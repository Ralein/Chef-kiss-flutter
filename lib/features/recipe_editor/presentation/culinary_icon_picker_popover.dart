import 'package:flutter/material.dart';
import 'package:design_tokens/design_tokens.dart';
import '../../../app/audio_chime_service.dart';

class CulinaryIconPickerModal extends StatefulWidget {
  final String? currentIcon;
  final String? currentColor;
  final void Function(String iconKey, String colorHex) onIconSelected;

  const CulinaryIconPickerModal({
    super.key,
    this.currentIcon,
    this.currentColor,
    required this.onIconSelected,
  });

  @override
  State<CulinaryIconPickerModal> createState() => _CulinaryIconPickerModalState();
}

class _CulinaryIconPickerModalState extends State<CulinaryIconPickerModal> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  late String _selectedColor;

  final List<String> _colors = [
    '#C85A32', // Terracotta
    '#4A6B53', // Sage Olive
    '#D9822B', // Golden Honey
    '#8C7355', // Artisan Kraft
    '#1E1A18', // Charcoal Ink
    '#8C2D3A', // Merlot Wine
    '#3B7EA1', // Nordic Slate
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.currentColor ?? '#C85A32';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _hexToColor(String hex) {
    final clean = hex.replaceAll('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final categories = [
      'All',
      'Produce & Garden',
      'Bakery & Grains',
      'Proteins & Seafood',
      'Sweets & Treats',
      'Drinks & Beverages',
      'Cookware & Prep',
      'Quality Badges',
    ];

    final query = _searchController.text.trim().toLowerCase();
    final filtered = culinaryIconsCatalog.where((item) {
      final matchesQuery = query.isEmpty || item.label.toLowerCase().contains(query) || item.key.toLowerCase().contains(query);
      if (!matchesQuery) return false;
      if (_selectedCategory != 'All') {
        return item.category == _selectedCategory;
      }
      return true;
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      padding: EdgeInsets.only(bottom: bottomInset + 16),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1A18),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header & Drag handle
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5C534D),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'CULINARY ICON & COLOR PICKER',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20, color: Colors.white70),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Color Palette Swatches
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Ink Tone: ',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFD6CBBF)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _colors.map((cHex) {
                        final isSelected = _selectedColor.toLowerCase() == cHex.toLowerCase();
                        final c = _hexToColor(cHex);
                        return GestureDetector(
                          onTap: () {
                            audioChime.playTap();
                            setState(() => _selectedColor = cHex);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.white24,
                                width: isSelected ? 3 : 1.5,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: c.withValues(alpha: 0.6),
                                    blurRadius: 8,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Search Bar with High Contrast
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: Color(0xFF1E1A18), fontWeight: FontWeight.w700, fontSize: 13),
              cursorColor: const Color(0xFFC85A32),
              decoration: InputDecoration(
                hintText: 'Search icon (e.g. wheat, tomato, whisk, egg, coffee)...',
                hintStyle: const TextStyle(color: Color(0xFF6B625B), fontSize: 12),
                prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFFC85A32)),
                filled: true,
                fillColor: const Color(0xFFFCFAF7),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE8E0D2)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : const Color(0xFFD6CBBF),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFFC85A32),
                    backgroundColor: const Color(0xFF2C2623),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFFC85A32) : const Color(0xFF5C534D),
                      ),
                    ),
                    onSelected: (_) {
                      audioChime.playTap();
                      setState(() => _selectedCategory = cat);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),

          // Icons Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.95,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, idx) {
                final item = filtered[idx];
                final isSelected = widget.currentIcon == item.key;
                final activeTint = _hexToColor(_selectedColor);

                return InkWell(
                  onTap: () {
                    audioChime.playTap();
                    widget.onIconSelected(item.key, _selectedColor);
                    Navigator.of(context).pop();
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFAF7F2) : const Color(0xFFFCFAF7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? activeTint : const Color(0xFFE8E0D2),
                        width: isSelected ? 2.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item.icon, size: 26, color: activeTint),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E1A18),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
