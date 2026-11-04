import 'package:chefs_kiss/core/timers/kitchen_timers.dart';
import 'package:test/test.dart';

void main() {
  late DateTime now;
  late KitchenTimersController timers;
  final finished = <String>[];

  setUp(() {
    now = DateTime(2026, 11, 5, 12);
    finished.clear();
    timers = KitchenTimersController(clock: () => now)..onFinished = (t) => finished.add(t.id);
  });
  tearDown(() => timers.dispose());

  void start(String id, int seconds) =>
      timers.start(id: id, label: 'Boil', durationSeconds: seconds, recipeId: 'r', recipeTitle: 'Pasta');

  test('counts down from wall-clock time, not ticks', () {
    start('t1', 600);
    now = now.add(const Duration(minutes: 8, seconds: 30));
    expect(timers['t1']!.remainingSeconds(now), 90);
    expect(timers['t1']!.progress(now), closeTo(0.85, 1e-9));
  });

  test('pause freezes the remaining time and resume continues from it', () {
    start('t1', 120);
    now = now.add(const Duration(seconds: 50));
    timers.pause('t1');
    now = now.add(const Duration(hours: 1));
    expect(timers['t1']!.remainingSeconds(now), 70);
    expect(timers['t1']!.isRunning, isFalse);

    start('t1', 120);
    now = now.add(const Duration(seconds: 20));
    expect(timers['t1']!.remainingSeconds(now), 50);
  });

  test('fires onFinished exactly once and a finished timer restarts fresh', () {
    start('t1', 10);
    now = now.add(const Duration(seconds: 11));
    timers.tick();
    timers.tick();
    expect(finished, ['t1']);
    expect(timers['t1']!.finished, isTrue);
    expect(timers.running, isEmpty);

    start('t1', 10);
    expect(timers['t1']!.remainingSeconds(now), 10);
  });

  test('reset removes the timer', () {
    start('t1', 10);
    timers.reset('t1');
    expect(timers['t1'], isNull);
  });
}
