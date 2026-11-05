import 'dart:math' as math;

import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:recipe_domain/recipe_domain.dart';

/// Ink colours shared by stickers, badges and ingredient icons.
const inkPalette = <({String name, Color ink, Color paper})>[
  (name: 'Terracotta', ink: Color(0xFFC85A32), paper: Color(0xFFFBF0EB)),
  (name: 'Sage', ink: Color(0xFF4A6B53), paper: Color(0xFFEEF4F0)),
  (name: 'Honey', ink: Color(0xFFD9822B), paper: Color(0xFFFEF8EB)),
  (name: 'Kraft', ink: Color(0xFF8C7355), paper: Color(0xFFF5EFEB)),
  (name: 'Charcoal', ink: Color(0xFF2C2623), paper: Color(0xFFF6F2EB)),
  (name: 'Merlot', ink: Color(0xFF8C2D3A), paper: Color(0xFFFBEFF1)),
  (name: 'Slate', ink: Color(0xFF4F6D7A), paper: Color(0xFFEEF3F5)),
];

Color? parseHexColor(String? hex) {
  if (hex == null) return null;
  var h = hex.trim().replaceFirst('#', '');
  if (h.length == 6) h = 'FF$h';
  if (h.length != 8) return null;
  final v = int.tryParse(h, radix: 16);
  return v == null ? null : Color(v);
}

String toHexColor(Color c) => '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

double degToRad(double deg) => deg * math.pi / 180;

/// The on-page footprint of a sticker before rotation, for a page [pageWidth]
/// wide. Square for stamps and doodles, wide for ink badges.
Size stickerBoxSize(ScrapbookSticker s, double pageWidth) {
  final base = stickerBaseSize(pageWidth) * s.scale.clamp(0.35, 3.0);
  return s.type == 'badge' ? Size(base * 2.2, base * 0.62) : Size.square(base);
}

/// Stickers scale with the page so a layout looks the same on a phone and a
/// tablet.
double stickerBaseSize(double pageWidth) => (pageWidth * 0.17).clamp(52.0, 96.0);

/// Washi tape widths are stored in "reference pixels" for a 400px-wide page.
double tapeScaleFor(double pageWidth) => (pageWidth / 400).clamp(0.7, 1.6);

Size tapeBoxSize(WashiTapeDecoration t, double pageWidth) {
  final k = tapeScaleFor(pageWidth);
  return Size((t.width * k).clamp(36.0, pageWidth * 0.9), 18 * k);
}

/// Draws a sticker's artwork filling [size] (unrotated).
class StickerArt extends StatelessWidget {
  final ScrapbookSticker sticker;
  final Size size;
  const StickerArt({super.key, required this.sticker, required this.size});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final s = sticker;
    final ink = parseHexColor(s.color) ?? c.accentTomato;
    final Widget art;
    switch (s.type) {
      case 'badge':
        var text = (s.label?.trim().isNotEmpty ?? false) ? s.label!.trim() : s.content;
        var shape = 'oval';
        if (s.content.startsWith('custom-ink:')) {
          final parts = s.content.split(':');
          shape = parts.length > 1 ? parts[1] : 'oval';
          if (parts.length > 2) text = parts.sublist(2).join(':');
        }
        art = FittedBox(
          fit: BoxFit.contain,
          child: DynamicCustomInkBadge(
            text: text,
            shape: shape,
            color: ink,
            bgColor: parseHexColor(s.bgColor) ?? Color.alphaBlend(ink.withValues(alpha: 0.08), Colors.white),
            rotation: 0,
          ),
        );
      case 'icon':
        art = DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: parseHexColor(s.bgColor) ?? Color.alphaBlend(ink.withValues(alpha: 0.1), Colors.white),
            border: Border.all(color: ink, width: math.max(1.5, size.width * 0.035)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 4, offset: const Offset(0, 2)),
            ],
          ),
          child: Center(
            child: Icon(getCulinaryIconData(s.content), color: ink, size: size.width * 0.52),
          ),
        );
      case 'emoji':
        art = FittedBox(child: Text(s.content, style: const TextStyle(fontSize: 64)));
      default:
        final id = s.content.isNotEmpty ? s.content : (s.iconId ?? '');
        art = FittedBox(
          fit: BoxFit.contain,
          child: renderCulinaryStampById(id, size: 96, rotation: 0) ?? const SizedBox.square(dimension: 96),
        );
    }
    return SizedBox.fromSize(size: size, child: art);
  }
}

class TapeArt extends StatelessWidget {
  final WashiTapeDecoration tape;
  final Size size;
  const TapeArt({super.key, required this.tape, required this.size});

  @override
  Widget build(BuildContext context) => WashiTape(
    width: size.width,
    height: size.height,
    rotation: 0,
    pattern: WashiTapePattern.fromString(tape.pattern),
  );
}
