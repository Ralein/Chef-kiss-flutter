import 'dart:math' as math;

import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:recipe_domain/recipe_domain.dart';

import 'kitchen_format.dart';

/// Swatch shown *beside* text so identity never relies on color alone.
class _Swatch extends StatelessWidget {
  final Color color;
  const _Swatch(this.color);

  @override
  Widget build(BuildContext context) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
  );
}

/// A single ratio against a limit: 8px bar whose track is a lighter step of
/// the fill's own hue.
class Meter extends StatelessWidget {
  final double fraction;
  final Color color;
  final double height;

  const Meter({super.key, required this.fraction, required this.color, this.height = 8});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final f = fraction.isFinite ? fraction.clamp(0.0, 1.0).toDouble() : 0.0;
    final radius = BorderRadius.circular(height);
    // The track always spans the full width; the fill grows from the left.
    return LayoutBuilder(
      builder: (context, box) => Container(
        height: height,
        width: double.infinity,
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(color: c.meterTrack(color), borderRadius: radius),
        child: Container(
          width: box.maxWidth * f,
          height: height,
          decoration: BoxDecoration(color: color, borderRadius: radius),
        ),
      ),
    );
  }
}

/// The one big number on a nutrition view ("1,284 kcal"). A single
/// wrapping Text.rich, so very large text sizes wrap instead of overflowing.
class KcalHero extends StatelessWidget {
  final double calories;
  final TextStyle? style;
  const KcalHero({super.key, required this.calories, this.style});

  @override
  Widget build(BuildContext context) {
    final t = context.chefText;
    final c = context.chefColors;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: KitchenFormat.kcal(calories), style: style ?? t.displayLarge),
          TextSpan(
            text: '  kcal',
            style: t.titleMedium?.copyWith(color: c.contentSecondary),
          ),
        ],
      ),
    );
  }
}

/// Daily calories: one hero figure plus a goal meter. Going over the goal
/// switches the fill to the warning status color and adds icon + label.
class CalorieSummary extends StatelessWidget {
  final double consumed;
  final double goal;
  final String caption;

  const CalorieSummary({super.key, required this.consumed, required this.goal, this.caption = 'eaten today'});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final t = context.chefText;
    final over = consumed > goal && goal > 0;
    final remaining = (goal - consumed).abs();

    return Semantics(
      container: true,
      label: '${KitchenFormat.kcal(consumed)} kilocalories $caption, goal ${KitchenFormat.kcal(goal)}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KcalHero(calories: consumed),
          Text(
            '$caption · goal ${KitchenFormat.kcal(goal)} kcal',
            style: t.bodyMedium?.copyWith(color: c.contentSecondary),
          ),
          const SizedBox(height: 14),
          Meter(fraction: goal <= 0 ? 0 : consumed / goal, color: over ? c.stateWarning : c.chartPrimary, height: 10),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                over ? Icons.trending_up_rounded : Icons.flag_outlined,
                size: 16,
                color: over ? c.stateWarning : c.contentSecondary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  over
                      ? '${KitchenFormat.kcal(remaining)} kcal over goal'
                      : '${KitchenFormat.kcal(remaining)} kcal left',
                  style: t.labelLarge?.copyWith(color: c.contentPrimary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Labeled macro meter row: "■ Protein   42 / 50 g" over a meter.
class MacroMeterRow extends StatelessWidget {
  final String label;
  final double grams;
  final double goalGrams;
  final Color color;

  const MacroMeterRow({
    super.key,
    required this.label,
    required this.grams,
    required this.goalGrams,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.chefText;
    return Semantics(
      label: '$label ${grams.round()} of ${goalGrams.round()} grams',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Swatch(color),
              const SizedBox(width: 8),
              Expanded(child: Text(label, style: t.labelLarge)),
              Text('${grams.round()}', style: t.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
              Text(' / ${goalGrams.round()} g', style: t.bodySmall),
            ],
          ),
          const SizedBox(height: 6),
          Meter(fraction: goalGrams <= 0 ? 0 : grams / goalGrams, color: color),
        ],
      ),
    );
  }
}

/// Thin segmented bar of energy from protein | carbs | fat (fixed order).
/// No text on the bar: the [MacroLegend] beside it carries the figures.
class MacroSplitBar extends StatelessWidget {
  final NutritionFacts facts;
  final double height;

  const MacroSplitBar({super.key, required this.facts, this.height = 8});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final split = facts.macroEnergySplit;
    final parts = [
      (split.protein, c.macroProtein),
      (split.carbs, c.macroCarbs),
      (split.fat, c.macroFat),
    ].where((p) => p.$1 > 0).toList();

    final label =
        'Energy split: protein ${(split.protein * 100).round()}%, '
        'carbs ${(split.carbs * 100).round()}%, fat ${(split.fat * 100).round()}%';

    if (parts.isEmpty) {
      return Semantics(
        label: 'No macro data',
        child: Container(
          height: height,
          decoration: BoxDecoration(color: c.surfaceRaised, borderRadius: BorderRadius.circular(height)),
        ),
      );
    }
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height),
        child: SizedBox(
          height: height,
          child: Row(
            children: [
              for (var i = 0; i < parts.length; i++) ...[
                if (i > 0) SizedBox(width: 2, child: ColoredBox(color: c.surfacePaper)),
                Expanded(
                  flex: math.max(1, (parts[i].$1 * 1000).round()),
                  child: ColoredBox(color: parts[i].$2),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Swatched rows naming each macro with grams and share of energy.
class MacroLegend extends StatelessWidget {
  final NutritionFacts facts;
  const MacroLegend({super.key, required this.facts});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final t = context.chefText;
    final split = facts.macroEnergySplit;
    Widget row(String name, double grams, double share, Color color) => Expanded(
      child: Row(
        children: [
          _Swatch(color),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(KitchenFormat.grams(grams), style: t.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
                Text('$name · ${(share * 100).round()}%', style: t.bodySmall, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
    return Row(
      children: [
        row('Protein', facts.proteinG, split.protein, c.macroProtein),
        row('Carbs', facts.carbsG, split.carbs, c.macroCarbs),
        row('Fat', facts.fatG, split.fat, c.macroFat),
      ],
    );
  }
}

/// Secondary nutrients as compact label/value pairs.
class NutrientFootnote extends StatelessWidget {
  final NutritionFacts facts;
  const NutrientFootnote({super.key, required this.facts});

  @override
  Widget build(BuildContext context) {
    final t = context.chefText;
    Widget item(String label, String value) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: t.labelLarge),
        Text(label, style: t.bodySmall),
      ],
    );
    return Wrap(
      spacing: 24,
      runSpacing: 8,
      children: [
        item('Fiber', KitchenFormat.grams(facts.fiberG)),
        item('Sugars', KitchenFormat.grams(facts.sugarG)),
        item('Sodium', KitchenFormat.milligrams(facts.sodiumMg)),
      ],
    );
  }
}

/// Seven-day calorie columns with a goal reference line. Single series, so
/// no legend (the card title names it). Every column is a hit target with a
/// tooltip, semantics, and tap-to-open-day; the selected day is labeled.
/// A week of calories: one bar per day on its own track, a dashed goal line,
/// and above them the daily average and how many days stayed within the goal.
class WeeklyCaloriesChart extends StatelessWidget {
  final List<DailyNutritionSummary> summaries;
  final String endDayKey;
  final double goal;
  final String selectedDayKey;
  final ValueChanged<String>? onSelectDay;
  final double height;

  const WeeklyCaloriesChart({
    super.key,
    required this.summaries,
    required this.endDayKey,
    required this.goal,
    required this.selectedDayKey,
    this.onSelectDay,
    this.height = 170,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final t = context.chefText;
    final end = dateForDayKey(endDayKey);
    final days = [for (var i = 6; i >= 0; i--) end.subtract(Duration(days: i))];
    final byDay = {for (final s in summaries) s.dayKey: s.total.calories};
    final values = [for (final d in days) byDay[dayKeyFor(d)] ?? 0.0];
    final logged = values.where((v) => v > 0).toList();
    final maxValue = [goal, ...values].fold<double>(0, math.max);
    final scaleMax = maxValue <= 0 ? 1.0 : maxValue * 1.12;
    final weekday = DateFormat.E();
    final todayKey = dayKeyFor(DateTime.now());
    final average = logged.isEmpty ? 0.0 : logged.reduce((a, b) => a + b) / logged.length;
    final onGoal = goal <= 0 ? 0 : logged.where((v) => v <= goal).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (logged.isNotEmpty)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: KitchenFormat.kcal(average), style: t.titleLarge),
                      TextSpan(text: '  kcal a day on average', style: t.bodySmall),
                    ],
                  ),
                ),
              ),
              if (goal > 0) Text('$onGoal of ${logged.length} days within goal', style: t.bodySmall),
            ],
          ),
        const SizedBox(height: 14),
        SizedBox(
          height: height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              const labelBand = 22.0;
              const capBand = 18.0;
              final plotHeight = constraints.maxHeight - labelBand - capBand;
              final goalY = labelBand + plotHeight * (goal / scaleMax);
              return Stack(
                children: [
                  Positioned.fill(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final (i, day) in days.indexed)
                          Expanded(
                            child: _DayColumn(
                              dayKey: dayKeyFor(day),
                              label: weekday.format(day),
                              value: values[i],
                              fraction: values[i] / scaleMax,
                              plotHeight: plotHeight,
                              labelBand: labelBand,
                              selected: dayKeyFor(day) == selectedDayKey,
                              isToday: dayKeyFor(day) == todayKey,
                              onTap: onSelectDay,
                              fullDate: DateFormat.MMMEd().format(day),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Goal reference: dashed, above the bars, never catching taps.
                  if (goal > 0)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: goalY,
                      child: IgnorePointer(
                        child: CustomPaint(
                          size: const Size.fromHeight(1),
                          painter: _DashPainter(c.contentSecondary.withValues(alpha: 0.7)),
                        ),
                      ),
                    ),
                  if (goal > 0)
                    Positioned(
                      right: 0,
                      bottom: goalY + 3,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: c.surfacePaper.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text('Goal ${KitchenFormat.kcal(goal)}', style: t.labelSmall),
                          ),
                        ),
                      ),
                    ),
                  if (logged.isEmpty)
                    Positioned.fill(
                      bottom: labelBand,
                      child: IgnorePointer(
                        child: Center(
                          child: DecoratedBox(
                            decoration: BoxDecoration(color: c.surfacePaper, borderRadius: BorderRadius.circular(8)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              child: Text('Log a meal and your week fills in here', style: t.bodySmall),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DashPainter extends CustomPainter {
  final Color color;
  _DashPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 7) {
      canvas.drawLine(Offset(x, 0), Offset(math.min(x + 4, size.width), 0), p);
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}

class _DayColumn extends StatefulWidget {
  final String dayKey;
  final String label;
  final String fullDate;
  final double value;
  final double fraction;
  final double plotHeight;
  final double labelBand;
  final bool selected;
  final bool isToday;
  final ValueChanged<String>? onTap;

  const _DayColumn({
    required this.dayKey,
    required this.label,
    required this.fullDate,
    required this.value,
    required this.fraction,
    required this.plotHeight,
    required this.labelBand,
    required this.selected,
    required this.isToday,
    required this.onTap,
  });

  @override
  State<_DayColumn> createState() => _DayColumnState();
}

class _DayColumnState extends State<_DayColumn> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final t = context.chefText;
    final barHeight = (widget.plotHeight * widget.fraction.clamp(0.0, 1.0)).toDouble();
    final valueText = widget.value > 0 ? '${KitchenFormat.kcal(widget.value)} kcal' : 'Nothing logged';
    final barColor = _hover && !widget.selected ? Color.lerp(c.chartPrimary, c.surfacePaper, 0.18)! : c.chartPrimary;
    // Every day has a track, so an empty day still reads as a day.
    final track = widget.selected ? c.meterTrack(c.chartPrimary) : c.meterTrack(c.contentSecondary);

    return Semantics(
      button: widget.onTap != null,
      selected: widget.selected,
      label: '${widget.fullDate}: $valueText',
      excludeSemantics: true,
      child: Tooltip(
        message: '$valueText\n${widget.fullDate}',
        child: MouseRegion(
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: widget.onTap == null ? null : () => widget.onTap!(widget.dayKey),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 16,
                  child: widget.selected && widget.value > 0
                      ? FittedBox(
                          child: Text(
                            KitchenFormat.kcal(widget.value),
                            style: t.labelSmall?.copyWith(color: c.contentPrimary, fontWeight: FontWeight.w700),
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 2),
                SizedBox(
                  width: 24,
                  height: widget.plotHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: track, borderRadius: BorderRadius.circular(6)),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: barHeight > 0
                          ? AnimatedContainer(
                              duration: ChefMotion.standard,
                              curve: ChefMotion.easeStandard,
                              width: 24,
                              height: math.max(4, barHeight),
                              decoration: BoxDecoration(color: barColor, borderRadius: BorderRadius.circular(6)),
                            )
                          : null,
                    ),
                  ),
                ),
                SizedBox(
                  height: widget.labelBand,
                  child: Center(
                    child: Text(
                      widget.isToday ? 'Today' : widget.label,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      style: t.labelSmall?.copyWith(
                        color: widget.selected ? c.contentPrimary : c.contentSecondary,
                        fontWeight: widget.selected ? FontWeight.w800 : FontWeight.w500,
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
}
