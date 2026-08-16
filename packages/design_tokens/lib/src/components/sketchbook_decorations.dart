import 'package:flutter/material.dart';
import '../tokens/chef_spacing.dart';
import '../tokens/chef_theme.dart';

enum WashiTapePattern {
  terracotta,
  sage,
  kraft,
  dots,
  striped,
  strawberry,
  gingham,
  glitter,
  green,
  peach;

  static WashiTapePattern fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'sage':
        return WashiTapePattern.sage;
      case 'kraft':
        return WashiTapePattern.kraft;
      case 'dots':
        return WashiTapePattern.dots;
      case 'strawberry':
        return WashiTapePattern.strawberry;
      case 'gingham':
        return WashiTapePattern.gingham;
      case 'glitter':
        return WashiTapePattern.glitter;
      case 'green':
        return WashiTapePattern.green;
      case 'peach':
        return WashiTapePattern.peach;
      case 'striped':
        return WashiTapePattern.striped;
      case 'terracotta':
      default:
        return WashiTapePattern.terracotta;
    }
  }
}

/// A decorative washi tape strip to give cards an authentic scrapbook/journal feel
class WashiTape extends StatelessWidget {
  final double width;
  final double height;
  final double rotation;
  final Color? color;
  final WashiTapePattern pattern;

  const WashiTape({
    super.key,
    this.width = 64,
    this.height = 16,
    this.rotation = -0.05,
    this.color,
    this.pattern = WashiTapePattern.terracotta,
  });

  Color _getBaseColor(BuildContext context) {
    if (color != null) return color!;
    switch (pattern) {
      case WashiTapePattern.terracotta:
      case WashiTapePattern.strawberry:
        return const Color(0xFFC85A32).withValues(alpha: 0.75);
      case WashiTapePattern.sage:
      case WashiTapePattern.green:
        return const Color(0xFF4A6B53).withValues(alpha: 0.75);
      case WashiTapePattern.kraft:
        return const Color(0xFF8C7355).withValues(alpha: 0.75);
      case WashiTapePattern.dots:
        return const Color(0xFFD9822B).withValues(alpha: 0.75);
      case WashiTapePattern.gingham:
        return const Color(0xFFB24E29).withValues(alpha: 0.75);
      case WashiTapePattern.glitter:
        return const Color(0xFFE5A124).withValues(alpha: 0.8);
      case WashiTapePattern.peach:
        return const Color(0xFFE8927C).withValues(alpha: 0.75);
      case WashiTapePattern.striped:
        return const Color(0xFFC85A32).withValues(alpha: 0.7);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tapeColor = _getBaseColor(context);

    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: tapeColor,
          borderRadius: BorderRadius.circular(1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: CustomPaint(
          painter: _WashiTapePainter(pattern: pattern),
        ),
      ),
    );
  }
}

class _WashiTapePainter extends CustomPainter {
  final WashiTapePattern pattern;

  _WashiTapePainter({required this.pattern});

  @override
  void paint(Canvas canvas, Size size) {
    final whiteSubtle = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 2.0;

    if (pattern == WashiTapePattern.striped || pattern == WashiTapePattern.terracotta) {
      for (double i = -size.height; i < size.width + size.height; i += 7) {
        canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), whiteSubtle);
      }
    } else if (pattern == WashiTapePattern.dots) {
      final dotPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..style = PaintingStyle.fill;
      for (double x = 4; x < size.width; x += 6) {
        for (double y = 4; y < size.height; y += 6) {
          canvas.drawCircle(Offset(x, y), 1.0, dotPaint);
        }
      }
    } else if (pattern == WashiTapePattern.gingham) {
      final gridPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..strokeWidth = 1.5;
      for (double x = 4; x < size.width; x += 6) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      }
      for (double y = 3; y < size.height; y += 5) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      }
    } else if (pattern == WashiTapePattern.glitter) {
      final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.6);
      for (double x = 5; x < size.width; x += 8) {
        canvas.drawCircle(Offset(x, size.height / 2), 1.2, starPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WashiTapePainter oldDelegate) => false;
}

/// Dynamic Custom Ink Badge with oval, box, or ribbon borders
class DynamicCustomInkBadge extends StatelessWidget {
  final String text;
  final String shape; // 'oval' | 'box' | 'ribbon'
  final Color color;
  final Color bgColor;
  final double rotation;

  const DynamicCustomInkBadge({
    super.key,
    required this.text,
    this.shape = 'oval',
    this.color = const Color(0xFFC85A32),
    this.bgColor = const Color(0xFFFBF0EB),
    this.rotation = -0.04,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = shape == 'box'
        ? BorderRadius.circular(3)
        : shape == 'ribbon'
            ? BorderRadius.circular(16)
            : BorderRadius.circular(30);

    return Transform.rotate(
      angle: rotation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: borderRadius,
          border: Border.all(
            color: color,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.12),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_outlined, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              text.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A stamp with dashed/scalloped border representing chef annotations
class DoodleStamp extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final double rotation;

  const DoodleStamp({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.rotation = -0.04,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.chefColors;
    final stampColor = color ?? colors.accentHerb;

    return Transform.rotate(
      angle: rotation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: ChefSpacing.space3, vertical: 4),
        decoration: BoxDecoration(
          color: stampColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(ChefRadius.pill),
          border: Border.all(
            color: stampColor.withValues(alpha: 0.8),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignCenter,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: stampColor),
              const SizedBox(width: 4),
            ],
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: stampColor,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// An interactive ingredient sticker with tactile pop-in animation and checkoff state
class SketchbookIngredientBadge extends StatefulWidget {
  final String name;
  final String? quantityDisplay;
  final IconData icon;
  final bool isChecked;
  final ValueChanged<bool>? onToggle;
  final Color? accentColor;

  const SketchbookIngredientBadge({
    super.key,
    required this.name,
    this.quantityDisplay,
    this.icon = Icons.eco_outlined,
    this.isChecked = false,
    this.onToggle,
    this.accentColor,
  });

  @override
  State<SketchbookIngredientBadge> createState() => _SketchbookIngredientBadgeState();
}

class _SketchbookIngredientBadgeState extends State<SketchbookIngredientBadge> with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.chefColors;
    final accent = widget.accentColor ?? colors.accentTomato;

    return GestureDetector(
      onTapDown: (_) => _anim.forward(),
      onTapUp: (_) {
        _anim.reverse();
        if (widget.onToggle != null) {
          widget.onToggle!(!widget.isChecked);
        }
      },
      onTapCancel: () => _anim.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: ChefSpacing.space3, vertical: ChefSpacing.space2),
          decoration: BoxDecoration(
            color: widget.isChecked
                ? colors.surfaceRaised.withValues(alpha: 0.6)
                : colors.surfacePaper,
            borderRadius: BorderRadius.circular(ChefRadius.card),
            border: Border.all(
              color: widget.isChecked
                  ? colors.contentSecondary.withValues(alpha: 0.3)
                  : accent.withValues(alpha: 0.4),
              width: widget.isChecked ? 1 : 1.5,
            ),
            boxShadow: widget.isChecked
                ? null
                : [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: widget.isChecked
                      ? colors.surfaceRaised
                      : accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.isChecked ? Icons.check : widget.icon,
                  size: 14,
                  color: widget.isChecked ? colors.contentSecondary : accent,
                ),
              ),
              const SizedBox(width: ChefSpacing.space2),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: widget.isChecked ? colors.contentSecondary : colors.contentPrimary,
                      decoration: widget.isChecked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (widget.quantityDisplay != null && widget.quantityDisplay!.isNotEmpty)
                    Text(
                      widget.quantityDisplay!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: widget.isChecked ? colors.contentSecondary : accent,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Brand logo badge displaying the hand-drawn Chef's Kiss toque and garland
class ChefBrandBadge extends StatelessWidget {
  final double size;
  final bool showTitle;

  const ChefBrandBadge({
    super.key,
    this.size = 36,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.chefColors;
    final textTheme = context.chefText;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.surfacePaper,
            border: Border.all(color: colors.accentTomato.withValues(alpha: 0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: colors.accentTomato.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            'assets/illustrations/app_logo_chef_kiss.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(Icons.restaurant_menu, size: size * 0.6, color: colors.accentTomato),
          ),
        ),
        if (showTitle) ...[
          const SizedBox(width: ChefSpacing.space2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Chef's Kiss",
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Illustrated Recipe Journal',
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: colors.contentSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
