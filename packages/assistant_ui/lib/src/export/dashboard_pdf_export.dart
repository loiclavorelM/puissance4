import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Export du tableau de bord en PDF : chaque widget est capturé tel qu'il
/// est affiché (graphiques compris, aux couleurs du thème), puis les images
/// sont mises en page sur A4. La grille pose [capture] autour de chaque
/// widget ; [build] lit ensuite ces captures.
class DashboardPdfExport {
  final _keys = <String, GlobalKey>{};

  /// Rend [child] capturable sous l'identifiant [id] du widget.
  Widget capture(String id, Widget child) =>
      RepaintBoundary(key: _keys.putIfAbsent(id, GlobalKey.new), child: child);

  /// Le PDF des [widgets] (dans cet ordre) qui sont affichés, sous [title]
  /// et [subtitle] (date, filtres). Un widget pas encore construit est
  /// ignoré.
  Future<Uint8List> build({
    required String title,
    required String subtitle,
    required List<WidgetDefinition> widgets,
    double pixelRatio = 2,
  }) async {
    final images = <Uint8List>[];
    for (final widget in widgets) {
      final boundary = _keys[widget.id]?.currentContext?.findRenderObject();
      if (boundary is! RenderRepaintBoundary) continue;
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (png != null) images.add(png.buffer.asUint8List());
    }

    final document = pw.Document(title: title);
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (_) => [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            subtitle,
            style: const pw.TextStyle(color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 16),
          for (final png in images) ...[
            // Hauteur bornée : une image plus haute qu'une page ne peut pas
            // être coupée par MultiPage.
            pw.Center(
              child: pw.ConstrainedBox(
                constraints: const pw.BoxConstraints(maxHeight: 340),
                child: pw.Image(pw.MemoryImage(png), fit: pw.BoxFit.contain),
              ),
            ),
            pw.SizedBox(height: 12),
          ],
        ],
      ),
    );
    return document.save();
  }
}
