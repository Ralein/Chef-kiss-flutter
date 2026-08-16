import 'package:flutter/material.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:design_tokens/design_tokens.dart';
import '../../../app/audio_chime_service.dart';

class StickerTrayModal extends StatefulWidget {
  final String targetPageSide; // 'left' | 'right'
  final ValueChanged<String> onTargetPageSideChanged;
  final ValueChanged<ScrapbookSticker> onAddSticker;
  final ValueChanged<WashiTapeDecoration> onAddWashiTape;

  const StickerTrayModal({
    super.key,
    required this.targetPageSide,
    required this.onTargetPageSideChanged,
    required this.onAddSticker,
    required this.onAddWashiTape,
  });

  @override
  State<StickerTrayModal> createState() => _StickerTrayModalState();
}

class _StickerTrayModalState extends State<StickerTrayModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String _currentPageSide;

  // Custom Ink Badge Creator State
  final TextEditingController _customBadgeController = TextEditingController(text: "Grandma's Secret");
  String _selectedShape = 'oval';
  Color _selectedInkColor = const Color(0xFFC85A32);
  Color _selectedInkBg = const Color(0xFFFBF0EB);

  final List<Map<String, dynamic>> _inkPalettes = [
    {'name': 'Terracotta', 'color': const Color(0xFFC85A32), 'bg': const Color(0xFFFBF0EB)},
    {'name': 'Sage Olive', 'color': const Color(0xFF4A6B53), 'bg': const Color(0xFFEEF4F0)},
    {'name': 'Golden Honey', 'color': const Color(0xFFD9822B), 'bg': const Color(0xFFFEF8EB)},
    {'name': 'Artisan Kraft', 'color': const Color(0xFF8C7355), 'bg': const Color(0xFFF5EFEB)},
    {'name': 'Charcoal Ink', 'color': const Color(0xFF1E1A18), 'bg': const Color(0xFFF6F2EB)},
    {'name': 'Merlot Wine', 'color': const Color(0xFF8C2D3A), 'bg': const Color(0xFFFBEFF1)},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _currentPageSide = widget.targetPageSide;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _customBadgeController.dispose();
    super.dispose();
  }

  void _handlePlaceStamp(CulinaryStampDef stamp) {
    audioChime.playTap();
    final now = DateTime.now().millisecondsSinceEpoch;
    final sticker = ScrapbookSticker(
      id: 'stk-$now',
      content: stamp.id,
      type: stamp.category,
      iconId: stamp.id,
      label: stamp.name,
      pageSide: _currentPageSide,
      x: _currentPageSide == 'left' ? 45.0 : 55.0,
      y: 35.0,
      rotation: stamp.defaultRotation,
      scale: 1.0,
    );
    widget.onAddSticker(sticker);
    Navigator.of(context).pop();
  }

  void _handlePlaceWashiTape(WashiTapePattern pattern) {
    audioChime.playTap();
    final now = DateTime.now().millisecondsSinceEpoch;
    final tape = WashiTapeDecoration(
      id: 'wash-$now',
      pattern: pattern.name,
      pageSide: _currentPageSide,
      x: _currentPageSide == 'left' ? 30.0 : 70.0,
      y: 20.0,
      width: 75.0,
      rotation: -0.05,
    );
    widget.onAddWashiTape(tape);
    Navigator.of(context).pop();
  }

  void _handlePlaceCustomBadge() {
    if (_customBadgeController.text.trim().isEmpty) return;
    audioChime.playTap();
    final now = DateTime.now().millisecondsSinceEpoch;
    final sticker = ScrapbookSticker(
      id: 'stk-$now',
      content: _customBadgeController.text.trim(),
      type: 'badge',
      label: _customBadgeController.text.trim(),
      color: '#${_selectedInkColor.toARGB32().toRadixString(16).substring(2)}',
      bgColor: '#${_selectedInkBg.toARGB32().toRadixString(16).substring(2)}',
      pageSide: _currentPageSide,
      x: _currentPageSide == 'left' ? 50.0 : 50.0,
      y: 30.0,
      rotation: -0.03,
      scale: 1.0,
    );
    widget.onAddSticker(sticker);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: Color(0xFFFAF7F2),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle & Top Bar
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 8),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6CBBF),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.style_outlined, size: 20, color: Color(0xFFC85A32)),
                        SizedBox(width: 8),
                        Text(
                          'STICKERS & WASHI TAPES',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1E1A18),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),

                    // Target Page Selector (Left Page vs Right Page)
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE5D8),
                        borderRadius: BorderRadius.circular(ChefRadius.pill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildSideButton('left', '1. Mise en Place'),
                          _buildSideButton('right', '2. Method Steps'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Categories TabBar
          Container(
            color: const Color(0xFFF3ECE1),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: const Color(0xFFC85A32),
              unselectedLabelColor: const Color(0xFF6B625B),
              indicatorColor: const Color(0xFFC85A32),
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
              unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(icon: Icon(Icons.markunread_mailbox_outlined, size: 16), text: 'Postage'),
                Tab(icon: Icon(Icons.draw_outlined, size: 16), text: 'Food Doodles'),
                Tab(icon: Icon(Icons.stars_outlined, size: 16), text: 'Wax Seals'),
                Tab(icon: Icon(Icons.texture, size: 16), text: 'Washi Tapes'),
                Tab(icon: Icon(Icons.verified_outlined, size: 16), text: 'Custom Badge'),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. Postage Stamps
                _buildGridTab(
                  items: postageStampDefs,
                  onSelect: _handlePlaceStamp,
                ),

                // 2. Food Doodles
                _buildGridTab(
                  items: foodDoodleDefs,
                  onSelect: _handlePlaceStamp,
                ),

                // 3. Wax Seals
                _buildGridTab(
                  items: waxSealDefs,
                  onSelect: _handlePlaceStamp,
                ),

                // 4. Washi Tapes
                _buildWashiTapeTab(),

                // 5. Custom Ink Badge Creator
                _buildCustomBadgeTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideButton(String side, String label) {
    final isSelected = _currentPageSide == side;

    return GestureDetector(
      onTap: () {
        audioChime.playTap();
        setState(() => _currentPageSide = side);
        widget.onTargetPageSideChanged(side);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFC85A32) : Colors.transparent,
          borderRadius: BorderRadius.circular(ChefRadius.pill),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: isSelected ? Colors.white : const Color(0xFF6B625B),
          ),
        ),
      ),
    );
  }

  Widget _buildGridTab({
    required List<CulinaryStampDef> items,
    required ValueChanged<CulinaryStampDef> onSelect,
  }) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return GridView.builder(
      padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: bottomInset + 32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: items.length,
      itemBuilder: (context, idx) {
        final stamp = items[idx];
        return InkWell(
          onTap: () => onSelect(stamp),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8E0D2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Center(child: stamp.builder(size: 56))),
                const SizedBox(height: 4),
                Text(
                  stamp.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF1E1A18)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWashiTapeTab() {
    final patterns = WashiTapePattern.values;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return GridView.builder(
      padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: bottomInset + 32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.0,
      ),
      itemCount: patterns.length,
      itemBuilder: (context, idx) {
        final pattern = patterns[idx];
        return InkWell(
          onTap: () => _handlePlaceWashiTape(pattern),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE8E0D2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WashiTape(
                  width: 90,
                  height: 16,
                  pattern: pattern,
                  rotation: 0,
                ),
                const SizedBox(height: 6),
                Text(
                  pattern.name.toUpperCase(),
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF1E1A18)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomBadgeTab() {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: bottomInset + 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create Artisan Ink Badge',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF1E1A18)),
          ),
          const SizedBox(height: 12),

          // Badge Live Preview
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: _selectedInkBg,
                borderRadius: _selectedShape == 'oval' ? BorderRadius.circular(24) : BorderRadius.circular(8),
                border: Border.all(color: _selectedInkColor, width: 1.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.stars, size: 16, color: _selectedInkColor),
                  const SizedBox(width: 6),
                  Text(
                    _customBadgeController.text.trim().isEmpty ? "Grandma's Secret" : _customBadgeController.text.trim(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: _selectedInkColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Label Input
          TextField(
            controller: _customBadgeController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Badge Text',
              labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF6B625B)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE8E0D2)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Shape Selector
          const Text('Badge Shape', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1E1A18))),
          const SizedBox(height: 8),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Oval Ink Stamp'),
                selected: _selectedShape == 'oval',
                selectedColor: const Color(0xFFC85A32),
                labelStyle: TextStyle(color: _selectedShape == 'oval' ? Colors.white : const Color(0xFF1E1A18)),
                onSelected: (_) => setState(() => _selectedShape = 'oval'),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Vintage Crest'),
                selected: _selectedShape == 'rect',
                selectedColor: const Color(0xFFC85A32),
                labelStyle: TextStyle(color: _selectedShape == 'rect' ? Colors.white : const Color(0xFF1E1A18)),
                onSelected: (_) => setState(() => _selectedShape = 'rect'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Ink Color Palette
          const Text('Ink & Paper Palette', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1E1A18))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _inkPalettes.map((palette) {
              final isSelected = _selectedInkColor == palette['color'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedInkColor = palette['color'] as Color;
                    _selectedInkBg = palette['bg'] as Color;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: palette['bg'] as Color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFC85A32) : const Color(0xFFE8E0D2),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: palette['color'] as Color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        palette['name'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: palette['color'] as Color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Place Badge Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC85A32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Place Badge on Page', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
              onPressed: _handlePlaceCustomBadge,
            ),
          ),
        ],
      ),
    );
  }
}
