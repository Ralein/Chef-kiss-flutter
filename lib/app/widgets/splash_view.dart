import 'dart:async';

import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_info.dart';

/// The app icon's cream disc: the same picture the launcher and the system
/// splash show, so opening the app runs on without a jump.
const splashMedallionAsset = 'assets/illustrations/splash_medallion.png';

/// Matches the icon on Android, iOS and web launch screens (144 dp).
const splashMedallionSize = 144.0;

class BrandMedallion extends StatelessWidget {
  final double size;
  const BrandMedallion({super.key, this.size = splashMedallionSize});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: AppInfo.appName,
      child: Image.asset(
        splashMedallionAsset,
        width: size,
        height: size,
        filterQuality: FilterQuality.medium,
        gaplessPlayback: true,
      ),
    );
  }
}

/// Decodes the medallion before the first frame, so the launch screen
/// hands over to [SplashView] without a blink. Never waits more than a
/// moment.
Future<void> precacheSplashArt() async {
  final done = Completer<void>();
  final stream = const AssetImage(splashMedallionAsset).resolve(ImageConfiguration.empty);
  late final ImageStreamListener listener;
  listener = ImageStreamListener(
    (_, _) {
      if (!done.isCompleted) done.complete();
    },
    onError: (_, _) {
      if (!done.isCompleted) done.complete();
    },
  );
  stream.addListener(listener);
  await done.future.timeout(const Duration(milliseconds: 800), onTimeout: () {});
  stream.removeListener(listener);
}

/// How long the splash stays up at least, however fast the app is ready.
const splashMinimum = Duration(seconds: 2);

/// Set once the splash has been up for [splashMinimum].
final splashShownProvider = StateProvider<bool>((ref) => false);

/// The splash: the medallion where the system splash left it, the name
/// fading in, and a line that fills over [splashMinimum] before the app
/// takes over.
class SplashView extends ConsumerStatefulWidget {
  const SplashView({super.key});

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView> with SingleTickerProviderStateMixin {
  late final _fill = AnimationController(vsync: this, duration: splashMinimum);

  @override
  void initState() {
    super.initState();
    _fill.forward().whenComplete(() {
      if (mounted) ref.read(splashShownProvider.notifier).state = true;
    });
  }

  @override
  void dispose() {
    _fill.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final t = context.chefText;
    // The medallion stays dead centre, where the system splash drew it; the
    // name and the line sit below without moving it.
    const below = splashMedallionSize / 2 + 28;
    return Material(
      color: c.surfaceCanvas,
      child: AnimatedBuilder(
        animation: _fill,
        builder: (context, _) {
          final v = _fill.value;
          return Stack(
            fit: StackFit.expand,
            children: [
              const Center(child: BrandMedallion()),
              Center(
                child: Transform.translate(
                  offset: const Offset(0, below + 14),
                  child: Opacity(
                    opacity: Curves.easeOut.transform(((v - 0.1) / 0.3).clamp(0.0, 1.0)),
                    child: Text(AppInfo.appName, style: t.headlineSmall),
                  ),
                ),
              ),
              Center(
                child: Transform.translate(
                  offset: const Offset(0, below + 56),
                  child: SizedBox(
                    width: 96,
                    child: LinearProgressIndicator(
                      value: Curves.easeInOut.transform(v),
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
