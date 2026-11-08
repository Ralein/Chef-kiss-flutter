import 'dart:async';

import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../../app/app_info.dart';
import '../../../app/providers.dart';
import '../../../app/widgets/kitchen_format.dart';
import '../../../app/widgets/splash_view.dart';
import '../../library/domain/cookbook.dart';
import '../../library/domain/shelf_style.dart';
import '../../library/presentation/widgets/library_books.dart';
import '../../library/presentation/widgets/shelf_scene.dart';
import '../../scan/presentation/scan_screen.dart' show ScanModeCopy;
import '../application/onboarding.dart';

/// The tour's screens, in order. Those between the welcome and the end are
/// the steps the progress line counts.
enum _Step { welcome, name, cooking, look, recipes, goal, ready }

const _steps = 5;

typedef _Option = ({String id, IconData icon, String label});

const List<_Option> _frequencies = [
  (id: 'now-and-then', icon: LucideIcons.coffee, label: 'Now and then'),
  (id: '1-2', icon: LucideIcons.egg, label: '1–2 days a week'),
  (id: '3-4', icon: LucideIcons.soup, label: '3–4 days a week'),
  (id: 'most', icon: LucideIcons.flame, label: 'Most days'),
  (id: 'daily', icon: LucideIcons.chefHat, label: 'Every day'),
];

const List<_Option> _wants = [
  (id: 'one-place', icon: LucideIcons.bookHeart, label: 'All my recipes in one place'),
  (id: 'remember', icon: LucideIcons.notebookPen, label: 'Remembering what I’ve cooked'),
  (id: 'ideas', icon: LucideIcons.lightbulb, label: 'Ideas for what to cook'),
  (id: 'eating', icon: LucideIcons.salad, label: 'Keeping an eye on what I eat'),
];

const List<_Option> _keeps = [
  (id: 'nowhere', icon: LucideIcons.sparkles, label: 'Nowhere yet'),
  (id: 'screenshots', icon: LucideIcons.images, label: 'Screenshots and bookmarks'),
  (id: 'notebook', icon: LucideIcons.notebookText, label: 'A notebook or cards'),
  (id: 'memory', icon: LucideIcons.brain, label: 'In my head'),
  (id: 'apps', icon: LucideIcons.smartphone, label: 'Other apps'),
];

/// Paces to set the goal with one tap.
const _paces = [
  (goal: 12, label: 'One a month'),
  (goal: 26, label: 'Every other week'),
  (goal: 52, label: 'One a week'),
  (goal: 104, label: 'Two a week'),
];

/// How often someone cooks suggests a goal, until they set one.
const _goalFor = {'now-and-then': 12, '1-2': 26, '3-4': 52, 'most': 52, 'daily': 104};

/// The welcome tour, shown once on a new install: a name, a little about
/// their cooking, a look for their shelves, starter recipes and a goal for
/// the year, then into their kitchen. It wears the app's own theme, so it
/// follows light and dark like everything else.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  _Step _step = _Step.welcome;
  bool _forward = true;
  final _answers = OnboardingAnswers();
  final _name = TextEditingController();

  /// A goal the cook set (or saved before): how often they cook no longer
  /// suggests one.
  bool _goalSet = false;
  bool _saving = false;

  late final _privacyTap = TapGestureRecognizer()..onTap = () => context.push('/privacy');
  late final _termsTap = TapGestureRecognizer()..onTap = () => context.push('/terms');

  @override
  void initState() {
    super.initState();
    unawaited(_prefill());
  }

  @override
  void dispose() {
    _name.dispose();
    _privacyTap.dispose();
    _termsTap.dispose();
    super.dispose();
  }

  /// A cook seeing a new version of the tour starts from what they set.
  Future<void> _prefill() async {
    try {
      final prefs = ref.read(preferencesRepositoryProvider);
      final profile = await ref.read(settingsRepositoryProvider).watchProfile().first;
      final goal = await prefs.readJson(cookingGoalKey);
      final habits = await prefs.readJson(cookingHabitsKey);
      final shelves = ShelfStyle.fromJson(await prefs.readJson(shelfStyleKey));
      if (!mounted) return;
      setState(() {
        _answers.prefill(name: profile.displayName, goal: goal is int ? goal : null, habits: habits, shelves: shelves);
        _goalSet = goal is int;
        if (_name.text.isEmpty) _name.text = _answers.name;
      });
    } catch (_) {
      // A fresh start is fine too.
    }
  }

  void _go(_Step next) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _forward = next.index > _step.index;
      _step = next;
    });
  }

  void _next() => _go(_Step.values[_step.index + 1]);

  bool get _canGoBack => _step != _Step.welcome && _step != _Step.ready && !_saving;

  /// Back goes a step back; from the last screen it opens the kitchen, and
  /// from the first it leaves the app.
  Future<bool> _back() async {
    if (_step == _Step.ready) {
      unawaited(_openKitchen());
      return true;
    }
    if (!_canGoBack) return false;
    _go(_Step.values[_step.index - 1]);
    return true;
  }

  /// Saves the answers, then shows the kitchen they set up.
  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final starters = _answers.starterIds.isEmpty ? const <Recipe>[] : await ref.read(starterRecipesProvider.future);
      await saveOnboarding(
        _answers,
        starters: starters,
        prefs: ref.read(preferencesRepositoryProvider),
        settings: ref.read(settingsRepositoryProvider),
        recipes: ref.read(recipeRepositoryProvider),
      );
    } catch (e, st) {
      // The kitchen opens either way; the answers are a nicety.
      ref.read(appLoggerProvider).error('Saving the welcome tour failed', feature: 'onboarding', error: e, stackTrace: st);
    }
    if (!mounted) return;
    setState(() => _saving = false);
    _go(_Step.ready);
  }

  /// The router takes it from here: a finished tour opens the library.
  Future<void> _openKitchen() => markTourDone(ref.read(preferencesRepositoryProvider));

  @override
  Widget build(BuildContext context) {
    final progress = switch (_step) {
      _Step.welcome || _Step.ready => null,
      _ => _step.index / _steps,
    };
    return BackButtonListener(
      onBackButtonPressed: _back,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(onBack: _canGoBack ? _back : null, progress: progress, step: _step.index),
              Expanded(
                child: AnimatedSwitcher(
                  duration: ChefMotion.emphasis,
                  switchInCurve: ChefMotion.easeExit,
                  switchOutCurve: Curves.easeIn,
                  // Forward slides in from the right, back from the left.
                  transitionBuilder: (child, animation) {
                    final incoming = child.key == ValueKey(_step);
                    final dx = (_forward ? 1 : -1) * (incoming ? 0.06 : -0.06);
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween(begin: Offset(dx, 0), end: Offset.zero).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: KeyedSubtree(key: ValueKey(_step), child: _page(_step)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _page(_Step step) => switch (step) {
    _Step.welcome => _welcomePage(),
    _Step.name => _namePage(),
    _Step.cooking => _cookingPage(),
    _Step.look => _lookPage(),
    _Step.recipes => _recipesPage(),
    _Step.goal => _goalPage(),
    _Step.ready => _readyPage(),
  };

  // --- Welcome ----------------------------------------------------------------------

  Widget _welcomePage() {
    final t = context.chefText;
    final c = context.chefColors;
    final starters = ref.watch(starterRecipesProvider).valueOrNull ?? const <Recipe>[];
    final link = TextStyle(color: c.accentTomato, fontWeight: FontWeight.w600);
    return _Page(
      centered: true,
      action: FilledButton(onPressed: _next, child: const Text('Get started')),
      footer: Text.rich(
        TextSpan(
          style: t.bodySmall,
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
      children: [
        // The kitchen shelves, with the medallion from the launch screen.
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            _ShelfPreview(style: shelfLooks.first.style, books: starters, height: 300),
            Positioned(
              bottom: -38,
              child: DecoratedBox(
                decoration: BoxDecoration(color: c.surfaceCanvas, shape: BoxShape.circle),
                child: const Padding(padding: EdgeInsets.all(5), child: BrandMedallion(size: 68)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 54),
        Semantics(
          header: true,
          child: Text('Welcome to ${AppInfo.appName}', style: t.headlineLarge, textAlign: TextAlign.center),
        ),
        const SizedBox(height: 10),
        Text(
          'Keep the recipes you love on your own kitchen shelves, cook them step by step and keep an eye on '
          'what you eat.',
          style: t.bodyLarge?.copyWith(color: c.contentSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // --- Name -------------------------------------------------------------------------

  void _submitName() {
    _answers.name = _name.text.trim();
    _next();
  }

  Widget _namePage() {
    return _Page(
      title: 'What should we call you?',
      subtitle: 'It’s how ${AppInfo.appName} greets you, and it stays on this phone.',
      action: FilledButton(onPressed: _submitName, child: const Text('Continue')),
      children: [
        TextField(
          controller: _name,
          autofocus: _name.text.isEmpty,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.givenName],
          maxLength: 30,
          onSubmitted: (_) => _submitName(),
          decoration: const InputDecoration(
            hintText: 'Your name',
            counterText: '',
            prefixIcon: Icon(LucideIcons.userRound),
          ),
        ),
      ],
    );
  }

  // --- Cooking ----------------------------------------------------------------------

  void _setFrequency(String id) => setState(() {
    _answers.frequency = _answers.frequency == id ? null : id;
    if (!_goalSet && _answers.frequency != null) _answers.goal = _goalFor[id] ?? _answers.goal;
  });

  Widget _cookingPage() {
    return _Page(
      title: 'About your cooking',
      subtitle: 'A few taps so ${AppInfo.appName} can suggest where to start. Skip any you like.',
      action: FilledButton(onPressed: _next, child: const Text('Continue')),
      children: [
        _ChipGroup(
          label: 'How often do you cook?',
          options: _frequencies,
          selected: {?_answers.frequency},
          onTap: _setFrequency,
        ),
        const SizedBox(height: 24),
        _ChipGroup(
          label: 'What would help most?',
          options: _wants,
          selected: _answers.wants,
          onTap: (id) => setState(() => _answers.wants.contains(id) ? _answers.wants.remove(id) : _answers.wants.add(id)),
        ),
        const SizedBox(height: 24),
        _ChipGroup(
          label: 'Where do your recipes live now?',
          options: _keeps,
          selected: {?_answers.keeps},
          onTap: (id) => setState(() => _answers.keeps = _answers.keeps == id ? null : id),
        ),
      ],
    );
  }

  // --- Look -------------------------------------------------------------------------

  Widget _lookPage() {
    final own = _answers.ownShelves;
    final options = [
      if (own != null) (name: 'My shelves', style: own, look: null),
      for (final look in shelfLooks) (name: look.name, style: look.style, look: look),
    ];
    return _Page(
      title: 'Pick a look for your shelves',
      subtitle: 'Your recipes live on these shelves. Restyle them any time with the brush on the Recipes tab.',
      action: FilledButton(onPressed: _next, child: const Text('Continue')),
      children: [
        _ShelfPreview(style: _answers.shelves, books: [Cookbook.myRecipes(recipes: 0)], height: 280),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (i, option) in options.indexed) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(
                child: _LookTile(
                  name: option.name,
                  style: option.style,
                  selected: _answers.look == option.look,
                  onTap: () => setState(() => _answers.look = option.look),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // --- Recipes ----------------------------------------------------------------------

  Widget _recipesPage() {
    final starters = ref.watch(starterRecipesProvider).valueOrNull ?? const <Recipe>[];
    final owned = {for (final r in ref.watch(allRecipesProvider).valueOrNull ?? const <Recipe>[]) r.id};
    final available = [
      for (final r in starters)
        if (!owned.contains(r.id)) r.id,
    ];
    final picked = _answers.starterIds.length;
    final all = available.isNotEmpty && available.every(_answers.starterIds.contains);
    return _Page(
      title: 'Start with a few classics',
      subtitle: 'Tested recipes you can cook from today. Pick any you like; add your own whenever you want.',
      action: FilledButton(
        onPressed: _next,
        child: Text(picked == 0 ? 'Continue' : 'Add $picked recipe${picked == 1 ? '' : 's'}'),
      ),
      children: [
        if (available.isNotEmpty)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => setState(() => all ? _answers.starterIds.clear() : _answers.starterIds.addAll(available)),
              child: Text(all ? 'Clear' : 'Select all'),
            ),
          ),
        for (final r in starters)
          _StarterRow(
            recipe: r,
            owned: owned.contains(r.id),
            selected: _answers.starterIds.contains(r.id),
            onChanged: (on) => setState(() => on ? _answers.starterIds.add(r.id) : _answers.starterIds.remove(r.id)),
          ),
      ],
    );
  }

  // --- Goal -------------------------------------------------------------------------

  void _setGoal(int value) => setState(() {
    _goalSet = true;
    _answers.goal = value.clamp(1, 365);
  });

  Widget _goalPage() {
    final t = context.chefText;
    final c = context.chefColors;
    return _Page(
      title: 'Set a goal for ${DateTime.now().year}',
      subtitle: 'How many new recipes would you like to try this year? You can change it in Settings.',
      action: FilledButton(
        onPressed: _saving ? null : _save,
        child: _saving
            ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2.5))
            : const Text('Continue'),
      ),
      children: [
        Center(child: _GoalStepper(value: _answers.goal, onChanged: _setGoal)),
        const SizedBox(height: 8),
        Center(child: Text('new recipes this year', style: t.bodyMedium?.copyWith(color: c.contentSecondary))),
        const SizedBox(height: 28),
        Text('Or pick a pace', style: t.titleMedium),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final pace in _paces)
              FilterChip(
                label: Text(pace.label),
                selected: _answers.goal == pace.goal,
                showCheckmark: false,
                onSelected: (_) => _setGoal(pace.goal),
              ),
          ],
        ),
      ],
    );
  }

  // --- Ready ------------------------------------------------------------------------

  /// Where to begin, from what the cook said about their cooking.
  List<_Tip> _tips(ChefColors c) {
    final tips = <_Tip>[];
    void add(_Tip tip) {
      if (tips.length < 3 && !tips.any((t) => t.title == tip.title)) tips.add(tip);
    }

    switch (_answers.keeps) {
      case 'screenshots' || 'notebook':
        add((
          icon: ScanMode.recipeCard.icon,
          tint: c.accentHerb,
          title: 'Scan the recipes you have',
          body: 'On the Scan tab, choose Recipe and snap a cookbook page, a card or a screenshot.',
        ));
      case 'apps':
        add((
          icon: LucideIcons.link,
          tint: c.accentYolk,
          title: 'Bring recipes from the web',
          body: 'Tap New recipe, then Import from a website, and paste the link.',
        ));
      case 'memory' || 'nowhere':
        add((
          icon: LucideIcons.notebookPen,
          tint: c.accentHerb,
          title: 'Write one down',
          body: 'Tap New recipe to write it yourself, or describe a dish and let AI write it.',
        ));
    }
    for (final want in _answers.wants) {
      switch (want) {
        case 'ideas':
          add((
            icon: ScanMode.ingredients.icon,
            tint: c.accentTomato,
            title: 'Find something to cook',
            body: 'On the Scan tab, choose Ingredients and snap your fridge for ideas.',
          ));
        case 'eating':
          add((
            icon: ScanMode.meal.icon,
            tint: c.accentYolk,
            title: 'Log what you eat',
            body: 'On the Scan tab, choose Meal to see calories and macros, then log it.',
          ));
        case 'remember':
          add((
            icon: LucideIcons.bookOpen,
            tint: c.accentTomato,
            title: 'Read it like a cookbook',
            body: 'Open My Recipes on your shelf and turn the pages.',
          ));
      }
    }
    if (_answers.starterIds.isNotEmpty) {
      add((
        icon: LucideIcons.chefHat,
        tint: c.accentTomato,
        title: 'Cook step by step',
        body: 'Open a recipe and tap Cook for one step at a time, with timers and read-aloud.',
      ));
    }
    add((
      icon: LucideIcons.plus,
      tint: c.accentHerb,
      title: 'Add your own recipes',
      body: 'Tap New recipe to scan, import, paste or write one.',
    ));
    return tips;
  }

  Widget _readyPage() {
    final t = context.chefText;
    final c = context.chefColors;
    final starters = ref.watch(starterRecipesProvider).valueOrNull ?? const <Recipe>[];
    final picked = [
      for (final r in starters)
        if (_answers.starterIds.contains(r.id)) r.title,
    ];
    final name = _answers.name.trim();
    return _Page(
      centered: true,
      action: FilledButton(onPressed: _openKitchen, child: const Text('Open my kitchen')),
      children: [
        _ShelfPreview(style: _answers.shelves, books: [Cookbook.myRecipes(recipes: picked.length)], height: 220),
        const SizedBox(height: 24),
        Semantics(
          header: true,
          child: Text(
            name.isEmpty || name == defaultCookName ? 'Your kitchen is ready' : 'Your kitchen is ready, $name',
            style: t.headlineMedium,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          switch (picked.length) {
            0 => 'Your shelves are set up. Add your first recipe whenever you like.',
            1 => '${picked.first} is waiting in My Recipes.',
            final n => '${picked.first} and ${n - 1} more are waiting in My Recipes.',
          },
          style: t.bodyLarge?.copyWith(color: c.contentSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        Align(alignment: Alignment.centerLeft, child: Text('A good place to start', style: t.titleMedium)),
        const SizedBox(height: 4),
        for (final tip in _tips(c)) _TipRow(tip: tip),
      ],
    );
  }
}

// --- Layout ---------------------------------------------------------------------------

/// Back on the left, and how far along the tour is as a line in the middle.
class _TopBar extends StatelessWidget {
  final Future<bool> Function()? onBack;
  final double? progress;
  final int step;
  const _TopBar({required this.onBack, required this.progress, required this.step});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          SizedBox(width: 56, child: onBack == null ? null : BackButton(onPressed: () => onBack!())),
          Expanded(
            child: AnimatedOpacity(
              opacity: progress == null ? 0 : 1,
              duration: ChefMotion.standard,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: Semantics(
                    label: progress == null ? null : 'Step $step of $_steps',
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(end: progress ?? 1),
                      duration: ChefMotion.emphasis,
                      curve: ChefMotion.easeStandard,
                      builder: (context, value, _) => LinearProgressIndicator(
                        value: value,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 56),
        ],
      ),
    );
  }
}

/// One screen of the tour: a title and what it's for, its content, and the
/// one button that moves on, kept at the bottom.
class _Page extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final List<Widget> children;
  final Widget action;
  final Widget? footer;

  /// Content centred on the screen (the welcome and the end).
  final bool centered;

  const _Page({
    this.title,
    this.subtitle,
    required this.children,
    required this.action,
    this.footer,
    this.centered = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.chefText;
    final c = context.chefColors;
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: box.maxHeight - 20),
                child: Align(
                  alignment: centered ? Alignment.center : Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                      children: [
                        if (title != null) ...[
                          Semantics(header: true, child: Text(title!, style: t.headlineMedium)),
                          if (subtitle != null) ...[
                            const SizedBox(height: 8),
                            Text(subtitle!, style: t.bodyLarge?.copyWith(color: c.contentSecondary)),
                          ],
                          const SizedBox(height: 24),
                        ],
                        ...children,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: double.infinity, child: action),
                  if (footer != null) ...[const SizedBox(height: 12), footer!],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --- Pieces -----------------------------------------------------------------------------

/// The kitchen shelves in a rounded window, drawn as the library draws them.
class _ShelfPreview extends StatelessWidget {
  final ShelfStyle style;
  final List<Recipe> books;
  final double height;
  const _ShelfPreview({required this.style, required this.books, required this.height});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final radius = BorderRadius.circular(ChefRadius.card);
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(borderRadius: radius, color: style.wallColor),
      foregroundDecoration: BoxDecoration(borderRadius: radius, border: Border.all(color: c.outlineSubtle)),
      clipBehavior: Clip.antiAlias,
      child: AnimatedSwitcher(
        duration: ChefMotion.emphasis,
        layoutBuilder: (current, previous) => Stack(fit: StackFit.expand, children: [...previous, ?current]),
        // Laid out at phone width, then fitted to the window.
        child: FittedBox(
          key: ValueKey(Object.hash(style, books.length)),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 390,
            height: 430,
            child: ShelfScene(style: style, books: books, topPadding: 12),
          ),
        ),
      ),
    );
  }
}

/// A group of answers, as the library's filter chips.
class _ChipGroup extends StatelessWidget {
  final String label;
  final List<_Option> options;
  final Set<String> selected;
  final ValueChanged<String> onTap;
  const _ChipGroup({required this.label, required this.options, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.chefText.titleMedium),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final o in options)
              FilterChip(
                avatar: Icon(o.icon, size: 16),
                label: Text(o.label),
                selected: selected.contains(o.id),
                showCheckmark: false,
                onSelected: (_) => onTap(o.id),
              ),
          ],
        ),
      ],
    );
  }
}

/// A look in miniature, as the shelf editor shows it.
class _LookTile extends StatelessWidget {
  final String name;
  final ShelfStyle style;
  final bool selected;
  final VoidCallback onTap;
  const _LookTile({required this.name, required this.style, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final t = context.chefText;
    return Semantics(
      button: true,
      selected: selected,
      label: name,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            AnimatedContainer(
              duration: ChefMotion.quick,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: style.wallColor,
                border: Border.all(color: selected ? c.accentTomato : c.outlineSubtle, width: selected ? 2 : 1),
              ),
              clipBehavior: Clip.antiAlias,
              child: ShelfMiniRoom(style),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: t.labelMedium?.copyWith(
                color: selected ? c.contentPrimary : c.contentSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A starter recipe to tick, with its little book beside it.
class _StarterRow extends StatelessWidget {
  final Recipe recipe;
  final bool owned;
  final bool selected;
  final ValueChanged<bool> onChanged;
  const _StarterRow({required this.recipe, required this.owned, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cuisine = recipe.labels.where((l) => l.kind == 'cuisine').firstOrNull?.displayName;
    final meta = [?cuisine, KitchenFormat.minutes(recipe.totalMinutes)].join(' · ');
    return CheckboxListTile(
      value: owned || selected,
      onChanged: owned ? null : (on) => onChanged(on ?? false),
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.trailing,
      secondary: SizedBox(
        width: 40,
        height: 56,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: FittedBox(
            fit: BoxFit.fill,
            child: SizedBox(width: 124, height: 177, child: BookCoverFace(recipe: recipe)),
          ),
        ),
      ),
      title: Text(recipe.title),
      subtitle: Text(owned ? 'Already in your cookbook' : meta),
    );
  }
}

/// The servings stepper's shape, for a yearly goal.
class _GoalStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _GoalStepper({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: c.surfaceRaised, borderRadius: BorderRadius.circular(ChefRadius.pill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Fewer',
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_rounded),
          ),
          SizedBox(
            width: 104,
            child: Semantics(
              liveRegion: true,
              label: '$value new recipes',
              excludeSemantics: true,
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: ChefTypography.numeric(c.contentPrimary, size: 34, weight: FontWeight.w700),
              ),
            ),
          ),
          IconButton(
            tooltip: 'More',
            onPressed: value < 365 ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

typedef _Tip = ({IconData icon, Color tint, String title, String body});

/// A way to begin, set like the options of the add-recipe sheet.
class _TipRow extends StatelessWidget {
  final _Tip tip;
  const _TipRow({required this.tip});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final t = context.chefText;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: c.meterTrack(tip.tint), borderRadius: BorderRadius.circular(12)),
            child: Icon(tip.icon, color: tip.tint, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tip.title, style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(tip.body, style: t.bodyMedium?.copyWith(color: c.contentSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
