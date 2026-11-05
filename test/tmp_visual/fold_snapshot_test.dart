import 'dart:io';
import 'dart:ui' as ui;

import 'package:chefs_kiss/features/journal/presentation/widgets/page_flip_book.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _page(int i) => Container(
      color: i.isEven ? const Color(0xFFFDFAF4) : const Color(0xFFF7F1E6),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 120, color: [Colors.teal, Colors.orange, Colors.indigo, Colors.red, Colors.green, Colors.purple][i % 6].withValues(alpha: 0.7)),
          const SizedBox(height: 16),
          for (var l = 0; l < 14; l++) ...[
            Container(height: 8, width: 200.0 + (l * 37 % 90), color: Colors.black.withValues(alpha: 0.25)),
            const SizedBox(height: 10),
          ],
          Text('Page $i', style: const TextStyle(fontSize: 22, color: Colors.black)),
        ],
      ),
    );

Future<void> _snap(WidgetTester tester, GlobalKey key, String name) async {
  final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await tester.runAsync(() => boundary.toImage(pixelRatio: 1));
  final bytes = await tester.runAsync(() => image!.toByteData(format: ui.ImageByteFormat.png));
  File('${Platform.environment['SNAP_DIR']}/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  for (final spread in [false, true]) {
    testWidgets('fold snapshot spread=$spread', (tester) async {
      final key = GlobalKey();
      final controller = PageFlipController(initialPosition: spread ? 1 : 2);
      tester.view.physicalSize = Size(spread ? 1000 : 400, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFF3A2B22),
          body: Center(
            child: RepaintBoundary(
              key: key,
              child: Container(
                color: const Color(0xFF3A2B22),
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: spread ? 960 : 360,
                  height: 600,
                  child: PageFlipBook(controller: controller, spread: spread, pageCount: 8, pageBuilder: (_, i) => _page(i)),
                ),
              ),
            ),
          ),
        ),
      ));
      controller.next();
      for (final (ms, tag) in [(160, 'a'), (300, 'b'), (440, 'c')]) {
        await tester.pump(Duration(milliseconds: ms == 160 ? 160 : 140));
        await _snap(tester, key, 'fold_${spread ? 'spread' : 'single'}_$tag');
      }
      await tester.pumpAndSettle();
    });
  }
}
