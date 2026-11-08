import 'dart:async';

import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../../app/app_info.dart';
import '../../../app/providers.dart';
import '../../../app/widgets/kitchen_format.dart';
import '../../library/domain/cookbook.dart';
import '../../library/domain/shelf_style.dart';
import '../../library/presentation/widgets/library_books.dart';
import '../../library/presentation/widgets/shelf_scene.dart';
import '../application/onboarding.dart';
import 'widgets/onboarding_widgets.dart';

/// The screens of the welcome tour, in order.
enum _Step {
  intro,
  welcome,
  cooked,
  home,
  name,
  greet,
  frequency,
  wants,
  keeps,
  honest,
  reassure,
  hero,
  vibe,
  taste,
  recipes,
  alive,
  goal,
  plates,
  building;

  /// Screens that move on by themselves; Back skips over them.
  bool get passes => this == intro || this == taste;
}

typedef _Option = ({String id, IconData icon, String label});

const List<_Option> _frequencies = [
  (id: 'now-and-then', icon: LucideIcons.coffee, label: 'Now and then'),
  (id: '1-2', icon: LucideIcons.egg, label: '1–2 days a week'),
  (id: '3-4', icon: LucideIcons.soup, label: '3–4 days a week'),
  (id: 'most', icon: LucideIcons.flame, label: 'Most days'),
  (id: 'daily', icon: LucideIcons.chefHat, label: 'Every single day'),
];

const List<_Option> _wants = [
  (id: 'one-place', icon: LucideIcons.bookHeart, label: 'One place for all my recipes'),
  (id: 'remember', icon: LucideIcons.notebookPen, label: 'Remembering what I’ve cooked'),
  (id: 'ideas', icon: LucideIcons.lightbulb, label: 'Ideas for what to cook tonight'),
  (id: 'eating', icon: LucideIcons.salad, label: 'Keeping an eye on what I eat'),
];

const List<_Option> _keeps = [
  (id: 'nowhere', icon: LucideIcons.wind, label: 'Nowhere, really'),
  (id: 'screenshots', icon: LucideIcons.images, label: 'Screenshots and bookmarks'),
  (id: 'notebook', icon: LucideIcons.notebookText, label: 'A notebook or recipe cards'),
  (id: 'memory', icon: LucideIcons.brain, label: 'In my head'),
  (id: 'apps', icon: LucideIcons.smartphone, label: 'Other apps'),
];

/// Plates stack about 2 cm apiece.
const _plateCm = 2;

/// The welcome tour, shown once on a new install: a few warm words, the
/// cook's name and habits, a look for their shelves, starter recipes to
/// begin with and a goal for the year — then into their kitchen.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> with TickerProviderStateMixin {
  _Step _step = _Step.intro;
  final _history = <_Step>[];
  final _answers = OnboardingAnswers();
  final _name = TextEditingController();
  final _looks = PageController();
  Timer? _auto;

  late final _privacyTap = TapGestureRecognizer()..onTap = () => context.push('/privacy');
  late final _termsTap = TapGestureRecognizer()..onTap = () => context.push('/terms');

  /// The last screen's progress ring.
  late final _progress = AnimationController(vsync: this, duration: const Duration(milliseconds: 4200));

  String get _cook => TourHeadline.plain(_answers.name.isEmpty ? 'chef' : _answers.name);

  @override
  void initState() {
    super.initState();
    _auto = Timer(const Duration(milliseconds: 1900), () {
      if (mounted && _step == _Step.intro) _go(_Step.welcome);
    });
  }

  @override
  void dispose() {
    _auto?.cancel();
    _name.dispose();
    _looks.dispose();
    _privacyTap.dispose();
    _termsTap.dispose();
    _progress.dispose();
    super.dispose();
  }

  void _go(_Step next) {
    _auto?.cancel();
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      if (!_step.passes) _history.add(_step);
      _step = next;
    });
    if (next == _Step.taste) {
      _auto = Timer(const Duration(milliseconds: 2300), () {
        if (mounted && _step == _Step.taste) _go(_Step.recipes);
      });
    }
    if (next == _Step.building) unawaited(_finish());
  }

  void _next() => _go(_Step.values[_step.index + 1]);

  /// Back goes to the previous screen; on the first one it leaves the app.
  Future<bool> _back() async {
    if (_history.isEmpty || _step == _Step.building) return false;
    _auto?.cancel();
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _step = _history.removeLast());
    return true;
  }

  /// Saves everything while the ring fills, then opens the kitchen.
  Future<void> _finish() async {
    final prefs = ref.read(preferencesRepositoryProvider);
    Future<void> save() async {
      try {
        final starters = _answers.starterIds.isEmpty ? const <Recipe>[] : await ref.read(starterRecipesProvider.future);
        await saveOnboarding(
          _answers,
          starters: starters,
          prefs: prefs,
          settings: ref.read(settingsRepositoryProvider),
          recipes: ref.read(recipeRepositoryProvider),
        );
      } catch (e, st) {
        // The kitchen opens either way; the answers are a nicety.
        ref.read(appLoggerProvider).error('Saving the welcome tour failed', feature: 'onboarding', error: e, stackTrace: st);
      }
    }

    Future<void> ring() async {
      if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
        _progress.value = 1;
        return;
      }
      await _progress.forward(from: 0).orCancel.catchError((_) {});
    }

    await Future.wait([save(), ring()]);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    // The router takes it from here: a finished tour opens the library.
    await prefs.writeJson(onboardingDoneKey, true);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ChefTheme.dark(),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
        child: BackButtonListener(
          onBackButtonPressed: _back,
          child: Scaffold(
            backgroundColor: TourColors.background,
            body: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(child: StarField(restartKey: _step)),
                Positioned.fill(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 520),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween(begin: const Offset(0, 0.02), end: Offset.zero).animate(animation),
                        child: child,
                      ),
                    ),
                    child: KeyedSubtree(key: ValueKey(_step), child: _screen(_step)),
                  ),
                ),
                if (_history.isNotEmpty && _step != _Step.building && _step != _Step.alive)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: IconButton(
                          tooltip: 'Back',
                          onPressed: _back,
                          icon: const Icon(LucideIcons.chevronLeft, color: TourColors.muted),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _screen(_Step step) => switch (step) {
    _Step.intro => const _Intro(),
    _Step.welcome => _Words(
      markup: 'Welcome, *chef*',
      body: 'Every recipe you’ve cooked, loved or can’t wait to try, finally in one place.',
      button: 'Start your journey',
      trailing: LucideIcons.arrowRight,
      onNext: _next,
      buttonInline: true,
    ),
    _Step.cooked => _Words(
      markup: 'You’ve cooked meals that *stayed with you*',
      body: 'The ones you made for someone you love. The ones you still crave. They’re all part of your story.',
      onNext: _next,
    ),
    _Step.home => _Words(
      markup: '${AppInfo.appName} is the home your recipes *deserve*',
      body: 'A warm, personal kitchen where every recipe you love lives on.',
      onNext: _next,
    ),
    _Step.name => _nameScreen(),
    _Step.greet => _Words(
      markup: 'Nice to meet you, *$_cook!*',
      body: 'Let’s set up your kitchen.',
      onNext: _next,
      centered: true,
    ),
    _Step.frequency => _Question(
      markup: 'How often do you cook *each week?*',
      options: _frequencies,
      isSelected: (id) => _answers.frequency == id,
      onTap: (id) => setState(() {
        _answers.frequency = id;
        if (!_goalTouched) _answers.goal = _goalFor[id] ?? _answers.goal;
      }),
      canContinue: _answers.frequency != null,
      onNext: _next,
    ),
    _Step.wants => _Question(
      markup: 'What’s missing in your *kitchen life?*',
      hint: 'Pick as many as you like.',
      options: _wants,
      multi: true,
      isSelected: _answers.wants.contains,
      onTap: (id) => setState(() => _answers.wants.contains(id) ? _answers.wants.remove(id) : _answers.wants.add(id)),
      canContinue: _answers.wants.isNotEmpty,
      onNext: _next,
    ),
    _Step.keeps => _Question(
      markup: 'Where do your recipes *live right now?*',
      options: _keeps,
      isSelected: (id) => _answers.keeps == id,
      onTap: (id) => setState(() => _answers.keeps = id),
      canContinue: _answers.keeps != null,
      onNext: _next,
    ),
    _Step.honest => _Words(markup: _honest.markup, body: _honest.body, onNext: _next),
    _Step.reassure => _Words(
      markup: 'It doesn’t have to be this way, *$_cook*',
      body: 'Every dish you love deserves a place to live on, beautifully, for years to come.',
      onNext: _next,
    ),
    _Step.hero => _heroScreen(),
    _Step.vibe => _vibeScreen(),
    _Step.taste => const _Words(
      markup: 'You’ve got great *taste!*',
      body: 'Your shelves are going to look beautiful.',
      centered: true,
    ),
    _Step.recipes => _recipesScreen(),
    _Step.alive => _aliveScreen(),
    _Step.goal => _goalScreen(),
    _Step.plates => _platesScreen(),
    _Step.building => _buildingScreen(),
  };

  /// A nudge that answers where the cook keeps their recipes now.
  ({String markup, String body}) get _honest => switch (_answers.keeps) {
    'screenshots' => (
      markup: 'Be honest: how many recipes are *lost in your screenshots?*',
      body: 'Somewhere between the memes and the receipts, a perfect curry is waiting.',
    ),
    'notebook' => (
      markup: 'Be honest: how many recipe cards have *a splash of sauce on them?*',
      body: 'Paper is lovely, until the page you need goes missing.',
    ),
    'apps' => (
      markup: 'Be honest: how many apps does it take to *cook one dinner?*',
      body: 'A bookmark here, a note there and a timer somewhere else.',
    ),
    'nowhere' => (
      markup: 'Be honest: how many dishes have you loved and *never made again?*',
      body: 'A recipe that isn’t kept anywhere slowly slips away.',
    ),
    _ => (
      markup: 'Be honest: how many family recipes live only in *someone’s memory?*',
      body: 'A recipe that’s never written down is one forgotten dinner away from being lost.',
    ),
  };

  /// How often they cook suggests a goal, until they set one themselves.
  static const _goalFor = {'now-and-then': 12, '1-2': 24, '3-4': 52, 'most': 52, 'daily': 104};
  bool _goalTouched = false;

  // --- Name -------------------------------------------------------------------------

  void _submitName() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    _answers.name = name;
    _next();
  }

  Widget _nameScreen() {
    final ready = _name.text.trim().isNotEmpty;
    const small = TextStyle(fontSize: 12.5, height: 1.5, color: TourColors.muted);
    const link = TextStyle(decoration: TextDecoration.underline, color: TourColors.cream);
    return _Page(
      scroll: true,
      children: [
        const Spacer(flex: 2),
        const Text('First of all…', style: TextStyle(fontSize: 15, color: TourColors.muted)),
        const SizedBox(height: 6),
        const TourHeadline('What should we call *you?*', align: TextAlign.start),
        const SizedBox(height: 22),
        TextField(
          controller: _name,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.givenName],
          maxLength: 30,
          cursorColor: TourColors.gold,
          style: const TextStyle(fontSize: 17, color: TourColors.cream),
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _submitName(),
          decoration: InputDecoration(
            hintText: 'Type your name…',
            hintStyle: TextStyle(color: TourColors.muted.withValues(alpha: 0.7)),
            counterText: '',
            filled: true,
            fillColor: TourColors.tile,
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: TourColors.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: TourColors.gold, width: 1.4),
            ),
          ),
        ),
        const Spacer(flex: 3),
        TourButton(label: 'Continue', onPressed: ready ? _submitName : null),
        const SizedBox(height: 12),
        Text.rich(
          TextSpan(
            style: small,
            children: [
              const TextSpan(text: 'By continuing, you accept our '),
              TextSpan(text: 'Privacy Policy', style: link, recognizer: _privacyTap),
              const TextSpan(text: ' and '),
              TextSpan(text: 'Terms of Use', style: link, recognizer: _termsTap),
              const TextSpan(text: '.'),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // --- Shelves ----------------------------------------------------------------------

  Widget _heroScreen() {
    final starters = ref.watch(starterRecipesProvider).valueOrNull ?? const <Recipe>[];
    return _Scene(
      top: const Column(
        children: [
          TourHeadline(AppInfo.appName, size: 44),
          SizedBox(height: 6),
          TourHeadline('the warm kitchen your recipes *were waiting for.*', size: 23),
        ],
      ),
      scene: ShelfScene(style: shelfLooks.first.style, books: starters, topPadding: 18),
      bottom: TourButton(label: 'Let’s begin', onPressed: _next),
    );
  }

  Widget _vibeScreen() {
    final index = shelfLooks.indexOf(_answers.look);
    void show(int i) => _looks.animateToPage(i, duration: ChefMotion.emphasis, curve: ChefMotion.easeStandard);
    if (!_looks.hasClients && index > 0) {
      // Back from a later screen: open on the look chosen before.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_looks.hasClients) _looks.jumpToPage(index);
      });
    }
    return _Scene(
      top: const Column(
        children: [
          Text(
            'Every cook has their vibe.',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: kSerifFamily, fontSize: 19, color: TourColors.muted),
          ),
          SizedBox(height: 4),
          TourHeadline('Which one feels like *yours?*'),
        ],
      ),
      scene: PageView.builder(
        controller: _looks,
        itemCount: shelfLooks.length,
        onPageChanged: (i) => setState(() => _answers.look = shelfLooks[i]),
        itemBuilder: (context, i) => ShelfScene(style: shelfLooks[i].style, topPadding: 18),
      ),
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: 'Previous look',
                onPressed: index > 0 ? () => show(index - 1) : null,
                icon: const Icon(LucideIcons.chevronLeft),
                color: TourColors.cream,
                disabledColor: TourColors.outline,
              ),
              SizedBox(
                width: 170,
                child: Text(
                  _answers.look.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: kSerifFamily,
                    fontStyle: FontStyle.italic,
                    fontSize: 24,
                    color: TourColors.cream,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Next look',
                onPressed: index < shelfLooks.length - 1 ? () => show(index + 1) : null,
                icon: const Icon(LucideIcons.chevronRight),
                color: TourColors.cream,
                disabledColor: TourColors.outline,
              ),
            ],
          ),
          const SizedBox(height: 6),
          _Dots(count: shelfLooks.length, active: index),
          const SizedBox(height: 18),
          TourButton(label: 'I like it!', onPressed: _next),
        ],
      ),
    );
  }

  Widget _recipesScreen() {
    final starters = ref.watch(starterRecipesProvider).valueOrNull ?? const <Recipe>[];
    final picked = _answers.starterIds.length;
    return _Page(
      children: [
        const SizedBox(height: 40),
        const Text(
          'Every cookbook starts with a recipe.',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: kSerifFamily, fontSize: 19, color: TourColors.muted),
        ),
        const SizedBox(height: 4),
        const TourHeadline('Which ones start *yours?*'),
        const SizedBox(height: 8),
        const TourBody('Pick a few classics to begin with. You can add your own any time.'),
        const SizedBox(height: 18),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.only(bottom: 12),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 132,
              childAspectRatio: 0.52,
              mainAxisSpacing: 14,
              crossAxisSpacing: 12,
            ),
            itemCount: starters.length,
            itemBuilder: (context, i) {
              final r = starters[i];
              final on = _answers.starterIds.contains(r.id);
              return _StarterTile(
                recipe: r,
                selected: on,
                onTap: () => setState(() => on ? _answers.starterIds.remove(r.id) : _answers.starterIds.add(r.id)),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        TourButton(
          label: picked == 0 ? 'Add to my cookbook' : 'Add $picked recipe${picked == 1 ? '' : 's'}',
          onPressed: picked == 0 ? null : _next,
        ),
        TourTextButton(
          label: 'I’ll add my own',
          onPressed: () {
            _answers.starterIds.clear();
            _next();
          },
        ),
      ],
    );
  }

  Widget _aliveScreen() {
    final count = _answers.starterIds.length;
    return Stack(
      fit: StackFit.expand,
      children: [
        _Scene(
          top: Column(
            children: [
              TourHeadline('Your kitchen is alive, *$_cook!*'),
              const SizedBox(height: 8),
              TourBody(
                count == 0
                    ? 'Your cookbook is ready for its first recipe.'
                    : '${count == 1 ? 'Your first recipe is' : '$count recipes are'} waiting in My Recipes.',
              ),
            ],
          ),
          scene: ShelfScene(
            style: _answers.look.style,
            books: [Cookbook.myRecipes(recipes: count)],
            topPadding: 18,
          ),
          bottom: TourButton(label: 'I’m so happy!', onPressed: _next),
        ),
        const Positioned.fill(child: ConfettiBurst()),
      ],
    );
  }

  // --- Goal -------------------------------------------------------------------------

  void _setGoal(int value) => setState(() {
    _goalTouched = true;
    _answers.goal = value.clamp(1, 365);
  });

  String get _goalHint {
    final n = _answers.goal;
    final perWeek = n / 52;
    if (n >= 365) return 'A new dish every single day!';
    if (perWeek >= 1.5) return 'About ${perWeek.round()} new dishes a week';
    if (perWeek >= 0.75) return 'About one new dish a week';
    if (n >= 18) return 'About ${(n / 12).round()} new dishes a month';
    if (n >= 9) return 'About one new dish a month';
    return 'A gentle start';
  }

  Widget _goalScreen() {
    final n = _answers.goal;
    return _Page(
      children: [
        const SizedBox(height: 48),
        const TourHeadline('How many new recipes do you want to try *this year?*'),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: 'Fewer',
              iconSize: 30,
              color: TourColors.gold,
              onPressed: n > 1 ? () => _setGoal(n - 1) : null,
              icon: const Icon(LucideIcons.circleMinus),
            ),
            SizedBox(
              width: 150,
              child: Semantics(
                label: '$n recipes this year',
                excludeSemantics: true,
                child: Text(
                  '$n',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w700,
                    color: TourColors.cream,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: 'More',
              iconSize: 30,
              color: TourColors.gold,
              onPressed: n < 365 ? () => _setGoal(n + 1) : null,
              icon: const Icon(LucideIcons.circlePlus),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: TourColors.gold,
            inactiveTrackColor: TourColors.outline,
            thumbColor: TourColors.cream,
            overlayColor: TourColors.gold.withValues(alpha: 0.15),
          ),
          child: Slider(
            value: n.toDouble(),
            min: 1,
            max: 365,
            label: '$n',
            semanticFormatterCallback: (v) => '${v.round()} recipes',
            onChanged: (v) => _setGoal(v.round()),
          ),
        ),
        const SizedBox(height: 8),
        TourBody(_goalHint),
        const Spacer(),
        TourButton(label: 'Continue', onPressed: _next),
      ],
    );
  }

  Widget _platesScreen() {
    final n = _answers.goal;
    final cm = n * _plateCm;
    final height = cm < 100 ? '$cm cm' : '${(cm / 100).toStringAsFixed(2)} m';
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return _Page(
      children: [
        const SizedBox(height: 48),
        TourHeadline('By the end of the year, that’s a stack of plates *~$height tall!*'),
        const SizedBox(height: 10),
        TourBody('$n new dishes, one plate at a time.'),
        Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: still ? n.toDouble() : 0, end: n.toDouble()),
            duration: Duration(milliseconds: still ? 0 : 2400),
            curve: Curves.easeOutCubic,
            builder: (context, plates, _) => PlateStack(plates: plates),
          ),
        ),
        TourButton(label: 'Continue', onPressed: _next),
      ],
    );
  }

  // --- Building ---------------------------------------------------------------------

  Widget _buildingScreen() {
    final first = ref
        .watch(starterRecipesProvider)
        .valueOrNull
        ?.where((r) => _answers.starterIds.contains(r.id))
        .firstOrNull;
    final tasks = [
      'Setting up your ${_answers.look.name.toLowerCase()} shelves',
      first == null ? 'Opening your cookbook' : 'Adding ${first.title}',
      'Saving your ${_answers.goal}-recipe goal',
      switch (_answers.wants) {
        final w when w.contains('eating') => 'Opening your food log',
        final w when w.contains('ideas') => 'Warming up Chef’s Kiss AI',
        final w when w.contains('remember') => 'Binding your cookbook journal',
        _ => 'Warming up the kitchen',
      },
    ];
    return _Page(
      children: [
        const Spacer(flex: 2),
        AnimatedBuilder(
          animation: _progress,
          builder: (context, _) {
            final p = _progress.value;
            return Column(
              children: [
                SizedBox.square(
                  dimension: 150,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: p,
                        strokeWidth: 9,
                        strokeCap: StrokeCap.round,
                        color: TourColors.gold,
                        backgroundColor: TourColors.outline,
                      ),
                      Center(
                        child: Text(
                          '${(p * 100).round()}%',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: TourColors.cream,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const TourHeadline('Building your *kitchen…*'),
                const SizedBox(height: 22),
                for (final (i, task) in tasks.indexed)
                  _Task(label: task, done: p >= (i + 1) / tasks.length, active: p >= i / tasks.length),
              ],
            );
          },
        ),
        const Spacer(flex: 3),
      ],
    );
  }
}

// --- Layouts --------------------------------------------------------------------------

/// A centred column of tour content, never wider than a phone.
class _Page extends StatelessWidget {
  final List<Widget> children;

  /// Lets a screen with a text field scroll above the keyboard.
  final bool scroll;
  const _Page({required this.children, this.scroll = false});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: scroll
                ? LayoutBuilder(
                    builder: (context, box) => SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: box.maxHeight),
                        child: IntrinsicHeight(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
                        ),
                      ),
                    ),
                  )
                : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
          ),
        ),
      ),
    );
  }
}

/// A few words and a button: the tour's story screens.
class _Words extends StatelessWidget {
  final String markup;
  final String body;
  final String button;
  final IconData? trailing;
  final VoidCallback? onNext;

  /// Words in the middle of the screen rather than its upper part.
  final bool centered;

  /// The button sits under the words instead of at the bottom.
  final bool buttonInline;

  const _Words({
    required this.markup,
    required this.body,
    this.button = 'Continue',
    this.trailing,
    this.onNext,
    this.centered = false,
    this.buttonInline = false,
  });

  @override
  Widget build(BuildContext context) {
    final align = centered ? TextAlign.center : TextAlign.start;
    final action = onNext == null ? null : TourButton(label: button, onPressed: onNext, trailing: trailing);
    return _Page(
      scroll: true,
      children: [
        Spacer(flex: centered ? 5 : 3),
        TourHeadline(markup, align: align, size: centered ? 30 : 32),
        const SizedBox(height: 14),
        TourBody(body, align: align),
        if (buttonInline && action != null) ...[const SizedBox(height: 32), action],
        Spacer(flex: centered ? 6 : 5),
        if (!buttonInline && action != null) action,
      ],
    );
  }
}

/// A question with answers to pick from.
class _Question extends StatelessWidget {
  final String markup;
  final String? hint;
  final List<_Option> options;
  final bool multi;
  final bool Function(String id) isSelected;
  final ValueChanged<String> onTap;
  final bool canContinue;
  final VoidCallback onNext;

  const _Question({
    required this.markup,
    this.hint,
    required this.options,
    this.multi = false,
    required this.isSelected,
    required this.onTap,
    required this.canContinue,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return _Page(
      children: [
        const SizedBox(height: 48),
        TourHeadline(markup),
        if (hint != null) ...[const SizedBox(height: 8), TourBody(hint!)],
        const SizedBox(height: 26),
        Expanded(
          child: ListView.separated(
            itemCount: options.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final o = options[i];
              return TourChoice(
                icon: o.icon,
                label: o.label,
                multi: multi,
                selected: isSelected(o.id),
                onTap: () => onTap(o.id),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        TourButton(label: 'Continue', onPressed: canContinue ? onNext : null),
      ],
    );
  }
}

/// Words on top, a bookcase filling the middle and a button below: the
/// bookcase fades into the evening at both edges.
class _Scene extends StatelessWidget {
  final Widget top;
  final Widget scene;
  final Widget bottom;
  const _Scene({required this.top, required this.scene, required this.bottom});

  @override
  Widget build(BuildContext context) {
    Widget fade(Alignment from) => IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: from,
            end: -from,
            colors: [TourColors.background, TourColors.background.withValues(alpha: 0)],
          ),
        ),
      ),
    );
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 40, 28, 16),
            child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 460), child: top),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: scene),
                Positioned(top: 0, left: 0, right: 0, height: 28, child: fade(Alignment.topCenter)),
                Positioned(bottom: 0, left: 0, right: 0, height: 72, child: fade(Alignment.bottomCenter)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
            child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 460), child: bottom),
          ),
        ],
      ),
    );
  }
}

// --- Pieces -----------------------------------------------------------------------------

/// The logo, coming into the light.
class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 1100),
        curve: Curves.easeOutCubic,
        builder: (context, t, child) => Opacity(
          opacity: t,
          child: Transform.scale(scale: 0.9 + 0.1 * t, child: child),
        ),
        child: Semantics(
          label: AppInfo.appName,
          child: Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: TourColors.cream,
              boxShadow: [BoxShadow(color: TourColors.gold.withValues(alpha: 0.25), blurRadius: 40, spreadRadius: 4)],
            ),
            clipBehavior: Clip.antiAlias,
            child: SvgPicture.asset('assets/illustrations/chef_kiss_logo.svg', fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}

/// A starter recipe as a little book: tap to put it in the cookbook.
class _StarterTile extends StatelessWidget {
  final Recipe recipe;
  final bool selected;
  final VoidCallback onTap;
  const _StarterTile({required this.recipe, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cuisine = recipe.labels.where((l) => l.kind == 'cuisine').firstOrNull?.displayName;
    final time = KitchenFormat.minutes(recipe.totalMinutes);
    final meta = [?cuisine, time].join(' · ');
    return Semantics(
      button: true,
      selected: selected,
      label: '${recipe.title}, $meta',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: selected ? TourColors.gold : Colors.transparent, width: 2),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.45), blurRadius: 6, offset: const Offset(1, 3)),
                        ],
                      ),
                      // Drawn at shelf size and scaled down, so titles break
                      // where they do on the shelf.
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: SizedBox(width: 124, height: 177, child: BookCoverFace(recipe: recipe)),
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: AnimatedOpacity(
                        opacity: selected ? 1 : 0,
                        duration: const Duration(milliseconds: 160),
                        child: const CircleAvatar(
                          radius: 11,
                          backgroundColor: TourColors.gold,
                          child: Icon(LucideIcons.check, size: 14, color: TourColors.ink),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            for (final line in [?cuisine, time])
              Text(
                line,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11.5, height: 1.3, color: TourColors.muted),
              ),
          ],
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int active;
  const _Dots({required this.count, required this.active});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == active ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == active ? TourColors.cream : TourColors.outline,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
        ],
      ),
    );
  }
}

/// One line of the "building" checklist.
class _Task extends StatelessWidget {
  final String label;
  final bool done;
  final bool active;
  const _Task({required this.label, required this.done, required this.active});

  @override
  Widget build(BuildContext context) {
    final Widget mark = done
        ? const Icon(LucideIcons.circleCheck, size: 18, color: TourColors.gold)
        : active
        ? const SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: TourColors.gold),
          )
        : Icon(Icons.circle_outlined, size: 18, color: TourColors.outline.withValues(alpha: 0.9));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          SizedBox(width: 22, child: Center(child: mark)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.5,
                color: done || active ? TourColors.cream : TourColors.muted.withValues(alpha: 0.55),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
