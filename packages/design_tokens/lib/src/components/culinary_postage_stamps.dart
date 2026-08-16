// GENERATED PIXEL-PERFECT VINTAGE POSTAGE STAMPS
// 100% exact parity with Next.js CulinaryPostageStamps.tsx

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CulinaryStampDef {
  final String id;
  final String name;
  final String category;
  final double defaultRotation;
  final Widget Function({double size, double rotation}) builder;

  const CulinaryStampDef({
    required this.id,
    required this.name,
    required this.category,
    required this.defaultRotation,
    required this.builder,
  });
}

class SvgPostageStampWidget extends StatelessWidget {
  final String id;
  final double size;
  final double rotation;

  const SvgPostageStampWidget({
    super.key,
    required this.id,
    this.size = 72,
    this.rotation = 0,
  });

  @override
  Widget build(BuildContext context) {
    final rawSvg = rawPostageStampSvgMap[id] ?? rawPostageStampSvgMap['postage-tomato'] ?? rawPostageStampSvgMap.values.first;
    final meta = _stampMetadata[id] ?? const ('SPECIAL EDITION', '50¢', 'CHEF', Color(0xFFC85A32));

    final w = size;
    final h = size * 1.2;

    return Transform.rotate(
      angle: rotation * (math.pi / 180),
      child: SizedBox(
        width: w,
        height: h,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.string(
              rawSvg,
              width: w,
              height: h,
              fit: BoxFit.contain,
            ),
            // Crisp Top Banner Title
            Positioned(
              top: h * 0.14,
              left: w * 0.12,
              right: w * 0.12,
              child: Text(
                meta.$1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: meta.$4,
                  fontSize: size * 0.082,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  height: 1.0,
                ),
              ),
            ),
            // Crisp Bottom Left Denomination Price
            Positioned(
              bottom: h * 0.11,
              left: w * 0.16,
              child: Text(
                meta.$2,
                style: TextStyle(
                  color: const Color(0xFF1E1A18),
                  fontSize: size * 0.10,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'serif',
                  height: 1.0,
                ),
              ),
            ),
            // Crisp Bottom Right Origin Label
            Positioned(
              bottom: h * 0.12,
              right: w * 0.16,
              child: Text(
                meta.$3,
                style: TextStyle(
                  color: meta.$4,
                  fontSize: size * 0.075,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  height: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const Map<String, (String, String, String, Color)> _stampMetadata = {
  'postage-tomato': ('SAN MARZANO', '50¢', 'ITALIA', Color(0xFFC85A32)),
  'postage-basil': ('FRESH BASIL', '25¢', 'HERBIER', Color(0xFF4A6B53)),
  'postage-pizza': ('NAPOLETANA', '80¢', 'NAPOLI', Color(0xFFC85A32)),
  'postage-strawberry': ('FRAGOLE', '45¢', 'GIARDINO', Color(0xFFD94B58)),
  'postage-sushi': ('EDOMAE SUSHI', '¥120', 'TOKYO', Color(0xFF2C2623)),
  'postage-taco': ('CALLEJERO', '15¢', 'MEXICO', Color(0xFFD9822B)),
  'postage-baguette': ('FOURNIL', '€1.20', 'FRANCE', Color(0xFF8C7355)),
  'postage-ramen': ('RAMEN-YA', '¥850', 'KYOTO', Color(0xFF2C2623)),
  'postage-cheese': ('PARMIGIANO', '€2.50', 'REGGIANO', Color(0xFFD9822B)),
  'postage-croissant': ('CROISSANT', '€1.50', 'PARIS', Color(0xFF8C7355)),
  'postage-egg': ('FERMIER', '30¢', 'CAMPAGNE', Color(0xFFD9822B)),
  'postage-berry': ('MYRTILLES', '60¢', 'FOREST', Color(0xFF4B306B)),
  'postage-garlic': ('AIL ROSE', '20¢', 'PROVENCE', Color(0xFF4A6B53)),
  'postage-espresso': ('ESPRESSO', '€1.00', 'ROMA', Color(0xFF5C3A21)),
  'postage-avocado': ('AGUACATE', '75¢', 'ORGANIC', Color(0xFF4A6B53)),
  'postage-honey': ('WILDFLOWER', '90¢', 'APIARY', Color(0xFFD9822B)),
  'postage-parmigiano': ('STAGIONATO', '€3.00', 'DOP', Color(0xFF8C7355)),
  'postage-lemon': ('LIMONE', '35¢', 'SORRENTO', Color(0xFFD9822B)),
  'postage-whisk': ('PATISSERIE', '50¢', 'ATELIER', Color(0xFF4A6B53)),
};

final List<CulinaryStampDef> postageStampDefs = [
  CulinaryStampDef(
    id: 'postage-tomato',
    name: 'San Marzano Tomato',
    category: 'postage',
    defaultRotation: -4,
    builder: ({double size = 72, double rotation = -4}) => SvgPostageStampWidget(id: 'postage-tomato', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'postage-basil',
    name: 'Fresh Genovese Basil',
    category: 'postage',
    defaultRotation: 3,
    builder: ({double size = 72, double rotation = 3}) => SvgPostageStampWidget(id: 'postage-basil', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'postage-pizza',
    name: 'Pizza Napoletana',
    category: 'postage',
    defaultRotation: 4,
    builder: ({double size = 72, double rotation = 4}) => SvgPostageStampWidget(id: 'postage-pizza', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'postage-strawberry',
    name: 'Wild Strawberries',
    category: 'postage',
    defaultRotation: -4,
    builder: ({double size = 72, double rotation = -4}) => SvgPostageStampWidget(id: 'postage-strawberry', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'postage-sushi',
    name: 'Edomae Salmon Nigiri',
    category: 'postage',
    defaultRotation: 3,
    builder: ({double size = 72, double rotation = 3}) => SvgPostageStampWidget(id: 'postage-sushi', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'postage-taco',
    name: 'Street Taco Callejero',
    category: 'postage',
    defaultRotation: -4,
    builder: ({double size = 72, double rotation = -4}) => SvgPostageStampWidget(id: 'postage-taco', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'postage-baguette',
    name: 'Fournil Baguette',
    category: 'postage',
    defaultRotation: 4,
    builder: ({double size = 72, double rotation = 4}) => SvgPostageStampWidget(id: 'postage-baguette', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'postage-croissant',
    name: 'Pâtisserie Croissant',
    category: 'postage',
    defaultRotation: -5,
    builder: ({double size = 72, double rotation = -5}) => SvgPostageStampWidget(id: 'postage-croissant', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'postage-cheese',
    name: 'Parmigiano Reggiano',
    category: 'postage',
    defaultRotation: -4,
    builder: ({double size = 72, double rotation = -4}) => SvgPostageStampWidget(id: 'postage-cheese', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'postage-oliveoil',
    name: 'Extra Virgin Olive Oil',
    category: 'postage',
    defaultRotation: -3,
    builder: ({double size = 72, double rotation = -3}) => SvgPostageStampWidget(id: 'postage-oliveoil', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'postage-wine',
    name: 'Bordeaux Grand Cru',
    category: 'postage',
    defaultRotation: 4,
    builder: ({double size = 72, double rotation = 4}) => SvgPostageStampWidget(id: 'postage-wine', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'postage-chili',
    name: 'Peperoncino Chili',
    category: 'postage',
    defaultRotation: 4,
    builder: ({double size = 72, double rotation = 4}) => SvgPostageStampWidget(id: 'postage-chili', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'postage-mushroom',
    name: 'Boletus Wild Porcini',
    category: 'postage',
    defaultRotation: -4,
    builder: ({double size = 72, double rotation = -4}) => SvgPostageStampWidget(id: 'postage-mushroom', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'postage-lemon',
    name: 'Meyer Lemon Harvest',
    category: 'postage',
    defaultRotation: 4,
    builder: ({double size = 72, double rotation = 4}) => SvgPostageStampWidget(id: 'postage-lemon', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'postage-skillet',
    name: 'Cast Iron Skillet',
    category: 'postage',
    defaultRotation: -3,
    builder: ({double size = 72, double rotation = -3}) => SvgPostageStampWidget(id: 'postage-skillet', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'postage-ramen',
    name: 'Tokyo Craft Ramen',
    category: 'postage',
    defaultRotation: 4,
    builder: ({double size = 72, double rotation = 4}) => SvgPostageStampWidget(id: 'postage-ramen', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'postage-avocado',
    name: 'Hass Avocado Harvest',
    category: 'postage',
    defaultRotation: -4,
    builder: ({double size = 72, double rotation = -4}) => SvgPostageStampWidget(id: 'postage-avocado', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'postage-espresso',
    name: 'Crema Espresso Roast',
    category: 'postage',
    defaultRotation: 3,
    builder: ({double size = 72, double rotation = 3}) => SvgPostageStampWidget(id: 'postage-espresso', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'postage-honey',
    name: 'Raw Wildflower Honey',
    category: 'postage',
    defaultRotation: -4,
    builder: ({double size = 72, double rotation = -4}) => SvgPostageStampWidget(id: 'postage-honey', size: size, rotation: rotation),
  ),
];

final Map<String, String> rawPostageStampSvgMap = {
  'postage-tomato': r'''<svg viewBox="0 0 100 120" fill="none" xmlns="http://www.w3.org/2000/svg">

    <rect x="4" y="4" width="92" height="112" rx="4" fill="#FCFAF7" stroke="#1E1A18" stroke-width="2" stroke-dasharray="3 3" />
    <rect x="10" y="10" width="80" height="100" fill="#FBF0EB" stroke="#C85A32" stroke-width="1.5" />
    <text x="50" y="22" text-anchor="middle" fill="#C85A32" font-size="7" font-weight="900" font-family="sans-serif" letter-spacing="1">SAN MARZANO</text>
    <line x1="16" y1="26" x2="84" y2="26" stroke="#C85A32" stroke-width="0.75" stroke-dasharray="2 1" />
    <g transform="translate(18, 28)">
      
      <path d="M 10 20 L 12 16 L 14 20 L 18 22 L 14 24 L 12 28 L 10 24 L 6 22 Z" fill="#F4BA42" opacity="0.6" />
      <path d="M 52 40 L 53 38 L 54 40 L 56 41 L 54 42 L 53 44 L 52 42 L 50 41 Z" fill="#F4BA42" opacity="0.6" />
      
      <path d="M32 54C48 54 56 42 56 30C56 16 44 14 32 14C20 14 8 16 8 30C8 42 16 54 32 54Z" fill="#E64A33" stroke="#A82E1C" stroke-width="1.5" />
      
      <path d="M 18 28 C 16 34 18 42 22 48" stroke="#FF8A8A" stroke-width="2" stroke-linecap="round" opacity="0.6" fill="none" />
      <ellipse cx="22" cy="22" rx="4" ry="2" transform="rotate(-30 22 22)" fill="#FFF" opacity="0.5" />
      
      <path d="M32 14C32 8 34 3 36 2" stroke="#4A6B53" stroke-width="2.5" stroke-linecap="round" />
      <path d="M32 14L22 9M32 14L42 9M32 14L26 18M32 14L38 18" stroke="#4A6B53" stroke-width="2.5" stroke-linecap="round" />
      <path d="M22 9 Q 28 12 32 14" fill="#587E62" />
      <path d="M42 9 Q 36 12 32 14" fill="#587E62" />
      
      <circle cx="26" cy="34" r="2.5" fill="#1E1A18" />
      <circle cx="26.5" cy="33" r="1" fill="#FFF" />
      <circle cx="38" cy="34" r="2.5" fill="#1E1A18" />
      <circle cx="38.5" cy="33" r="1" fill="#FFF" />
      <path d="M 29.5 35 Q 32 38 34.5 35" stroke="#1E1A18" stroke-width="1.5" fill="none" stroke-linecap="round" />
      <path d="M 31 36.5 Q 32 37.5 33 36.5 Z" fill="#FF8A8A" /> 
      <ellipse cx="22" cy="36" rx="3" ry="1.5" fill="#FFCDB2" opacity="0.8" />
      <ellipse cx="42" cy="36" rx="3" ry="1.5" fill="#FFCDB2" opacity="0.8" />
    </g>
    <text x="20" y="102" fill="#1E1A18" font-size="9" font-weight="900" font-family="serif">50&#162;</text>
    <text x="80" y="102" text-anchor="end" fill="#8C7355" font-size="6" font-weight="bold" font-family="sans-serif">ITALIA</text>
  
</svg>''',
  'postage-basil': r'''<svg viewBox="0 0 100 120" fill="none" xmlns="http://www.w3.org/2000/svg">

    <rect x="4" y="4" width="92" height="112" rx="4" fill="#FCFAF7" stroke="#1E1A18" stroke-width="2" stroke-dasharray="3 3" />
    <rect x="10" y="10" width="80" height="100" fill="#EEF4F0" stroke="#4A6B53" stroke-width="1.5" />
    <text x="50" y="22" text-anchor="middle" fill="#4A6B53" font-size="7" font-weight="900" font-family="sans-serif" letter-spacing="1">FRESH BASIL</text>
    <line x1="16" y1="26" x2="84" y2="26" stroke="#4A6B53" stroke-width="0.75" stroke-dasharray="2 1" />
    <g transform="translate(20, 26)">
      
      <circle cx="12" cy="18" r="1.5" fill="#75A87B" opacity="0.6" />
      <circle cx="48" cy="42" r="2" fill="#75A87B" opacity="0.6" />
      
      <path d="M30 54C30 35 30 18 30 8" stroke="#3D5A45" stroke-width="2.5" stroke-linecap="round" />
      
      <g>
        <path d="M30 30C16 28 8 40 24 48C30 44 30 34 30 30Z" fill="#587E62" stroke="#3D5A45" stroke-width="1.5" stroke-linejoin="round" />
        <path d="M30 30 C 24 38 18 42 16 42" stroke="#3D5A45" stroke-width="1" opacity="0.6" fill="none" />
      </g>
      <g>
        <path d="M30 30C44 28 52 40 36 48C30 44 30 34 30 30Z" fill="#587E62" stroke="#3D5A45" stroke-width="1.5" stroke-linejoin="round" />
        <path d="M30 30 C 36 38 42 42 44 42" stroke="#3D5A45" stroke-width="1" opacity="0.6" fill="none" />
      </g>
      <g>
        <path d="M30 8C18 12 16 24 30 32C44 24 42 12 30 8Z" fill="#75A87B" stroke="#3D5A45" stroke-width="1.5" stroke-linejoin="round" />
        
        <path d="M30 8 C 30 16 30 24 30 32" stroke="#3D5A45" stroke-width="1" opacity="0.5" fill="none" />
        <path d="M30 16 L 24 14 M30 20 L 22 18 M30 24 L 24 24" stroke="#3D5A45" stroke-width="1" opacity="0.4" stroke-linecap="round" />
        <path d="M30 16 L 36 14 M30 20 L 38 18 M30 24 L 36 24" stroke="#3D5A45" stroke-width="1" opacity="0.4" stroke-linecap="round" />
      </g>
      
      <ellipse cx="24" cy="18" rx="2" ry="3" transform="rotate(45 24 18)" fill="#FFF" opacity="0.6" />
      
      <circle cx="26" cy="22" r="1.5" fill="#1E1A18" />
      <circle cx="34" cy="22" r="1.5" fill="#1E1A18" />
      <path d="M 28.5 23 Q 30 26 31.5 23" stroke="#1E1A18" stroke-width="1.2" fill="none" stroke-linecap="round" />
      <ellipse cx="23.5" cy="23.5" rx="2" ry="1" fill="#FFCDB2" opacity="0.8" />
      <ellipse cx="36.5" cy="23.5" rx="2" ry="1" fill="#FFCDB2" opacity="0.8" />
    </g>
    <text x="20" y="102" fill="#1E1A18" font-size="9" font-weight="900" font-family="serif">25&#162;</text>
    <text x="80" y="102" text-anchor="end" fill="#4A6B53" font-size="6" font-weight="bold" font-family="sans-serif">HERBIER</text>
  
</svg>''',
  'postage-pizza': r'''<svg viewBox="0 0 100 120" fill="none" xmlns="http://www.w3.org/2000/svg">

    <rect x="4" y="4" width="92" height="112" rx="4" fill="#FCFAF7" stroke="#1E1A18" stroke-width="2" stroke-dasharray="3 3" />
    <rect x="10" y="10" width="80" height="100" fill="#FBF0EB" stroke="#C85A32" stroke-width="1.5" />
    <text x="50" y="22" text-anchor="middle" fill="#C85A32" font-size="7" font-weight="900" font-family="sans-serif" letter-spacing="1">NAPOLETANA</text>
    <line x1="16" y1="26" x2="84" y2="26" stroke="#C85A32" stroke-width="0.75" stroke-dasharray="2 1" />
    <g transform="translate(14, 28)">
      
      <circle cx="36" cy="34" r="24" fill="#1E1A18" opacity="0.1" />
      
      <circle cx="36" cy="32" r="24" fill="#F4BA42" stroke="#B86A1D" stroke-width="2" />
      <circle cx="20" cy="20" r="2" fill="#D99726" opacity="0.5" />
      <circle cx="48" cy="14" r="1.5" fill="#D99726" opacity="0.5" />
      <circle cx="54" cy="40" r="2.5" fill="#D99726" opacity="0.5" />
      
      <circle cx="36" cy="32" r="20" fill="#C8281E" />
      
      <path d="M 28 22 C 34 20 38 24 34 28 C 30 30 26 26 28 22 Z" fill="#FFFDF8" />
      <path d="M 42 26 C 48 24 50 30 46 32 C 40 34 38 28 42 26 Z" fill="#FFFDF8" />
      <path d="M 32 40 C 38 38 42 42 38 46 C 32 48 28 44 32 40 Z" fill="#FFFDF8" />
      <path d="M 22 34 C 26 32 28 36 26 38 C 22 40 18 36 22 34 Z" fill="#FFFDF8" />
      
      <circle cx="46" cy="38" r="3" fill="#A82E1C" />
      <circle cx="28" cy="44" r="2.5" fill="#A82E1C" />
      <circle cx="22" cy="26" r="3" fill="#A82E1C" />
      <path d="M 36 18 Q 40 16 42 20 Q 38 22 36 18 Z" fill="#4A6B53" />
      <path d="M 22 40 Q 26 42 24 46 Q 20 44 22 40 Z" fill="#4A6B53" />
      
      <circle cx="36" cy="32" r="6" fill="#FFFDF8" />
      <circle cx="34" cy="32" r="1.5" fill="#1E1A18" />
      <circle cx="38" cy="32" r="1.5" fill="#1E1A18" />
      <path d="M 35 33.5 Q 36 35 37 33.5" stroke="#1E1A18" stroke-width="1" fill="none" stroke-linecap="round" />
      <ellipse cx="32" cy="34" rx="1.5" ry="1" fill="#FFCDB2" opacity="0.9" />
      <ellipse cx="40" cy="34" rx="1.5" ry="1" fill="#FFCDB2" opacity="0.9" />
    </g>
    <text x="20" y="102" fill="#1E1A18" font-size="9" font-weight="900" font-family="serif">65&#162;</text>
    <text x="80" y="102" text-anchor="end" fill="#C85A32" font-size="6" font-weight="bold" font-family="sans-serif">FORNO</text>
  
</svg>''',
  'postage-strawberry': r'''<svg viewBox="0 0 100 120" fill="none" xmlns="http://www.w3.org/2000/svg">

    <rect x="4" y="4" width="92" height="112" rx="4" fill="#FCFAF7" stroke="#1E1A18" stroke-width="2" stroke-dasharray="3 3" />
    <rect x="10" y="10" width="80" height="100" fill="#FBEFF1" stroke="#8C2D3A" stroke-width="1.5" />
    <text x="50" y="22" text-anchor="middle" fill="#8C2D3A" font-size="7" font-weight="900" font-family="sans-serif" letter-spacing="1">FRAISE DES BOIS</text>
    <line x1="16" y1="26" x2="84" y2="26" stroke="#8C2D3A" stroke-width="0.75" stroke-dasharray="2 1" />
    <g transform="translate(18, 28)">
      
      <path d="M32 52C22 46 16 36 16 26C16 18 24 16 32 20C40 16 48 18 48 26C48 36 42 46 32 52Z" fill="#E83A30" stroke="#8C1810" stroke-width="1.5" stroke-linejoin="round" />
      
      <path d="M 20 28 C 18 36 22 44 28 48" stroke="#FF8A8A" stroke-width="2" stroke-linecap="round" opacity="0.5" fill="none" />
      
      <g fill="#F4BA42">
        <ellipse cx="24" cy="26" rx="0.8" ry="1.2" />
        <ellipse cx="40" cy="26" rx="0.8" ry="1.2" />
        <ellipse cx="20" cy="34" rx="0.8" ry="1.2" />
        <ellipse cx="44" cy="34" rx="0.8" ry="1.2" />
        <ellipse cx="26" cy="42" rx="0.8" ry="1.2" />
        <ellipse cx="38" cy="42" rx="0.8" ry="1.2" />
        <ellipse cx="32" cy="48" rx="0.8" ry="1.2" />
        <ellipse cx="32" cy="26" rx="0.8" ry="1.2" />
      </g>
      
      <path d="M32 20L26 12M32 20L38 12M32 20L32 10" stroke="#4A6B53" stroke-width="2.5" stroke-linecap="round" />
      <path d="M22 18C26 22 38 22 42 18 C 38 16 26 16 22 18 Z" fill="#4A6B53" stroke="#2D4233" stroke-width="1" />
      <path d="M 32 16 Q 28 10 24 12 Z" fill="#587E62" />
      <path d="M 32 16 Q 36 10 40 12 Z" fill="#587E62" />
      
      <circle cx="27" cy="35" r="2" fill="#1E1A18" />
      <circle cx="27.5" cy="34" r="0.8" fill="#FFF" />
      <circle cx="37" cy="35" r="2" fill="#1E1A18" />
      <circle cx="37.5" cy="34" r="0.8" fill="#FFF" />
      <path d="M 30.5 36.5 Q 32 38.5 33.5 36.5" stroke="#1E1A18" stroke-width="1.2" fill="none" stroke-linecap="round" />
      <ellipse cx="23.5" cy="37" rx="2" ry="1.5" fill="#FFCDB2" opacity="0.8" />
      <ellipse cx="40.5" cy="37" rx="2" ry="1.5" fill="#FFCDB2" opacity="0.8" />
    </g>
    <text x="20" y="102" fill="#1E1A18" font-size="9" font-weight="900" font-family="serif">40&#162;</text>
    <text x="80" y="102" text-anchor="end" fill="#8C2D3A" font-size="6" font-weight="bold" font-family="sans-serif">JARDIN</text>
  
</svg>''',
  'postage-sushi': r'''<svg viewBox="0 0 100 120" fill="none" xmlns="http://www.w3.org/2000/svg">

    <rect x="4" y="4" width="92" height="112" rx="4" fill="#FCFAF7" stroke="#1E1A18" stroke-width="2" stroke-dasharray="3 3" />
    <rect x="10" y="10" width="80" height="100" fill="#F5EFEB" stroke="#1E1A18" stroke-width="1.5" />
    <text x="50" y="22" text-anchor="middle" fill="#1E1A18" font-size="7" font-weight="900" font-family="sans-serif" letter-spacing="1">EDOMAE NIGIRI</text>
    <line x1="16" y1="26" x2="84" y2="26" stroke="#1E1A18" stroke-width="0.75" stroke-dasharray="2 1" />
    <g transform="translate(18, 30)">
      
      <ellipse cx="32" cy="46" rx="22" ry="4" fill="#1E1A18" opacity="0.1" />
      
      <rect x="10" y="24" width="44" height="22" rx="10" fill="#FFFDF9" stroke="#DFD5C4" stroke-width="1.5" />
      <path d="M 14 30 Q 16 32 14 34 M 16 40 Q 18 38 20 42 M 46 30 Q 44 32 46 34" stroke="#DFD5C4" stroke-width="1" fill="none" opacity="0.5" stroke-linecap="round" />
      
      <path d="M8 24C8 16 22 12 32 12C42 12 56 16 56 24C56 28 42 32 32 32C22 32 8 28 8 24Z" fill="#FF8C61" stroke="#D95A2B" stroke-width="1.2" />
      
      <path d="M 12 24 Q 24 20 36 28" stroke="#FFF" stroke-width="1.5" fill="none" opacity="0.7" stroke-linecap="round" />
      <path d="M 16 20 Q 28 16 44 24" stroke="#FFF" stroke-width="1.5" fill="none" opacity="0.7" stroke-linecap="round" />
      <path d="M 26 16 Q 38 14 52 20" stroke="#FFF" stroke-width="1.5" fill="none" opacity="0.7" stroke-linecap="round" />
      
      <rect x="36" y="14" width="10" height="32" rx="2" fill="#2E2825" />
      <line x1="38" y1="16" x2="38" y2="44" stroke="#1E1A18" stroke-width="1" />
      
      <ellipse cx="20" cy="18" rx="4" ry="2" fill="#FFF" opacity="0.4" transform="rotate(-15 20 18)" />
      
      <circle cx="20" cy="35" r="2" fill="#1E1A18" />
      <circle cx="30" cy="35" r="2" fill="#1E1A18" />
      <path d="M 23 37 Q 25 39 27 37" stroke="#1E1A18" stroke-width="1.2" fill="none" stroke-linecap="round" />
      <ellipse cx="16" cy="37" rx="2" ry="1.5" fill="#FF8A8A" opacity="0.6" />
      <ellipse cx="34" cy="37" rx="2" ry="1.5" fill="#FF8A8A" opacity="0.6" />
    </g>
    <text x="20" y="102" fill="#1E1A18" font-size="9" font-weight="900" font-family="serif">85&#162;</text>
    <text x="80" y="102" text-anchor="end" fill="#1E1A18" font-size="6" font-weight="bold" font-family="sans-serif">GINZA</text>
  
</svg>''',
  'postage-taco': r'''<svg viewBox="0 0 100 120" fill="none" xmlns="http://www.w3.org/2000/svg">

    <rect x="4" y="4" width="92" height="112" rx="4" fill="#FCFAF7" stroke="#1E1A18" stroke-width="2" stroke-dasharray="3 3" />
    <rect x="10" y="10" width="80" height="100" fill="#FEF8EB" stroke="#D9822B" stroke-width="1.5" />
    <text x="50" y="22" text-anchor="middle" fill="#D9822B" font-size="7" font-weight="900" font-family="sans-serif" letter-spacing="1">TACO CALLEJERO</text>
    <line x1="16" y1="26" x2="84" y2="26" stroke="#D9822B" stroke-width="0.75" stroke-dasharray="2 1" />
    <g transform="translate(18, 30)">
      
      <path d="M 20 16 C 30 14 42 18 48 30 C 50 36 48 42 40 44" fill="#E8B042" />
      
      <path d="M 18 20 Q 24 14 30 18 T 42 18 T 50 26 T 48 36" fill="#75A87B" stroke="#4A6B53" stroke-width="1" stroke-linejoin="round" /> 
      <path d="M 16 38 C 16 26 26 18 36 18 C 44 18 50 24 52 32" fill="none" stroke="#6F361E" stroke-width="6" stroke-linecap="round" /> 
      
      <path d="M 24 18 L 26 22 M 32 16 L 34 20 M 40 18 L 38 22 M 46 24 L 44 26" stroke="#F4BA42" stroke-width="1.5" stroke-linecap="round" />
      
      <circle cx="24" cy="22" r="2.5" fill="#C8281E" />
      <circle cx="36" cy="18" r="2" fill="#C8281E" />
      <circle cx="46" cy="26" r="2.5" fill="#C8281E" />
      
      <path d="M12 40C12 24 24 16 36 16C48 16 60 26 60 40C60 46 48 48 36 48C24 48 12 46 12 40Z" fill="#F4CA64" stroke="#D99726" stroke-width="1.5" stroke-linejoin="round" />
      
      <circle cx="20" cy="30" r="1" fill="#D99726" opacity="0.5" />
      <circle cx="48" cy="38" r="1.5" fill="#D99726" opacity="0.5" />
      <circle cx="54" cy="32" r="1" fill="#D99726" opacity="0.5" />
      
      <circle cx="30" cy="34" r="2" fill="#1E1A18" />
      <circle cx="30.5" cy="33.5" r="0.8" fill="#FFF" />
      <circle cx="42" cy="34" r="2" fill="#1E1A18" />
      <circle cx="42.5" cy="33.5" r="0.8" fill="#FFF" />
      <path d="M 34 36 Q 36 38 38 36" stroke="#1E1A18" stroke-width="1.2" fill="none" stroke-linecap="round" />
      <ellipse cx="26" cy="36" rx="2.5" ry="1.5" fill="#FF8A8A" opacity="0.8" />
      <ellipse cx="46" cy="36" rx="2.5" ry="1.5" fill="#FF8A8A" opacity="0.8" />
    </g>
    <text x="20" y="102" fill="#1E1A18" font-size="9" font-weight="900" font-family="serif">50&#162;</text>
    <text x="80" y="102" text-anchor="end" fill="#D9822B" font-size="6" font-weight="bold" font-family="sans-serif">OAXACA</text>
  
</svg>''',
  'postage-baguette': r'''<svg viewBox="0 0 100 120" fill="none" xmlns="http://www.w3.org/2000/svg">

    <rect x="4" y="4" width="92" height="112" rx="4" fill="#FCFAF7" stroke="#1E1A18" stroke-width="2" stroke-dasharray="3 3" />
    <rect x="10" y="10" width="80" height="100" fill="#FEF8EB" stroke="#8C7355" stroke-width="1.5" />
    <text x="50" y="22" text-anchor="middle" fill="#8C7355" font-size="7" font-weight="900" font-family="sans-serif" letter-spacing="1">FOURNIL ARTISAN</text>
    <line x1="16" y1="26" x2="84" y2="26" stroke="#8C7355" stroke-width="0.75" stroke-dasharray="2 1" />
    <g transform="translate(18, 24)">
      
      <path d="M 44 40 L 46 38 M 48 42 L 50 40" stroke="#D99726" stroke-width="1" stroke-linecap="round" opacity="0.4" />
      <path d="M 16 20 L 18 18 M 20 22 L 22 20" stroke="#D99726" stroke-width="1" stroke-linecap="round" opacity="0.4" />
      
      <path d="M12 50L48 14C52 10 58 14 54 18L18 54C14 58 8 54 12 50Z" fill="#F4BA42" stroke="#B86A1D" stroke-width="1.5" stroke-linejoin="round" />
      
      <path d="M 12 50 L 48 14 C 52 10 54 12 54 14 L 18 50 C 14 54 12 52 12 50 Z" fill="#D99726" opacity="0.6" />
      
      <path d="M 21 43 L 29 35" stroke="#FFFDF8" stroke-width="2" stroke-linecap="round" />
      <path d="M 22 42 L 28 36" stroke="#D99726" stroke-width="1.5" stroke-linecap="round" />
      <path d="M 31 33 L 39 25" stroke="#FFFDF8" stroke-width="2" stroke-linecap="round" />
      <path d="M 32 32 L 38 26" stroke="#D99726" stroke-width="1.5" stroke-linecap="round" />
      <path d="M 41 23 L 49 15" stroke="#FFFDF8" stroke-width="2" stroke-linecap="round" />
      <path d="M 42 22 L 48 16" stroke="#D99726" stroke-width="1.5" stroke-linecap="round" />
      
      <g transform="translate(33, 37) rotate(-45)">
        <circle cx="-5" cy="0" r="1.5" fill="#1E1A18" />
        <circle cx="5" cy="0" r="1.5" fill="#1E1A18" />
        <path d="M -2 2 Q 0 4 2 2" stroke="#1E1A18" stroke-width="1.2" fill="none" stroke-linecap="round" />
        <ellipse cx="-7" cy="2" rx="2" ry="1.5" fill="#FF8A8A" opacity="0.9" />
        <ellipse cx="7" cy="2" rx="2" ry="1.5" fill="#FF8A8A" opacity="0.9" />
      </g>
    </g>
    <text x="20" y="102" fill="#1E1A18" font-size="9" font-weight="900" font-family="serif">30&#162;</text>
    <text x="80" y="102" text-anchor="end" fill="#8C7355" font-size="6" font-weight="bold" font-family="sans-serif">PARIS</text>
  
</svg>''',
  'postage-croissant': r'''<svg viewBox="0 0 100 120" fill="none" xmlns="http://www.w3.org/2000/svg">

    <rect x="4" y="4" width="92" height="112" rx="4" fill="#FCFAF7" stroke="#1E1A18" stroke-width="2" stroke-dasharray="3 3" />
    <rect x="10" y="10" width="80" height="100" fill="#FEF8EB" stroke="#D9822B" stroke-width="1.5" />
    <text x="50" y="22" text-anchor="middle" fill="#D9822B" font-size="7" font-weight="900" font-family="sans-serif" letter-spacing="1">PÂTISSERIE</text>
    <line x1="16" y1="26" x2="84" y2="26" stroke="#D9822B" stroke-width="0.75" stroke-dasharray="2 1" />
    <g transform="translate(14, 30)">
      
      <path d="M 12 16 L 14 12 L 16 16 L 20 18 L 16 20 L 14 24 L 12 20 L 8 18 Z" fill="#F4BA42" opacity="0.5" />
      <path d="M 60 20 L 61 18 L 62 20 L 64 21 L 62 22 L 61 24 L 60 22 L 58 21 Z" fill="#F4BA42" opacity="0.5" />
      
      <path d="M12 40C16 20 28 12 40 12C52 12 64 20 68 40C60 38 52 32 40 32C28 32 20 38 12 40Z" fill="#D99726" />
      <path d="M12 40C16 20 28 12 40 12C52 12 64 20 68 40C60 38 52 32 40 32C28 32 20 38 12 40Z" fill="#F4B938" stroke="#8C5C1A" stroke-width="1.5" stroke-linejoin="round" />
      
      <path d="M 22 20 C 22 30 20 36 14 39" stroke="#8C5C1A" stroke-width="1.5" fill="none" stroke-linecap="round" />
      <path d="M 58 20 C 58 30 60 36 66 39" stroke="#8C5C1A" stroke-width="1.5" fill="none" stroke-linecap="round" />
      
      <ellipse cx="40" cy="26" rx="14" ry="12" fill="#F4BA42" stroke="#8C5C1A" stroke-width="1.5" />
      
      <path d="M 32 18 C 36 16 44 16 48 18" stroke="#FFF" stroke-width="1.5" fill="none" stroke-linecap="round" opacity="0.6" />
      
      <circle cx="34" cy="26" r="2" fill="#1E1A18" />
      <circle cx="46" cy="26" r="2" fill="#1E1A18" />
      <path d="M 37 28 Q 40 31 43 28" stroke="#1E1A18" stroke-width="1.2" fill="none" stroke-linecap="round" />
      <ellipse cx="30" cy="28" rx="2.5" ry="1.5" fill="#FF8A8A" opacity="0.8" />
      <ellipse cx="50" cy="28" rx="2.5" ry="1.5" fill="#FF8A8A" opacity="0.8" />
    </g>
    <text x="20" y="102" fill="#1E1A18" font-size="9" font-weight="900" font-family="serif">75&#162;</text>
    <text x="80" y="102" text-anchor="end" fill="#8C7355" font-size="6" font-weight="bold" font-family="sans-serif">FRANCE</text>
  
</svg>''',
  'postage-cheese': r'''<svg viewBox="0 0 100 120" fill="none" xmlns="http://www.w3.org/2000/svg">

    <rect x="4" y="4" width="92" height="112" rx="4" fill="#FCFAF7" stroke="#1E1A18" stroke-width="2" stroke-dasharray="3 3" />
    <rect x="10" y="10" width="80" height="100" fill="#FEF8EB" stroke="#D9822B" stroke-width="1.5" />
    <text x="50" y="22" text-anchor="middle" fill="#D9822B" font-size="7" font-weight="900" font-family="sans-serif" letter-spacing="1">PARMIGIANO</text>
    <line x1="16" y1="26" x2="84" y2="26" stroke="#D9822B" stroke-width="0.75" stroke-dasharray="2 1" />
    <g transform="translate(16, 30)">
      
      <path d="M16 44 L 60 44 L 52 24 L 22 24 Z" fill="#D9822B" opacity="0.3" />
      
      <path d="M12 42 L 56 42 L 48 22 L 18 22 Z" fill="#F4BA42" stroke="#D99726" stroke-width="1.5" stroke-linejoin="round" />
      
      <path d="M18 22 L 48 22 L 50 16 L 20 16 Z" fill="#FCE59F" stroke="#D99726" stroke-width="1.5" stroke-linejoin="round" />
      
      <path d="M48 22 L 56 42 L 58 36 L 50 16 Z" fill="#D99726" stroke="#D99726" stroke-width="1.5" stroke-linejoin="round" />
      
      <circle cx="22" cy="34" r="2.5" fill="#D99726" opacity="0.8" />
      <path d="M 22 34 A 2.5 2.5 0 0 0 24 32" stroke="#8C5C1A" stroke-width="0.5" fill="none" opacity="0.5" />
      <circle cx="36" cy="38" r="2" fill="#D99726" opacity="0.8" />
      <circle cx="46" cy="28" r="3" fill="#D99726" opacity="0.8" />
      <path d="M 46 28 A 3 3 0 0 0 49 26" stroke="#8C5C1A" stroke-width="0.5" fill="none" opacity="0.5" />
      
      <ellipse cx="26" cy="18" rx="2" ry="1" fill="#D99726" opacity="0.6" />
      <ellipse cx="40" cy="20" rx="1.5" ry="0.8" fill="#D99726" opacity="0.6" />
      
      <path d="M 6 12 L 10 16 L 16 10 L 12 6 Z" fill="#8C5C1A" />
      <path d="M 10 16 L 24 30 L 22 32 L 6 16 Z" fill="#DFD5C4" stroke="#1E1A18" stroke-width="0.5" />
      
      <circle cx="28" cy="28" r="1.5" fill="#1E1A18" />
      <circle cx="40" cy="28" r="1.5" fill="#1E1A18" />
      <path d="M 32 30 Q 34 32 36 30" stroke="#1E1A18" stroke-width="1.2" fill="none" stroke-linecap="round" />
      <ellipse cx="24" cy="30" rx="2" ry="1.2" fill="#FF8A8A" opacity="0.9" />
      <ellipse cx="44" cy="30" rx="2" ry="1.2" fill="#FF8A8A" opacity="0.9" />
    </g>
    <text x="20" y="102" fill="#1E1A18" font-size="9" font-weight="900" font-family="serif">55&#162;</text>
    <text x="80" y="102" text-anchor="end" fill="#D9822B" font-size="6" font-weight="bold" font-family="sans-serif">D.O.P.</text>
  
</svg>''',
  'postage-oliveoil': r'''<svg viewBox="0 0 100 120" fill="none" xmlns="http://www.w3.org/2000/svg">

    <rect x="4" y="4" width="92" height="112" rx="4" fill="#FCFAF7" stroke="#1E1A18" stroke-width="2" stroke-dasharray="3 3" />
    <rect x="10" y="10" width="80" height="100" fill="#EEF4F0" stroke="#4A6B53" stroke-width="1.5" />
    <text x="50" y="22" text-anchor="middle" fill="#4A6B53" font-size="7" font-weight="900" font-family="sans-serif" letter-spacing="1">OLIO D'OLIVA</text>
    <line x1="16" y1="26" x2="84" y2="26" stroke="#4A6B53" stroke-width="0.75" stroke-dasharray="2 1" />
    <g transform="translate(18, 28)">
      
      <path d="M24 14H36L42 26C44 32 44 46 36 52C30 56 26 56 20 52C12 46 12 32 18 26Z" fill="#D3DE8E" stroke="#75A87B" stroke-width="1.5" stroke-linejoin="round" />
      
      <path d="M 18 26 C 22 30 38 30 42 26 C 44 32 44 46 36 52 C 30 56 26 56 20 52 C 12 46 12 32 18 26 Z" fill="#B5C95B" />
      
      <rect x="27" y="8" width="6" height="6" fill="#8C5C33" rx="1" />
      
      <path d="M 16 34 C 15 40 18 48 24 52" stroke="#FFF" stroke-width="2" fill="none" opacity="0.6" stroke-linecap="round" />
      
      <path d="M 22 28 Q 30 32 38 28" fill="none" stroke="#FCFAF7" stroke-width="8" opacity="0.8" />
      <path d="M 22 28 Q 30 32 38 28" fill="none" stroke="#D99726" stroke-width="1" opacity="0.8" />
      
      <g transform="translate(38, 40)">
        <path d="M 0 10 C 2 4 8 0 12 -4" stroke="#4A6B53" stroke-width="1" fill="none" />
        <ellipse cx="6" cy="2" rx="3" ry="2" fill="#2D4233" transform="rotate(-30 6 2)" />
        <ellipse cx="10" cy="6" rx="3" ry="2" fill="#2D4233" transform="rotate(30 10 6)" />
        <ellipse cx="4" cy="8" rx="2.5" ry="1.5" fill="#75A87B" transform="rotate(15 4 8)" />
      </g>
      
      <circle cx="26" cy="38" r="1.5" fill="#1E1A18" />
      <circle cx="34" cy="38" r="1.5" fill="#1E1A18" />
      <path d="M 28.5 40 Q 30 43 31.5 40" stroke="#1E1A18" stroke-width="1" fill="none" stroke-linecap="round" />
      <ellipse cx="23" cy="40" rx="2" ry="1.2" fill="#FF8A8A" opacity="0.7" />
      <ellipse cx="37" cy="40" rx="2" ry="1.2" fill="#FF8A8A" opacity="0.7" />
    </g>
    <text x="20" y="102" fill="#1E1A18" font-size="9" font-weight="900" font-family="serif">65&#162;</text>
    <text x="80" y="102" text-anchor="end" fill="#4A6B53" font-size="6" font-weight="bold" font-family="sans-serif">TOSCANA</text>
  
</svg>''',
  'postage-wine': r'''<svg viewBox="0 0 100 120" fill="none" xmlns="http://www.w3.org/2000/svg">

    <rect x="4" y="4" width="92" height="112" rx="4" fill="#FCFAF7" stroke="#1E1A18" stroke-width="2" stroke-dasharray="3 3" />
    <rect x="10" y="10" width="80" height="100" fill="#FBEFF1" stroke="#8C2D3A" stroke-width="1.5" />
    <text x="50" y="22" text-anchor="middle" fill="#8C2D3A" font-size="7" font-weight="900" font-family="sans-serif" letter-spacing="1">GRAND CRU</text>
    <line x1="16" y1="26" x2="84" y2="26" stroke="#8C2D3A" stroke-width="0.75" stroke-dasharray="2 1" />
    <g transform="translate(20, 26)">
      
      <path d="M20 54V28C20 22 24 18 24 12H30C30 18 34 22 34 28V54H20Z" fill="#3D1A24" stroke="#8C2D3A" stroke-width="1.5" stroke-linejoin="round" />
      
      <path d="M 20.75 36 L 33.25 36" stroke="#1E1A18" stroke-width="1" opacity="0.5" />
      
      <rect x="23.5" y="6" width="7" height="6" fill="#A82E1C" rx="1" />
      
      <path d="M 22 30 V 50" stroke="#FFF" stroke-width="1.5" opacity="0.4" stroke-linecap="round" />
      
      <rect x="22" y="34" width="10" height="14" fill="#FCFAF7" rx="2" />
      <line x1="24" y1="36" x2="30" y2="36" stroke="#D99726" stroke-width="1" />
      <line x1="24" y1="46" x2="30" y2="46" stroke="#D99726" stroke-width="1" />

      
      <g transform="translate(36, 40)">
        <path d="M 4 2 Q 2 -2 6 -4" stroke="#4A6B53" fill="none" />
        <circle cx="4" cy="4" r="3" fill="#A83E4E" />
        <circle cx="10" cy="4" r="3" fill="#8C2D3A" />
        <circle cx="7" cy="9" r="3" fill="#6B1D28" />
        <circle cx="2" cy="8" r="2.5" fill="#8C2D3A" />
        <circle cx="12" cy="8" r="2.5" fill="#A83E4E" />
        <circle cx="7" cy="13" r="2" fill="#A83E4E" />
        
        <circle cx="3" cy="3" r="0.5" fill="#FFF" opacity="0.5" />
        <circle cx="9" cy="3" r="0.5" fill="#FFF" opacity="0.5" />
      </g>
    </g>
    <text x="20" y="102" fill="#1E1A18" font-size="9" font-weight="900" font-family="serif">90&#162;</text>
    <text x="80" y="102" text-anchor="end" fill="#8C2D3A" font-size="6" font-weight="bold" font-family="sans-serif">VINTAGE</text>
  
</svg>''',
  'postage-chili': r'''<svg viewBox="0 0 100 120" fill="none" xmlns="http://www.w3.org/2000/svg">

    <rect x="4" y="4" width="92" height="112" rx="4" fill="#FCFAF7" stroke="#1E1A18" stroke-width="2" stroke-dasharray="3 3" />
    <rect x="10" y="10" width="80" height="100" fill="#FBF0EB" stroke="#C85A32" stroke-width="1.5" />
    <text x="50" y="22" text-anchor="middle" fill="#C85A32" font-size="7" font-weight="900" font-family="sans-serif" letter-spacing="1">PEPERONCINO</text>
    <line x1="16" y1="26" x2="84" y2="26" stroke="#C85A32" stroke-width="0.75" stroke-dasharray="2 1" />
    <g transform="translate(18, 26)">
      
      <path d="M 12 20 Q 14 16 12 12 T 14 8" stroke="#F4BA42" stroke-width="1" fill="none" opacity="0.6" />
      <path d="M 46 30 Q 48 26 46 22 T 48 18" stroke="#F4BA42" stroke-width="1" fill="none" opacity="0.6" />
      
      <path d="M38 12C38 12 40 28 32 44C26 54 16 54 12 50C10 46 14 38 22 28C28 18 30 12 30 12Z" fill="#E83A30" stroke="#8C1810" stroke-width="1.5" stroke-linejoin="round" />
      
      <path d="M 26 18 C 22 24 16 36 14 42" stroke="#FF8A8A" stroke-width="1.5" fill="none" stroke-linecap="round" opacity="0.7" />
      <path d="M 32 20 C 32 24 28 34 22 40" stroke="#1E1A18" stroke-width="1" fill="none" stroke-linecap="round" opacity="0.2" />
      
      <path d="M30 12 Q 34 6 40 4" stroke="#4A6B53" stroke-width="2" fill="none" stroke-linecap="round" />
      <path d="M28 12C30 8 36 8 40 10C38 14 30 16 28 12Z" fill="#587E62" stroke="#2D4233" stroke-width="1" />
      
      <circle cx="23" cy="38" r="1.5" fill="#1E1A18" />
      <circle cx="31" cy="38" r="1.5" fill="#1E1A18" />
      <path d="M 25.5 40 Q 27 42 28.5 40" stroke="#1E1A18" stroke-width="1" fill="none" stroke-linecap="round" />
      <ellipse cx="20.5" cy="40" rx="1.5" ry="1" fill="#FFCDB2" opacity="0.8" />
      <ellipse cx="33.5" cy="40" rx="1.5" ry="1" fill="#FFCDB2" opacity="0.8" />
    </g>
    <text x="20" y="102" fill="#1E1A18" font-size="9" font-weight="900" font-family="serif">45&#162;</text>
    <text x="80" y="102" text-anchor="end" fill="#C85A32" font-size="6" font-weight="bold" font-family="sans-serif">SPEZIE</text>
  
</svg>''',
  'postage-mushroom': r'''<svg viewBox="0 0 100 120" fill="none" xmlns="http://www.w3.org/2000/svg">

    <rect x="4" y="4" width="92" height="112" rx="4" fill="#FCFAF7" stroke="#1E1A18" stroke-width="2" stroke-dasharray="3 3" />
    <rect x="10" y="10" width="80" height="100" fill="#F5EFEB" stroke="#8C7355" stroke-width="1.5" />
    <text x="50" y="22" text-anchor="middle" fill="#8C7355" font-size="7" font-weight="900" font-family="sans-serif" letter-spacing="1">PORCINI FOREST</text>
    <line x1="16" y1="26" x2="84" y2="26" stroke="#8C7355" stroke-width="0.75" stroke-dasharray="2 1" />
    <g transform="translate(18, 28)">
      
      <path d="M 12 50 Q 8 46 10 42 Q 14 44 12 50 Z" fill="#75A87B" opacity="0.6" />
      <path d="M 52 48 Q 56 46 54 40 Q 50 42 52 48 Z" fill="#75A87B" opacity="0.6" />
      
      <path d="M24 30C22 46 18 54 32 54C46 54 42 46 40 30Z" fill="#F3ECE2" stroke="#8C7355" stroke-width="1.5" stroke-linejoin="round" />
      
      <path d="M 22 48 Q 32 50 42 48" stroke="#8C5C33" stroke-width="1" fill="none" opacity="0.3" />
      <path d="M 24 44 Q 32 46 40 44" stroke="#8C5C33" stroke-width="1" fill="none" opacity="0.3" />
      
      <path d="M12 30 Q 32 38 52 30 Z" fill="#DFD5C4" stroke="#52321A" stroke-width="1" />
      
      <path d="M10 32C10 16 22 12 32 12C42 12 54 16 54 32C44 36 20 36 10 32Z" fill="#8C5C33" stroke="#52321A" stroke-width="1.5" stroke-linejoin="round" />
      
      <ellipse cx="20" cy="24" rx="3" ry="1.5" fill="#D99726" opacity="0.4" transform="rotate(-15 20 24)" />
      <ellipse cx="44" cy="22" rx="4" ry="2" fill="#D99726" opacity="0.4" transform="rotate(15 44 22)" />
      <ellipse cx="32" cy="18" rx="5" ry="2" fill="#D99726" opacity="0.4" />
      
      <path d="M 18 20 C 22 14 30 14 34 16" stroke="#FFF" stroke-width="1.5" fill="none" opacity="0.3" stroke-linecap="round" />
      
      <circle cx="26" cy="42" r="2" fill="#1E1A18" />
      <circle cx="38" cy="42" r="2" fill="#1E1A18" />
      <path d="M 30 44 Q 32 47 34 44" stroke="#1E1A18" stroke-width="1.2" fill="none" stroke-linecap="round" />
      <ellipse cx="22" cy="45" rx="2.5" ry="1.5" fill="#FF8A8A" opacity="0.7" />
      <ellipse cx="42" cy="45" rx="2.5" ry="1.5" fill="#FF8A8A" opacity="0.7" />
    </g>
    <text x="20" y="102" fill="#1E1A18" font-size="9" font-weight="900" font-family="serif">50&#162;</text>
    <text x="80" y="102" text-anchor="end" fill="#8C7355" font-size="6" font-weight="bold" font-family="sans-serif">WILD</text>
  
</svg>''',
  'postage-lemon': r'''<svg viewBox="0 0 100 120" fill="none" xmlns="http://www.w3.org/2000/svg">

    <rect x="4" y="4" width="92" height="112" rx="4" fill="#FCFAF7" stroke="#1E1A18" stroke-width="2" stroke-dasharray="3 3" />
    <rect x="10" y="10" width="80" height="100" fill="#FEF8EB" stroke="#D9822B" stroke-width="1.5" />
    <text x="50" y="22" text-anchor="middle" fill="#D9822B" font-size="7" font-weight="900" font-family="sans-serif" letter-spacing="1">MEYER LEMON</text>
    <line x1="16" y1="26" x2="84" y2="26" stroke="#D9822B" stroke-width="0.75" stroke-dasharray="2 1" />
    <g transform="translate(18, 30)">
      
      <circle cx="12" cy="12" r="1.5" fill="#F4BA42" opacity="0.5" />
      <circle cx="54" cy="46" r="2" fill="#F4BA42" opacity="0.5" />
      
      <path d="M12 28C10 20 18 12 32 12C46 12 54 20 54 32C54 44 46 52 32 52C18 52 14 40 12 28Z" fill="#FCE59F" stroke="#D99726" stroke-width="1.5" stroke-linejoin="round" />
      
      <g fill="#D99726" opacity="0.4">
        <circle cx="18" cy="28" r="0.8" />
        <circle cx="22" cy="22" r="0.8" />
        <circle cx="44" cy="42" r="0.8" />
        <circle cx="48" cy="34" r="0.8" />
        <circle cx="32" cy="48" r="0.8" />
        <circle cx="26" cy="46" r="0.8" />
      </g>
      
      <path d="M 20 30 C 22 22 28 16 34 16" stroke="#FFF" stroke-width="2" fill="none" stroke-linecap="round" opacity="0.7" />
      
      <path d="M30 12C32 2 44 4 48 10C42 16 34 16 30 12Z" fill="#587E62" stroke="#3D5A45" stroke-width="1.5" />
      <path d="M34 12C28 2 16 4 12 10C18 16 26 16 34 12Z" fill="#75A87B" stroke="#3D5A45" stroke-width="1.5" />
      <line x1="32" y1="14" x2="32" y2="8" stroke="#3D5A45" stroke-width="2" stroke-linecap="round" />
      
      <circle cx="26" cy="32" r="2" fill="#1E1A18" />
      <circle cx="26.5" cy="31" r="0.8" fill="#FFF" />
      <circle cx="38" cy="32" r="2" fill="#1E1A18" />
      <circle cx="38.5" cy="31" r="0.8" fill="#FFF" />
      <path d="M 30 34 Q 32 37 34 34" stroke="#1E1A18" stroke-width="1.2" fill="none" stroke-linecap="round" />
      <ellipse cx="22" cy="35" rx="3" ry="1.5" fill="#FF8A8A" opacity="0.8" />
      <ellipse cx="42" cy="35" rx="3" ry="1.5" fill="#FF8A8A" opacity="0.8" />
    </g>
    <text x="20" y="102" fill="#1E1A18" font-size="9" font-weight="900" font-family="serif">30&#162;</text>
    <text x="80" y="102" text-anchor="end" fill="#D9822B" font-size="6" font-weight="bold" font-family="sans-serif">AMALFI</text>
  
</svg>''',
  'postage-skillet': r'''<svg viewBox="0 0 100 120" fill="none" xmlns="http://www.w3.org/2000/svg">

    <rect x="4" y="4" width="92" height="112" rx="4" fill="#FCFAF7" stroke="#1E1A18" stroke-width="2" stroke-dasharray="3 3" />
    <rect x="10" y="10" width="80" height="100" fill="#FBF0EB" stroke="#C85A32" stroke-width="1.5" />
    <text x="50" y="22" text-anchor="middle" fill="#C85A32" font-size="7" font-weight="900" font-family="sans-serif" letter-spacing="1">CAST IRON</text>
    <line x1="16" y1="26" x2="84" y2="26" stroke="#C85A32" stroke-width="0.75" stroke-dasharray="2 1" />
    <g transform="translate(18, 30)">
      
      <path d="M48 24L60 14" stroke="#2C2623" stroke-width="6" stroke-linecap="round" />
      <circle cx="58" cy="16" r="1.5" fill="#FBF0EB" />
      
      <circle cx="30" cy="32" r="22" fill="#2C2623" stroke="#1E1A18" stroke-width="1.5" />
      
      <circle cx="30" cy="32" r="18" fill="#3D3430" />
      <path d="M 16 32 A 14 14 0 0 1 44 32" stroke="#524843" stroke-width="1" fill="none" />
      
      <path d="M 18 20 Q 22 24 26 22 T 34 24 T 38 20" stroke="#A82E1C" stroke-width="3" fill="none" stroke-linecap="round" />
      <path d="M 18 20 Q 22 24 26 22 T 34 24 T 38 20" stroke="#FFF" stroke-width="1" fill="none" stroke-linecap="round" opacity="0.6" />
      
      <path d="M 14 26 L 16 28 M 42 22 L 44 24 M 40 42 L 42 40 M 18 40 L 20 38" stroke="#F4BA42" stroke-width="1" stroke-linecap="round" />
      
      <path d="M 20 36 Q 22 26 30 26 Q 40 28 40 36 Q 38 46 30 46 Q 18 44 20 36 Z" fill="#FFFDF8" />
      <path d="M 20 36 Q 22 26 30 26 Q 40 28 40 36 Q 38 46 30 46 Q 18 44 20 36 Z" stroke="#E8D8A0" stroke-width="0.5" fill="none" />
      
      <circle cx="30" cy="36" r="6" fill="#F4BA42" stroke="#D99726" stroke-width="0.5" />
      <ellipse cx="28" cy="34" rx="2" ry="1" fill="#FFF" opacity="0.5" transform="rotate(-30 28 34)" />
      
      <circle cx="27.5" cy="36" r="1.2" fill="#1E1A18" />
      <circle cx="32.5" cy="36" r="1.2" fill="#1E1A18" />
      <path d="M 29 37.5 Q 30 39 31 37.5" stroke="#1E1A18" stroke-width="0.8" fill="none" stroke-linecap="round" />
      <ellipse cx="25.5" cy="37.5" rx="1.5" ry="1" fill="#FF8A8A" opacity="0.8" />
      <ellipse cx="34.5" cy="37.5" rx="1.5" ry="1" fill="#FF8A8A" opacity="0.8" />
    </g>
    <text x="20" y="102" fill="#1E1A18" font-size="9" font-weight="900" font-family="serif">60&#162;</text>
    <text x="80" y="102" text-anchor="end" fill="#C85A32" font-size="6" font-weight="bold" font-family="sans-serif">CUISINE</text>
  
</svg>''',
  'postage-ramen': r'''<svg viewBox="0 0 100 120" fill="none" xmlns="http://www.w3.org/2000/svg">

    <rect x="4" y="4" width="92" height="112" rx="4" fill="#FCFAF7" stroke="#1E1A18" stroke-width="2" stroke-dasharray="3 3" />
    <rect x="10" y="10" width="80" height="100" fill="#EEF4F0" stroke="#4A6B53" stroke-width="1.5" />
    <text x="50" y="22" text-anchor="middle" fill="#4A6B53" font-size="7" font-weight="900" font-family="sans-serif" letter-spacing="1">CRAFT RAMEN</text>
    <line x1="16" y1="26" x2="84" y2="26" stroke="#4A6B53" stroke-width="0.75" stroke-dasharray="2 1" />
    <g transform="translate(18, 28)">
      
      <path d="M 22 14 Q 24 10 22 6" stroke="#FFF" stroke-width="1.5" fill="none" stroke-linecap="round" opacity="0.6" />
      <path d="M 42 14 Q 40 10 42 6" stroke="#FFF" stroke-width="1.5" fill="none" stroke-linecap="round" opacity="0.6" />
      
      <rect x="14" y="16" width="12" height="14" fill="#2D4233" transform="rotate(-15 14 16)" />
      
      <path d="M44 8L36 30M50 10L38 32" stroke="#8C7355" stroke-width="2.5" stroke-linecap="round" />
      
      <ellipse cx="32" cy="30" rx="20" ry="8" fill="#D9822B" stroke="#B86A1D" stroke-width="1" />
      
      <path d="M 20 30 Q 24 26 28 30 T 36 30 T 42 28" stroke="#FCE59F" stroke-width="1.5" fill="none" />
      <path d="M 18 32 Q 22 28 26 32 T 34 32 T 44 30" stroke="#FCE59F" stroke-width="1.5" fill="none" />
      
      <circle cx="36" cy="26" r="3.5" fill="#FFF" stroke="#FF8A8A" stroke-width="0.5" />
      <path d="M 35 27 Q 37 28 37 25 Q 35 24 35 26 Z" stroke="#FF8A8A" fill="none" stroke-width="0.8" />
      
      <circle cx="28" cy="26" r="1.5" fill="#75A87B" />
      <circle cx="30" cy="28" r="1.5" fill="#75A87B" />
      
      <circle cx="22" cy="28" r="4.5" fill="#FFF" stroke="#E8D8A0" stroke-width="0.5" />
      <circle cx="22" cy="28" r="2.5" fill="#F4BA42" />
      
      <path d="M12 30C12 46 20 54 32 54C44 54 52 46 52 30Z" fill="#FFFDF8" stroke="#E64A33" stroke-width="1.5" />
      <path d="M12 36 Q 32 40 52 36" fill="none" stroke="#E64A33" stroke-width="1.5" />
      
      <circle cx="24" cy="44" r="2" fill="#1E1A18" />
      <circle cx="40" cy="44" r="2" fill="#1E1A18" />
      <path d="M 30 46 Q 32 48 34 46" stroke="#1E1A18" stroke-width="1.2" fill="none" stroke-linecap="round" />
      <ellipse cx="20" cy="46" rx="2.5" ry="1.5" fill="#FFCDB2" opacity="0.8" />
      <ellipse cx="44" cy="46" rx="2.5" ry="1.5" fill="#FFCDB2" opacity="0.8" />
    </g>
    <text x="20" y="102" fill="#1E1A18" font-size="9" font-weight="900" font-family="serif">80&#162;</text>
    <text x="80" y="102" text-anchor="end" fill="#4A6B53" font-size="6" font-weight="bold" font-family="sans-serif">TOKYO</text>
  
</svg>''',
  'postage-avocado': r'''<svg viewBox="0 0 100 120" fill="none" xmlns="http://www.w3.org/2000/svg">

    <rect x="4" y="4" width="92" height="112" rx="4" fill="#FCFAF7" stroke="#1E1A18" stroke-width="2" stroke-dasharray="3 3" />
    <rect x="10" y="10" width="80" height="100" fill="#EEF4F0" stroke="#4A6B53" stroke-width="1.5" />
    <text x="50" y="22" text-anchor="middle" fill="#4A6B53" font-size="7" font-weight="900" font-family="sans-serif" letter-spacing="1">HASS AVOCADO</text>
    <line x1="16" y1="26" x2="84" y2="26" stroke="#4A6B53" stroke-width="0.75" stroke-dasharray="2 1" />
    <g transform="translate(18, 28)">
      
      <path d="M 12 16 L 13 14 L 14 16 L 16 17 L 14 18 L 13 20 L 12 18 L 10 17 Z" fill="#75A87B" opacity="0.5" />
      <path d="M 48 48 L 49 46 L 50 48 L 52 49 L 50 50 L 49 52 L 48 50 L 46 49 Z" fill="#75A87B" opacity="0.5" />
      
      <path d="M32 10C22 10 16 20 16 32C16 46 24 56 32 56C40 56 48 46 48 32C48 20 42 10 32 10Z" fill="#2D4233" stroke="#1E1A18" stroke-width="1.5" stroke-linejoin="round" />
      
      <path d="M32 12C23 12 18 21 18 32C18 44 25 54 32 54C39 54 46 44 46 32C46 21 41 12 32 12Z" fill="#75A87B" />
      
      <path d="M32 14C24 14 20 22 20 32C20 44 26 52 32 52C38 52 44 44 44 32C44 22 40 14 32 14Z" fill="#D3DE8E" />
      
      <circle cx="32" cy="38" r="11" fill="#75A87B" opacity="0.6" />
      
      <circle cx="32" cy="38" r="10" fill="#8C5C33" stroke="#52321A" stroke-width="1" />
      
      <ellipse cx="28" cy="34" rx="3" ry="1.5" fill="#FFF" opacity="0.3" transform="rotate(-30 28 34)" />
      <path d="M 38 42 A 4 4 0 0 0 34 46" stroke="#52321A" stroke-width="1" fill="none" opacity="0.5" />
      
      <circle cx="28" cy="37" r="1.5" fill="#1E1A18" />
      <circle cx="36" cy="37" r="1.5" fill="#1E1A18" />
      <path d="M 30.5 39 Q 32 41 33.5 39" stroke="#1E1A18" stroke-width="1" fill="none" stroke-linecap="round" />
      <ellipse cx="25" cy="39" rx="2" ry="1.2" fill="#FF8A8A" opacity="0.9" />
      <ellipse cx="39" cy="39" rx="2" ry="1.2" fill="#FF8A8A" opacity="0.9" />
    </g>
    <text x="20" y="102" fill="#1E1A18" font-size="9" font-weight="900" font-family="serif">40&#162;</text>
    <text x="80" y="102" text-anchor="end" fill="#4A6B53" font-size="6" font-weight="bold" font-family="sans-serif">HARVEST</text>
  
</svg>''',
  'postage-espresso': r'''<svg viewBox="0 0 100 120" fill="none" xmlns="http://www.w3.org/2000/svg">

    <rect x="4" y="4" width="92" height="112" rx="4" fill="#FCFAF7" stroke="#1E1A18" stroke-width="2" stroke-dasharray="3 3" />
    <rect x="10" y="10" width="80" height="100" fill="#F5EFEB" stroke="#8C7355" stroke-width="1.5" />
    <text x="50" y="22" text-anchor="middle" fill="#8C7355" font-size="7" font-weight="900" font-family="sans-serif" letter-spacing="1">CREMA ESPRESSO</text>
    <line x1="16" y1="26" x2="84" y2="26" stroke="#8C7355" stroke-width="0.75" stroke-dasharray="2 1" />
    <g transform="translate(18, 30)">
      
      <path d="M 24 16 Q 26 10 24 6 T 28 2" stroke="#8C7355" stroke-width="1.5" fill="none" stroke-linecap="round" opacity="0.6" />
      <path d="M 32 14 Q 34 8 32 4 T 36 0" stroke="#8C7355" stroke-width="1.5" fill="none" stroke-linecap="round" opacity="0.6" />
      <path d="M 40 16 Q 42 10 40 6 T 44 2" stroke="#8C7355" stroke-width="1.5" fill="none" stroke-linecap="round" opacity="0.6" />
      
      <ellipse cx="30" cy="50" rx="20" ry="6" fill="#FBF0EB" stroke="#8C7355" stroke-width="1.5" />
      <ellipse cx="30" cy="50" rx="14" ry="3" fill="#E8E0D2" />
      
      <path d="M44 32C52 32 54 40 44 42" fill="none" stroke="#FFFDF8" stroke-width="4" stroke-linecap="round" />
      <path d="M44 32C52 32 54 40 44 42" fill="none" stroke="#8C7355" stroke-width="1" stroke-linecap="round" />
      
      <path d="M16 26 C 16 46, 22 48, 30 48 C 38 48, 44 46, 44 26 Z" fill="#FFFDF8" stroke="#8C7355" stroke-width="1.5" />
      
      <ellipse cx="30" cy="26" rx="14" ry="4" fill="#52321A" stroke="#8C7355" stroke-width="1" />
      
      <ellipse cx="30" cy="26" rx="12" ry="3" fill="#D9822B" />
      <path d="M 22 26 Q 30 28 38 26" stroke="#F4BA42" stroke-width="1" fill="none" />
      <circle cx="26" cy="25" r="0.8" fill="#FFF" opacity="0.6" />
      <circle cx="34" cy="27" r="0.5" fill="#FFF" opacity="0.6" />
      
      <path d="M 19 30 C 19 38 21 42 24 44" stroke="#FFF" stroke-width="2" fill="none" stroke-linecap="round" />
      
      <circle cx="24" cy="35" r="1.5" fill="#1E1A18" />
      <circle cx="36" cy="35" r="1.5" fill="#1E1A18" />
      <path d="M 28 37 Q 30 39 32 37" stroke="#1E1A18" stroke-width="1.2" fill="none" stroke-linecap="round" />
      <ellipse cx="20" cy="37" rx="2" ry="1.2" fill="#FF8A8A" opacity="0.8" />
      <ellipse cx="40" cy="37" rx="2" ry="1.2" fill="#FF8A8A" opacity="0.8" />
    </g>
    <text x="20" y="102" fill="#1E1A18" font-size="9" font-weight="900" font-family="serif">25&#162;</text>
    <text x="80" y="102" text-anchor="end" fill="#8C7355" font-size="6" font-weight="bold" font-family="sans-serif">ROASTERY</text>
  
</svg>''',
  'postage-honey': r'''<svg viewBox="0 0 100 120" fill="none" xmlns="http://www.w3.org/2000/svg">

    <rect x="4" y="4" width="92" height="112" rx="4" fill="#FCFAF7" stroke="#1E1A18" stroke-width="2" stroke-dasharray="3 3" />
    <rect x="10" y="10" width="80" height="100" fill="#FEF8EB" stroke="#D9822B" stroke-width="1.5" />
    <text x="50" y="22" text-anchor="middle" fill="#D9822B" font-size="7" font-weight="900" font-family="sans-serif" letter-spacing="1">RAW HONEY</text>
    <line x1="16" y1="26" x2="84" y2="26" stroke="#D9822B" stroke-width="0.75" stroke-dasharray="2 1" />
    <g transform="translate(18, 28)">
      
      <g fill="#F4CA64" opacity="0.4">
        <polygon points="10,10 13,12 13,15 10,17 7,15 7,12" />
        <polygon points="16,13 19,15 19,18 16,20 13,18 13,15" />
        <polygon points="10,17 13,19 13,22 10,24 7,22 7,19" />
        <polygon points="54,40 57,42 57,45 54,47 51,45 51,42" />
        <polygon points="48,43 51,45 51,48 48,50 45,48 45,45" />
      </g>
      
      <rect x="18" y="20" width="28" height="30" rx="8" fill="#F4BA42" stroke="#D99726" stroke-width="1.5" />
      <path d="M 18 26 Q 32 30 46 26 L 46 50 Q 32 54 18 50 Z" fill="#F4CA64" />
      
      <path d="M 22 28 C 22 34 26 36 26 30" fill="#D99726" opacity="0.6" />
      <path d="M 30 29 C 30 38 34 40 34 31" fill="#D99726" opacity="0.6" />
      <path d="M 40 28 C 40 35 44 37 44 29" fill="#D99726" opacity="0.6" />
      
      <rect x="14" y="14" width="36" height="8" rx="3" fill="#D9822B" stroke="#8C5C1A" stroke-width="1.5" />
      <line x1="16" y1="23" x2="48" y2="23" stroke="#FFF" stroke-width="1" stroke-dasharray="2 2" />
      
      <path d="M 20 28 C 20 40 22 46 26 48" stroke="#FFF" stroke-width="2" fill="none" stroke-linecap="round" opacity="0.5" />
      
      <circle cx="26" cy="38" r="2" fill="#1E1A18" />
      <circle cx="38" cy="38" r="2" fill="#1E1A18" />
      <path d="M 30 40 Q 32 43 34 40" stroke="#1E1A18" stroke-width="1.2" fill="none" stroke-linecap="round" />
      <ellipse cx="22" cy="40" rx="2.5" ry="1.5" fill="#FF8A8A" opacity="0.8" />
      <ellipse cx="42" cy="40" rx="2.5" ry="1.5" fill="#FF8A8A" opacity="0.8" />
      
      <path d="M 36 10 C 38 4 44 14 48 10" stroke="#1E1A18" stroke-width="0.5" stroke-dasharray="1 1" fill="none" />
      <g transform="translate(48, 8) scale(0.6)">
        <ellipse cx="10" cy="10" rx="6" ry="4" fill="#F4BA42" stroke="#1E1A18" stroke-width="1" />
        <line x1="8" y1="6" x2="8" y2="14" stroke="#1E1A18" stroke-width="1.5" />
        <line x1="12" y1="6" x2="12" y2="14" stroke="#1E1A18" stroke-width="1.5" />
        <circle cx="4" cy="10" r="1" fill="#1E1A18" />
        <path d="M 8 6 C 6 2 12 2 10 6" fill="#FFF" stroke="#1E1A18" stroke-width="0.5" />
      </g>
    </g>
    <text x="20" y="102" fill="#1E1A18" font-size="9" font-weight="900" font-family="serif">45&#162;</text>
    <text x="80" y="102" text-anchor="end" fill="#D9822B" font-size="6" font-weight="bold" font-family="sans-serif">ORGANIC</text>
  
</svg>''',
};
