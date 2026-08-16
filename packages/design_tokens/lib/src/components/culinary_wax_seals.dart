// GENERATED PIXEL-PERFECT EMBOSSED WAX SEALS & BADGES
// 100% exact parity with Next.js CulinaryWaxSeals.tsx

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'culinary_postage_stamps.dart';

class SvgWaxSealWidget extends StatelessWidget {
  final String id;
  final double size;
  final double rotation;

  const SvgWaxSealWidget({
    super.key,
    required this.id,
    this.size = 56,
    this.rotation = 0,
  });

  @override
  Widget build(BuildContext context) {
    final rawSvg = rawWaxSealSvgMap[id] ?? rawWaxSealSvgMap['seal-chef-kiss'] ?? rawWaxSealSvgMap.values.first;
    return Transform.rotate(
      angle: rotation * (math.pi / 180),
      child: SizedBox(
        width: size,
        height: size,
        child: SvgPicture.string(
          rawSvg,
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

final List<CulinaryStampDef> waxSealDefs = [
  CulinaryStampDef(
    id: 'seal-farm-table',
    name: 'Farm to Table Seal',
    category: 'seals',
    defaultRotation: -5,
    builder: ({double size = 56, double rotation = -5}) => SvgWaxSealWidget(id: 'seal-farm-table', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'seal-michelin',
    name: 'Michelin 3-Star Seal',
    category: 'seals',
    defaultRotation: 4,
    builder: ({double size = 56, double rotation = 4}) => SvgWaxSealWidget(id: 'seal-michelin', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'seal-wild-ferment',
    name: 'Wild Sourdough Ferment',
    category: 'seals',
    defaultRotation: -4,
    builder: ({double size = 56, double rotation = -4}) => SvgWaxSealWidget(id: 'seal-wild-ferment', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'seal-wood-fired',
    name: 'Wood Fired Oven Seal',
    category: 'seals',
    defaultRotation: 5,
    builder: ({double size = 56, double rotation = 5}) => SvgWaxSealWidget(id: 'seal-wood-fired', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'seal-handcrafted-daily',
    name: 'Handcrafted Daily Seal',
    category: 'seals',
    defaultRotation: 4,
    builder: ({double size = 56, double rotation = 4}) => SvgWaxSealWidget(id: 'seal-handcrafted-daily', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'stamp-al-dente',
    name: 'Al Dente Rubber Stamp',
    category: 'seals',
    defaultRotation: -8,
    builder: ({double size = 56, double rotation = -8}) => SvgWaxSealWidget(id: 'stamp-al-dente', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'stamp-slow-simmer',
    name: 'Slow Simmered Badge',
    category: 'seals',
    defaultRotation: 5,
    builder: ({double size = 56, double rotation = 5}) => SvgWaxSealWidget(id: 'stamp-slow-simmer', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'stamp-secret-recipe',
    name: 'Secret Recipe Postmark',
    category: 'seals',
    defaultRotation: -6,
    builder: ({double size = 56, double rotation = -6}) => SvgWaxSealWidget(id: 'stamp-secret-recipe', size: size, rotation: rotation),
  ),
];

final Map<String, String> rawWaxSealSvgMap = {
  'seal-farm-table': r'''<svg viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">

    <circle cx="50" cy="50" r="48" fill="#FFFFFF" />
    <circle cx="50" cy="50" r="44" fill="#D5F5E3" stroke="#4A3219" stroke-width="3" />
    <circle cx="50" cy="50" r="39" stroke="#4A3219" stroke-width="2" stroke-dasharray="1 5" stroke-linecap="round" opacity="0.6" />

    <path id="curve-ft-top" d="M 17 50 A 33 33 0 0 1 83 50" fill="none" />
    <path id="curve-ft-bot" d="M 10 50 A 40 40 0 0 0 90 50" fill="none" />
    <text fill="#27AE60" font-size="8.5" font-weight="900" font-family="system-ui, sans-serif" letter-spacing="1">
      <textPath href="#curve-ft-top" start-offset="50%" text-anchor="middle">FARM TO TABLE</textPath>
    </text>
    <text fill="#27AE60" font-size="7" font-weight="800" font-family="system-ui, sans-serif" letter-spacing="1">
      <textPath href="#curve-ft-bot" start-offset="50%" text-anchor="middle">&#8226; 100% ORGANIC &#8226;</textPath>
    </text>

    
    <g stroke="#4A3219" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
      <path d="M 50 38 Q 40 28 42 22 Q 47 25 50 32" fill="#58D68D" />
      <path d="M 50 38 Q 60 28 58 22 Q 53 25 50 32" fill="#58D68D" />
      <path d="M 50 38 L 50 20" fill="none" stroke-width="3" stroke="#58D68D" />
      <path d="M 37 38 C 45 35 55 35 63 38 L 56 68 Q 50 78 44 68 Z" fill="#F39C12" />
      <path d="M 42 45 L 48 45" fill="none" stroke-width="1.5" opacity="0.4" />
      <path d="M 58 55 L 53 55" fill="none" stroke-width="1.5" opacity="0.4" />
    </g>
    <g transform="translate(50.0, 50.0) scale(0.8)"><circle cx="-6" cy="0" r="3.5" fill="#4A3219" />
                       <circle cx="-7.5" cy="-1.5" r="1.5" fill="#FFFFFF" />
                       <circle cx="6" cy="0" r="3.5" fill="#4A3219" />
                       <circle cx="4.5" cy="-1.5" r="1.5" fill="#FFFFFF" /><path d="M -3 2 Q 0 5 3 2" fill="none" stroke="#4A3219" stroke-width="1.5" stroke-linecap="round" /><ellipse cx="-11" cy="3" rx="3.5" ry="2" fill="#FF8DA1" opacity="0.8" />
                   <ellipse cx="11" cy="3" rx="3.5" ry="2" fill="#FF8DA1" opacity="0.8" /></g>
  
</svg>''',
  'seal-michelin': r'''<svg viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">

    <circle cx="50" cy="50" r="48" fill="#FFFFFF" />
    <circle cx="50" cy="50" r="44" fill="#FDEBD0" stroke="#4A3219" stroke-width="3" />
    <circle cx="50" cy="50" r="39" stroke="#4A3219" stroke-width="2" stroke-dasharray="1 5" stroke-linecap="round" opacity="0.6" />

    <path id="curve-ms-top" d="M 17 50 A 33 33 0 0 1 83 50" fill="none" />
    <path id="curve-ms-bot" d="M 10 50 A 40 40 0 0 0 90 50" fill="none" />
    <text fill="#D35400" font-size="8" font-weight="900" font-family="system-ui, sans-serif" letter-spacing="1">
      <textPath href="#curve-ms-top" start-offset="50%" text-anchor="middle">CHEF SELECTION</textPath>
    </text>
    <text fill="#D35400" font-size="7" font-weight="800" font-family="system-ui, sans-serif" letter-spacing="1">
      <textPath href="#curve-ms-bot" start-offset="50%" text-anchor="middle">&#8226; 3-STAR QUALITY &#8226;</textPath>
    </text>

    
    <g stroke="#4A3219" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
      <path d="M 50 24 L 56 38 L 71 39 L 59 49 L 62 64 L 50 56 L 38 64 L 41 49 L 29 39 L 44 38 Z" fill="#F1C40F" />
    </g>
    <g transform="translate(50.0, 48.0) scale(0.8)"><circle cx="-6" cy="0" r="3.5" fill="#4A3219" />
                       <circle cx="-7.5" cy="-1.5" r="1.5" fill="#FFFFFF" />
                       <circle cx="6" cy="0" r="3.5" fill="#4A3219" />
                       <circle cx="4.5" cy="-1.5" r="1.5" fill="#FFFFFF" /><path d="M -3.5 2 Q 0 7 3.5 2 Z" fill="#FF8DA1" stroke="#4A3219" stroke-width="1.5" stroke-linejoin="round" /><ellipse cx="-11" cy="3" rx="3.5" ry="2" fill="#FF8DA1" opacity="0.8" />
                   <ellipse cx="11" cy="3" rx="3.5" ry="2" fill="#FF8DA1" opacity="0.8" /></g>
    
    <path d="M 30 25 L 32 30 L 37 32 L 32 34 L 30 39 L 28 34 L 23 32 L 28 30 Z" fill="#FFF" stroke="#4A3219" stroke-width="1" stroke-linejoin="round"/>
    <path d="M 70 25 L 71 28 L 74 29 L 71 30 L 70 33 L 69 30 L 66 29 L 69 28 Z" fill="#FFF" stroke="#4A3219" stroke-width="1" stroke-linejoin="round"/>
  
</svg>''',
  'seal-wild-ferment': r'''<svg viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">

    <circle cx="50" cy="50" r="48" fill="#FFFFFF" />
    <circle cx="50" cy="50" r="44" fill="#E8DAEF" stroke="#4A3219" stroke-width="3" />
    <circle cx="50" cy="50" r="39" stroke="#4A3219" stroke-width="2" stroke-dasharray="1 5" stroke-linecap="round" opacity="0.6" />

    <path id="curve-wf-top" d="M 17 50 A 33 33 0 0 1 83 50" fill="none" />
    <path id="curve-wf-bot" d="M 10 50 A 40 40 0 0 0 90 50" fill="none" />
    <text fill="#8E44AD" font-size="9" font-weight="900" font-family="system-ui, sans-serif" letter-spacing="1">
      <textPath href="#curve-wf-top" start-offset="50%" text-anchor="middle">WILD FERMENT</textPath>
    </text>
    <text fill="#8E44AD" font-size="7" font-weight="800" font-family="system-ui, sans-serif" letter-spacing="1">
      <textPath href="#curve-wf-bot" start-offset="50%" text-anchor="middle">&#8226; SOURDOUGH &#8226;</textPath>
    </text>

    
    <g stroke="#4A3219" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
      <path d="M 28 60 C 22 60 20 40 50 36 C 80 40 78 60 72 60 Z" fill="#E67E22" />
      <path d="M 38 43 Q 45 52 40 56" fill="none" stroke-width="2" />
      <path d="M 50 40 Q 55 50 50 55" fill="none" stroke-width="2" />
      <path d="M 62 43 Q 55 52 60 56" fill="none" stroke-width="2" />
      
      
      <circle cx="28" cy="35" r="4.5" fill="#FAD7A1" />
      <circle cx="72" cy="33" r="5.5" fill="#FAD7A1" />
    </g>
    <g transform="translate(50.0, 49.0) scale(0.7)"><path d="M -9 0 Q -6 3 -3 0" fill="none" stroke="#4A3219" stroke-width="2" stroke-linecap="round" />
                       <path d="M 3 0 Q 6 3 9 0" fill="none" stroke="#4A3219" stroke-width="2" stroke-linecap="round" /><path d="M -3 2 Q 0 5 3 2" fill="none" stroke="#4A3219" stroke-width="1.5" stroke-linecap="round" /><ellipse cx="-11" cy="3" rx="3.5" ry="2" fill="#FF8DA1" opacity="0.8" />
                   <ellipse cx="11" cy="3" rx="3.5" ry="2" fill="#FF8DA1" opacity="0.8" /></g>
    <g transform="translate(28.0, 35.0) scale(0.4)"><circle cx="-6" cy="0" r="3.5" fill="#4A3219" />
                       <circle cx="-7.5" cy="-1.5" r="1.5" fill="#FFFFFF" />
                       <circle cx="6" cy="0" r="3.5" fill="#4A3219" />
                       <circle cx="4.5" cy="-1.5" r="1.5" fill="#FFFFFF" /><path d="M -3.5 2 Q 0 7 3.5 2 Z" fill="#FF8DA1" stroke="#4A3219" stroke-width="1.5" stroke-linejoin="round" /><ellipse cx="-11" cy="3" rx="3.5" ry="2" fill="#FF8DA1" opacity="0.8" />
                   <ellipse cx="11" cy="3" rx="3.5" ry="2" fill="#FF8DA1" opacity="0.8" /></g>
    <g transform="translate(72.0, 33.0) scale(0.45)"><circle cx="-6" cy="0" r="3.5" fill="#4A3219" />
                       <circle cx="-7.5" cy="-1.5" r="1.5" fill="#FFFFFF" />
                       <circle cx="6" cy="0" r="3.5" fill="#4A3219" />
                       <circle cx="4.5" cy="-1.5" r="1.5" fill="#FFFFFF" /><path d="M -3 2 Q 0 5 3 2" fill="none" stroke="#4A3219" stroke-width="1.5" stroke-linecap="round" /><ellipse cx="-11" cy="3" rx="3.5" ry="2" fill="#FF8DA1" opacity="0.8" />
                   <ellipse cx="11" cy="3" rx="3.5" ry="2" fill="#FF8DA1" opacity="0.8" /></g>
  
</svg>''',
  'seal-wood-fired': r'''<svg viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">

    <circle cx="50" cy="50" r="48" fill="#FFFFFF" />
    <circle cx="50" cy="50" r="44" fill="#FADBD8" stroke="#4A3219" stroke-width="3" />
    <circle cx="50" cy="50" r="39" stroke="#4A3219" stroke-width="2" stroke-dasharray="1 5" stroke-linecap="round" opacity="0.6" />

    <path id="curve-wf2-top" d="M 17 50 A 33 33 0 0 1 83 50" fill="none" />
    <path id="curve-wf2-bot" d="M 10 50 A 40 40 0 0 0 90 50" fill="none" />
    <text fill="#C0392B" font-size="9" font-weight="900" font-family="system-ui, sans-serif" letter-spacing="1">
      <textPath href="#curve-wf2-top" start-offset="50%" text-anchor="middle">WOOD FIRED</textPath>
    </text>
    <text fill="#C0392B" font-size="7" font-weight="800" font-family="system-ui, sans-serif" letter-spacing="1">
      <textPath href="#curve-wf2-bot" start-offset="50%" text-anchor="middle">&#8226; BRICK OVEN &#8226;</textPath>
    </text>

    
    <g stroke="#4A3219" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
      <path d="M 33 34 L 67 34 L 56 65 Q 50 72 44 65 Z" fill="#F4D03F" />
      <path d="M 30 34 Q 50 28 70 34 C 74 36 67 42 67 42 L 33 42 C 33 42 26 36 30 34 Z" fill="#E67E22" />
      
      <circle cx="44" cy="48" r="4" fill="#E74C3C" />
      <circle cx="55" cy="56" r="3.5" fill="#E74C3C" />
    </g>
    <g transform="translate(50.0, 40.0) scale(0.7)"><circle cx="-6" cy="0" r="3.5" fill="#4A3219" />
                       <circle cx="-7.5" cy="-1.5" r="1.5" fill="#FFFFFF" />
                       <circle cx="6" cy="0" r="3.5" fill="#4A3219" />
                       <circle cx="4.5" cy="-1.5" r="1.5" fill="#FFFFFF" /><path d="M -3 2 Q 0 5 3 2" fill="none" stroke="#4A3219" stroke-width="1.5" stroke-linecap="round" /><ellipse cx="-11" cy="3" rx="3.5" ry="2" fill="#FF8DA1" opacity="0.8" />
                   <ellipse cx="11" cy="3" rx="3.5" ry="2" fill="#FF8DA1" opacity="0.8" /></g>
  
</svg>''',
  'seal-handcrafted-daily': r'''<svg viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">

    <circle cx="50" cy="50" r="48" fill="#FFFFFF" />
    <circle cx="50" cy="50" r="44" fill="#D6EAF8" stroke="#4A3219" stroke-width="3" />
    <circle cx="50" cy="50" r="39" stroke="#4A3219" stroke-width="2" stroke-dasharray="1 5" stroke-linecap="round" opacity="0.6" />

    <path id="curve-hc-top" d="M 17 50 A 33 33 0 0 1 83 50" fill="none" />
    <path id="curve-hc-bot" d="M 10 50 A 40 40 0 0 0 90 50" fill="none" />
    <text fill="#2980B9" font-size="8.5" font-weight="900" font-family="system-ui, sans-serif" letter-spacing="1">
      <textPath href="#curve-hc-top" start-offset="50%" text-anchor="middle">HANDCRAFTED</textPath>
    </text>
    <text fill="#2980B9" font-size="7" font-weight="800" font-family="system-ui, sans-serif" letter-spacing="1">
      <textPath href="#curve-hc-bot" start-offset="50%" text-anchor="middle">&#8226; FRESH DAILY &#8226;</textPath>
    </text>

    
    <g stroke="#4A3219" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
      <path d="M 60 40 L 73 24" fill="none" />
      <ellipse cx="73" cy="24" rx="4" ry="7" fill="#FDEBD0" transform="rotate(45 73 24)" />
      <path d="M 28 40 L 72 40 C 72 65 28 65 28 40 Z" fill="#85C1E9" />
    </g>
    <g transform="translate(50.0, 49.0) scale(0.7)"><circle cx="-6" cy="0" r="3.5" fill="#4A3219" />
                       <circle cx="-7.5" cy="-1.5" r="1.5" fill="#FFFFFF" />
                       <circle cx="6" cy="0" r="3.5" fill="#4A3219" />
                       <circle cx="4.5" cy="-1.5" r="1.5" fill="#FFFFFF" /><path d="M -3.5 2 Q 0 7 3.5 2 Z" fill="#FF8DA1" stroke="#4A3219" stroke-width="1.5" stroke-linejoin="round" /><ellipse cx="-11" cy="3" rx="3.5" ry="2" fill="#FF8DA1" opacity="0.8" />
                   <ellipse cx="11" cy="3" rx="3.5" ry="2" fill="#FF8DA1" opacity="0.8" /></g>
  
</svg>''',
  'stamp-al-dente': r'''<svg viewBox="0 0 120 90" fill="none" xmlns="http://www.w3.org/2000/svg">

    
    <ellipse cx="60" cy="45" rx="55" ry="40" fill="#FFFFFF" />
    <ellipse cx="60" cy="45" rx="51" ry="36" fill="#FCF3CF" stroke="#4A3219" stroke-width="3" />
    <ellipse cx="60" cy="45" rx="46" ry="31" stroke="#4A3219" stroke-width="2" stroke-dasharray="2 6" stroke-linecap="round" opacity="0.6" />

    <text x="60" y="27" text-anchor="middle" fill="#B7950B" font-size="7" font-weight="900" font-family="system-ui, sans-serif" letter-spacing="1.5">
      &#8226; CERTIFIED &#8226;
    </text>
    <text x="60" y="70" text-anchor="middle" fill="#B7950B" font-size="6.5" font-weight="800" font-family="system-ui, sans-serif" letter-spacing="1">
      AL DENTE PERFEZIONE
    </text>

    
    <g stroke="#4A3219" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
      <path d="M 38 32 L 38 58 C 50 54 70 54 82 58 L 82 32 C 70 36 50 36 38 32 Z" fill="#F9E79F" />
      
      <path d="M 38 32 Q 34 35 38 38 Q 34 41 38 45 Q 34 49 38 52 Q 34 55 38 58" fill="none" />
      <path d="M 82 32 Q 86 35 82 38 Q 86 41 82 45 Q 86 49 82 52 Q 86 55 82 58" fill="none" />
      
      <path d="M 57 40 L 57 50" fill="none" stroke-width="2" opacity="0.4" />
      <path d="M 63 40 L 63 50" fill="none" stroke-width="2" opacity="0.4" />
    </g>
    <g transform="translate(60.0, 47.0) scale(0.8)"><circle cx="-6" cy="0" r="3.5" fill="#4A3219" />
                       <circle cx="-7.5" cy="-1.5" r="1.5" fill="#FFFFFF" />
                       <circle cx="6" cy="0" r="3.5" fill="#4A3219" />
                       <circle cx="4.5" cy="-1.5" r="1.5" fill="#FFFFFF" /><path d="M -3 2 Q 0 5 3 2" fill="none" stroke="#4A3219" stroke-width="1.5" stroke-linecap="round" /><ellipse cx="-11" cy="3" rx="3.5" ry="2" fill="#FF8DA1" opacity="0.8" />
                   <ellipse cx="11" cy="3" rx="3.5" ry="2" fill="#FF8DA1" opacity="0.8" /></g>
  
</svg>''',
  'stamp-slow-simmer': r'''<svg viewBox="0 0 120 90" fill="none" xmlns="http://www.w3.org/2000/svg">

    
    <rect x="5" y="5" width="110" height="80" rx="15" fill="#FFFFFF" />
    <rect x="9" y="9" width="102" height="72" rx="12" fill="#FAD7A1" stroke="#4A3219" stroke-width="3" />
    <rect x="15" y="15" width="90" height="60" rx="8" stroke="#4A3219" stroke-width="2" stroke-dasharray="2 6" stroke-linecap="round" opacity="0.6" />

    <text x="60" y="27" text-anchor="middle" fill="#D35400" font-size="7" font-weight="900" font-family="system-ui, sans-serif" letter-spacing="1.5">
      SLOW SIMMERED
    </text>
    <text x="60" y="69" text-anchor="middle" fill="#D35400" font-size="6.5" font-weight="800" font-family="system-ui, sans-serif" letter-spacing="1">
      LOW & GENTLE HEAT
    </text>

    
    <g stroke="#4A3219" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
      <path d="M 33 46 C 25 46 25 54 33 54" fill="none" />
      <path d="M 87 46 C 95 46 95 54 87 54" fill="none" />
      <path d="M 38 42 L 82 42 C 82 66 38 66 38 42 Z" fill="#E74C3C" />
      <path d="M 35 38 Q 60 28 85 38 L 85 41 L 35 41 Z" fill="#C0392B" />
      <path d="M 55 31 L 65 31" fill="none" stroke-width="3" />
      
      <path d="M 45 28 Q 50 20 45 15" fill="none" stroke-width="2" stroke="#FFFFFF" opacity="0.8" />
      <path d="M 75 28 Q 70 20 75 15" fill="none" stroke-width="2" stroke="#FFFFFF" opacity="0.8" />
    </g>
    <g transform="translate(60.0, 51.0) scale(0.7)"><path d="M -9 0 Q -6 3 -3 0" fill="none" stroke="#4A3219" stroke-width="2" stroke-linecap="round" />
                       <path d="M 3 0 Q 6 3 9 0" fill="none" stroke="#4A3219" stroke-width="2" stroke-linecap="round" /><path d="M -3 2 Q 0 5 3 2" fill="none" stroke="#4A3219" stroke-width="1.5" stroke-linecap="round" /><ellipse cx="-11" cy="3" rx="3.5" ry="2" fill="#FF8DA1" opacity="0.8" />
                   <ellipse cx="11" cy="3" rx="3.5" ry="2" fill="#FF8DA1" opacity="0.8" /></g>
  
</svg>''',
  'stamp-secret-recipe': r'''<svg viewBox="0 0 130 80" fill="none" xmlns="http://www.w3.org/2000/svg">

    <rect x="4" y="4" width="122" height="72" rx="12" fill="#FFFFFF" />
    <rect x="8" y="8" width="114" height="64" rx="8" fill="#D1F2EB" stroke="#4A3219" stroke-width="3" />
    <rect x="14" y="14" width="102" height="52" rx="5" stroke="#4A3219" stroke-width="2" stroke-dasharray="2 6" stroke-linecap="round" opacity="0.6" />

    <text x="65" y="27" text-anchor="middle" fill="#16A085" font-size="7" font-weight="900" font-family="system-ui, sans-serif" letter-spacing="1.5">
      CONFIDENTIAL
    </text>
    <text x="65" y="65" text-anchor="middle" fill="#16A085" font-size="6.5" font-weight="800" font-family="system-ui, sans-serif" letter-spacing="1">
      &#8226; DO NOT SHARE &#8226;
    </text>

    
    <g stroke="#4A3219" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
      <path d="M 38 31 L 92 31 C 100 31 100 41 92 41 L 38 41 C 30 41 30 31 38 31 Z" fill="#F5CBA7" />
      <path d="M 42 41 L 42 54 C 42 62 88 62 88 54 L 88 41 Z" fill="#FAE5D3" />
      
      <rect x="61" y="47" width="8" height="6" rx="1.5" fill="#F1C40F" />
      <path d="M 62.5 47 L 62.5 44 C 62.5 41 67.5 41 67.5 44 L 67.5 47" fill="none" stroke-width="1.5" />
    </g>
    <g transform="translate(65.0, 36.0) scale(0.65)"><circle cx="-6" cy="0" r="3" fill="#4A3219" />
                       <circle cx="-7" cy="-1.5" r="1.5" fill="#FFFFFF" />
                       <path d="M 3 -1 Q 6 2 9 -1" fill="none" stroke="#4A3219" stroke-width="2" stroke-linecap="round" /><path d="M -3 2 Q 0 5 3 2" fill="none" stroke="#4A3219" stroke-width="1.5" stroke-linecap="round" /><ellipse cx="-11" cy="3" rx="3.5" ry="2" fill="#FF8DA1" opacity="0.8" />
                   <ellipse cx="11" cy="3" rx="3.5" ry="2" fill="#FF8DA1" opacity="0.8" /></g>
  
</svg>''',
};
