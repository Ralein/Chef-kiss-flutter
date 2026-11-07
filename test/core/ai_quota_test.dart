import 'package:chefs_kiss/core/ai/ai_usage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('free requests left this hour: counted per request, forgotten after an hour, kept across restarts', () {
    var now = DateTime(2026, 11, 7, 12);
    List<DateTime>? kept;
    final meter = AiUsageMeter(clock: () => now, onRecent: (r) => kept = r);
    expect(meter.leftThisHour, AiUsageMeter.hourlyLimit);

    meter
      ..noteRequest()
      ..noteRequest();
    expect(meter.leftThisHour, AiUsageMeter.hourlyLimit - 2);
    expect(kept, hasLength(2));

    now = now.add(const Duration(minutes: 61));
    expect(meter.leftThisHour, AiUsageMeter.hourlyLimit, reason: 'an hour on, they no longer count');

    // After a restart the kept requests still count.
    now = DateTime(2026, 11, 7, 12, 30);
    final restarted = AiUsageMeter(clock: () => now)..restore(kept!);
    expect(restarted.leftThisHour, AiUsageMeter.hourlyLimit - 2);
  });
}
