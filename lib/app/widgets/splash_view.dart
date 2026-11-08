import 'dart:async';

import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

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

/// Shown while the app works out where to open: the medallion where the
/// system splash left it, then the name, and a progress line only if it's
/// taking a while.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  bool _named = false;
  bool _slow = false;
  final _timers = <Timer>[];

  @override
  void initState() {
    super.initState();
    _timers
      ..add(Timer(const Duration(milliseconds: 350), () => setState(() => _named = true)))
      ..add(Timer(const Duration(milliseconds: 1600), () => setState(() => _slow = true)));
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final t = context.chefText;
    // The medallion stays dead centre, where the system splash drew it; the
    // name and progress line sit below without moving it.
    const below = splashMedallionSize / 2 + 28;
    return Material(
      color: c.surfaceCanvas,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Center(child: BrandMedallion()),
          Center(
            child: Transform.translate(
              offset: const Offset(0, below + 14),
              child: AnimatedOpacity(
                opacity: _named ? 1 : 0,
                duration: ChefMotion.emphasis,
                child: Text(AppInfo.appName, style: t.headlineSmall),
              ),
            ),
          ),
          Center(
            child: Transform.translate(
              offset: const Offset(0, below + 56),
              // Built only once it's needed: the line animates for as long as it's there.
              child: AnimatedSwitcher(
                duration: ChefMotion.emphasis,
                child: _slow
                    ? SizedBox(
                        width: 96,
                        child: LinearProgressIndicator(minHeight: 4, borderRadius: BorderRadius.circular(2)),
                      )
                    : const SizedBox(width: 96, height: 4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
