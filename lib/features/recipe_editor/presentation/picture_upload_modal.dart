import 'package:flutter/material.dart';
import '../../../app/audio_chime_service.dart';

class PictureUploadModal extends StatefulWidget {
  final String? initialImage;
  final String? initialCaption;
  final double? initialRotation;
  final void Function(String imagePath, String caption, double rotation) onSave;

  const PictureUploadModal({
    super.key,
    this.initialImage,
    this.initialCaption,
    this.initialRotation,
    required this.onSave,
  });

  @override
  State<PictureUploadModal> createState() => _PictureUploadModalState();
}

class _PictureUploadModalState extends State<PictureUploadModal> with SingleTickerProviderStateMixin {
  late String _selectedImage;
  late TextEditingController _captionController;
  late TextEditingController _urlController;
  late double _rotation;
  late TabController _tabController;

  final List<Map<String, String>> _illustrations = [
    {'name': 'Artisanal Pasta', 'path': 'assets/illustrations/sketchbook_pasta.jpg'},
    {'name': 'French Crêpes', 'path': 'assets/illustrations/sketchbook_crepes.jpg'},
    {'name': 'Avocado Toast', 'path': 'assets/illustrations/sketchbook_salad.jpg'},
    {'name': 'Tokyo Ramen', 'path': 'assets/illustrations/sketchbook_ramen.jpg'},
    {'name': 'Country Sourdough', 'path': 'assets/illustrations/sketchbook_sourdough.jpg'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.initialImage ?? 'assets/illustrations/sketchbook_pasta.jpg';
    _captionController = TextEditingController(text: widget.initialCaption ?? 'Handmade Recipe Note');
    _urlController = TextEditingController();
    _rotation = widget.initialRotation ?? -2.0;
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _captionController.dispose();
    _urlController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _handleSave() {
    audioChime.playTap();
    final caption = _captionController.text.trim().isEmpty ? 'Handmade Recipe Note' : _captionController.text.trim();
    widget.onSave(_selectedImage, caption, _rotation);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: bottomInset + 16),
      decoration: const BoxDecoration(
        color: Color(0xFFFAF7F2),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle & Header
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
                  Icon(Icons.camera_alt, color: Color(0xFFC85A32), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'POLAROID PHOTO & CAPTION',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E1A18),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20, color: Color(0xFF6B625B)),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          // Live Polaroid Tilt Preview
          Center(
            child: Transform.rotate(
              angle: _rotation * (3.14159 / 180),
              child: Container(
                width: 140,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFE8E0D2), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: AspectRatio(
                        aspectRatio: 4 / 3,
                        child: _selectedImage.startsWith('http')
                            ? Image.network(
                                _selectedImage,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 30),
                              )
                            : Image.asset(
                                _selectedImage,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.restaurant_menu, size: 30, color: Color(0xFFC85A32)),
                              ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _captionController.text.isEmpty ? 'Handmade Note' : _captionController.text,
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF1E1A18), fontStyle: FontStyle.italic),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Tabs: Sketchbook Artworks vs Photo Link / URL
          Container(
            color: const Color(0xFFEDE5D8),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFFC85A32),
              unselectedLabelColor: const Color(0xFF6B625B),
              indicatorColor: const Color(0xFFC85A32),
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
              tabs: const [
                Tab(icon: Icon(Icons.collections, size: 14), text: 'Artworks'),
                Tab(icon: Icon(Icons.link, size: 14), text: 'Photo URL / Link'),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. Sketchbook Artworks
                ListView(
                  padding: const EdgeInsets.only(top: 12),
                  children: [
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _illustrations.length,
                        itemBuilder: (context, idx) {
                          final item = _illustrations[idx];
                          final isSelected = _selectedImage == item['path'];

                          return GestureDetector(
                            onTap: () {
                              audioChime.playTap();
                              setState(() => _selectedImage = item['path']!);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFFC85A32) : const Color(0xFFE8E0D2),
                                  width: isSelected ? 2.5 : 1,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Image.asset(item['path']!, fit: BoxFit.cover),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                // 2. Photo URL Link
                ListView(
                  padding: const EdgeInsets.only(top: 12),
                  children: [
                    TextField(
                      controller: _urlController,
                      style: const TextStyle(color: Color(0xFF1E1A18), fontWeight: FontWeight.w700, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Paste Image Link (https://...)',
                        labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF6B625B)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.check_circle, color: Color(0xFFC85A32)),
                          onPressed: () {
                            if (_urlController.text.trim().startsWith('http')) {
                              setState(() => _selectedImage = _urlController.text.trim());
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Caption Text Input
          const Text('Polaroid Caption Text', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E1A18))),
          const SizedBox(height: 6),
          TextField(
            controller: _captionController,
            style: const TextStyle(color: Color(0xFF1E1A18), fontWeight: FontWeight.w800, fontSize: 13),
            cursorColor: const Color(0xFFC85A32),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'e.g. French Crêpes Suzette...',
              hintStyle: const TextStyle(color: Color(0xFF8C827A)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 10),

          // Tilt Angle Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Polaroid Tilt Angle', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E1A18))),
              Text('${_rotation.toStringAsFixed(1)}°', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFFC85A32))),
            ],
          ),
          Slider(
            value: _rotation,
            min: -15.0,
            max: 15.0,
            divisions: 30,
            activeColor: const Color(0xFFC85A32),
            onChanged: (val) => setState(() => _rotation = val),
          ),
          const SizedBox(height: 12),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC85A32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Save Polaroid Changes', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
              onPressed: _handleSave,
            ),
          ),
        ],
      ),
    );
  }
}
