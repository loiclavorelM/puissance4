import 'dart:convert';
import 'dart:ui' as ui;

import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../labels.dart';
import '../widgets/cross_table.dart';

/// Captures d'écran des corps de widgets, pour mettre un graphique tel
/// qu'il est affiché dans son export PDF. La grille pose [capture] autour
/// du corps de chaque widget.
class WidgetCaptures {
  final _keys = <String, GlobalKey>{};

  Widget capture(String id, Widget child) =>
      RepaintBoundary(key: _keys.putIfAbsent(id, GlobalKey.new), child: child);

  /// Image PNG du widget [id], ou `null` s'il n'est pas affiché.
  Future<Uint8List?> png(String id, {double pixelRatio = 3}) async {
    final boundary = _keys[id]?.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary) return null;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return bytes?.buffer.asUint8List();
  }
}

/// Export d'un seul widget, avec ses données : un PDF mis en page (titre,
/// contexte, chiffre clé / graphique et ses données / tableau, pied de page)
/// ou un CSV lisible par un tableur.
class WidgetExport {
  WidgetExport({
    required this.definition,
    required this.data,
    required this.labels,
    required this.scope,
    this.chartImage,
    DateTime? now,
  }) : now = now ?? DateTime.now();

  final WidgetDefinition definition;
  final SourceData data;
  final DashboardLabels labels;

  /// Ce qui situe les chiffres : période, mode, adversaire…
  final String scope;

  /// Le graphique tel qu'affiché ([WidgetCaptures.png]).
  final Uint8List? chartImage;
  final DateTime now;

  static const _accent = PdfColor.fromInt(0xFF4F46E5);
  static const _muted = PdfColors.grey700;

  String get _date => DateFormat.yMMMMd(labels.language).add_Hm().format(now);

  /// `puissance4-<titre>-<date>.<extension>`.
  String fileName(String extension) {
    final slug = definition.title
        .toLowerCase()
        .replaceAll(RegExp('[àâä]'), 'a')
        .replaceAll(RegExp('[éèêë]'), 'e')
        .replaceAll(RegExp('[îï]'), 'i')
        .replaceAll(RegExp('[ôö]'), 'o')
        .replaceAll(RegExp('[ùûü]'), 'u')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp('[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    final day = now.toIso8601String().substring(0, 10);
    return 'puissance4-${slug.isEmpty ? 'widget' : slug}-$day.$extension';
  }

  // ---------------------------------------------------------------- CSV

  /// CSV en UTF-8 (avec BOM, pour Excel) ; séparateur `;` en français, comme
  /// l'attend un tableur réglé en français, `,` sinon.
  Uint8List csv() {
    final separator = labels.language == 'fr' ? ';' : ',';
    final lines = [
      for (final row in _csvRows())
        row.map((cell) => _escape(cell, separator)).join(separator),
    ];
    return Uint8List.fromList(utf8.encode('﻿${lines.join('\r\n')}\r\n'));
  }

  List<List<String>> _csvRows() => switch (data) {
    KpiData(:final value, :final unit, :final delta, :final secondary) => [
      [labels.l10n.exportIndicator, labels.l10n.exportValue],
      [definition.title, '${value ?? ''}${unit == null ? '' : ' $unit'}'],
      if (delta != null) [labels.l10n.exportDelta, _signed(delta)],
      if (secondary != null) [labels.l10n.exportGames, '$secondary'],
    ],
    final DataSet rows => switch (CrossTable.of(definition, rows)) {
      final cross? => [
        [
          labels.field(cross.rowField),
          for (final column in cross.columnKeys)
            labels.value(cross.columnField, column),
        ],
        for (final row in cross.rowKeys)
          [
            labels.value(cross.rowField, row),
            for (final column in cross.columnKeys)
              '${cross.cell(row, column) ?? ''}',
          ],
      ],
      null => [
        [for (final i in _columns(rows)) labels.field(rows.fields[i].name)],
        for (final row in rows.rows)
          [for (final i in _columns(rows)) _csvValue(rows.fields[i], row[i])],
      ],
    },
  };

  /// Nombres bruts et dates complètes pour le tableur ; catégories
  /// traduites (Victoire, Classé…).
  String _csvValue(DataField field, Object? value) {
    if (value == null) return '';
    switch (field.type) {
      case FieldType.number:
        return '$value';
      case FieldType.temporal:
        final date = DateTime.tryParse('$value');
        if (date == null) return '$value';
        return '$value'.length > 10
            ? DateFormat('yyyy-MM-dd HH:mm').format(date.toLocal())
            : DateFormat('yyyy-MM-dd').format(date);
      case FieldType.category:
        return labels.value(field.name, value);
    }
  }

  static String _escape(String cell, String separator) =>
      cell.contains(separator) ||
          cell.contains('"') ||
          cell.contains('\n') ||
          cell.contains('\r')
      ? '"${cell.replaceAll('"', '""')}"'
      : cell;

  // ---------------------------------------------------------------- PDF

  Future<Uint8List> pdf() async {
    final theme = pw.ThemeData.withFont(
      base: await _font('NotoSans-Regular.ttf'),
      bold: await _font('NotoSans-Bold.ttf'),
    );
    final document = pw.Document(title: definition.title, theme: theme);
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(40, 36, 40, 32),
        header: (context) => context.pageNumber == 1
            ? pw.SizedBox()
            : pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 12),
                child: pw.Text(
                  definition.title,
                  style: const pw.TextStyle(fontSize: 9, color: _muted),
                ),
              ),
        footer: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(top: 8),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              top: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                labels.l10n.exportFooter(_date),
                style: const pw.TextStyle(fontSize: 8, color: _muted),
              ),
              pw.Text(
                '${context.pageNumber} / ${context.pagesCount}',
                style: const pw.TextStyle(fontSize: 8, color: _muted),
              ),
            ],
          ),
        ),
        build: (_) => [
          pw.Text(
            'PUISSANCE 4',
            style: pw.TextStyle(
              fontSize: 9,
              letterSpacing: 2,
              color: _accent,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            definition.title,
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            [labels.source(definition.query.source), scope].join(' · '),
            style: const pw.TextStyle(fontSize: 10, color: _muted),
          ),
          pw.SizedBox(height: 20),
          ..._body(),
        ],
      ),
    );
    return document.save();
  }

  /// Police embarquée : clé `packages/assistant_ui/...` depuis l'app, sans
  /// préfixe dans les tests du package lui-même.
  static Future<pw.Font> _font(String file) async {
    try {
      return pw.Font.ttf(
        await rootBundle.load('packages/assistant_ui/assets/fonts/$file'),
      );
    } on FlutterError {
      return pw.Font.ttf(await rootBundle.load('assets/fonts/$file'));
    }
  }

  List<pw.Widget> _body() => switch (data) {
    final KpiData kpi => [_kpi(kpi)],
    final DataSet rows when definition.type == WidgetType.chart => [
      if (chartImage case final image?) ...[
        pw.Container(
          alignment: pw.Alignment.center,
          constraints: const pw.BoxConstraints(maxHeight: 340),
          child: pw.ClipRRect(
            horizontalRadius: 8,
            verticalRadius: 8,
            child: pw.Image(pw.MemoryImage(image), fit: pw.BoxFit.contain),
          ),
        ),
        pw.SizedBox(height: 20),
      ],
      pw.Text(
        labels.l10n.exportData,
        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 8),
      _table(rows),
    ],
    final DataSet rows => [_table(rows)],
  };

  pw.Widget _kpi(KpiData kpi) => pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(24),
    decoration: pw.BoxDecoration(
      color: PdfColors.grey100,
      borderRadius: pw.BorderRadius.circular(10),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '${kpi.value ?? '–'}${kpi.unit == null ? '' : ' ${kpi.unit}'}',
          style: pw.TextStyle(
            fontSize: 44,
            fontWeight: pw.FontWeight.bold,
            color: _accent,
          ),
        ),
        if (kpi.delta case final delta? when delta != 0)
          pw.Text(
            '${_signed(delta)} ${labels.l10n.exportDeltaCaption}',
            style: pw.TextStyle(
              fontSize: 11,
              color: delta > 0 ? PdfColors.green700 : PdfColors.red700,
            ),
          ),
        if (kpi.secondary case final secondary?)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 6),
            child: pw.Text(
              definition.query.source == 'streaks'
                  ? labels.l10n.kpiBest(secondary.toInt())
                  : labels.l10n.kpiGames(secondary.toInt()),
              style: const pw.TextStyle(fontSize: 11, color: _muted),
            ),
          ),
      ],
    ),
  );

  pw.Widget _table(DataSet rows) {
    if (CrossTable.of(definition, rows) case final cross?) {
      return _textTable(
        headers: [
          labels.field(cross.rowField),
          for (final column in cross.columnKeys)
            labels.value(cross.columnField, column),
        ],
        data: [
          for (final row in cross.rowKeys)
            [
              labels.value(cross.rowField, row),
              for (final column in cross.columnKeys)
                labels.value(cross.measureField, cross.cell(row, column)),
            ],
        ],
        numeric: {
          for (var c = 1; c <= cross.columnKeys.length; c++)
            c: pw.Alignment.centerRight,
        },
      );
    }
    final columns = _columns(rows);
    return _textTable(
      headers: [
        for (final i in columns) labels.field(rows.fields[i].name),
      ],
      data: [
        for (final row in rows.rows)
          [
            for (final i in columns) labels.value(rows.fields[i].name, row[i]),
          ],
      ],
      numeric: {
        for (var c = 0; c < columns.length; c++)
          if (rows.fields[columns[c]].type == FieldType.number)
            c: pw.Alignment.centerRight,
      },
    );
  }

  pw.Widget _textTable({
    required List<String> headers,
    required List<List<String>> data,
    required Map<int, pw.Alignment> numeric,
  }) {
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: pw.TextStyle(
        fontSize: 9,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: _accent),
      headerAlignment: pw.Alignment.centerLeft,
      headerAlignments: numeric,
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignment: pw.Alignment.centerLeft,
      cellAlignments: numeric,
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      rowDecoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
      ),
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
    );
  }

  /// Colonnes montrées : celles choisies pour le tableau, sinon toutes
  /// celles qui se lisent (comme à l'écran).
  List<int> _columns(DataSet rows) {
    final chosen = definition.display.columns;
    if (chosen != null) {
      return [
        for (final name in chosen)
          if (rows.indexOf(name) case final i when i >= 0) i,
      ];
    }
    final catalog = AssistantContracts.catalog;
    return [
      for (var i = 0; i < rows.fields.length; i++)
        if (!(catalog.fields[rows.fields[i].name]?.internal ?? false) &&
            rows.fields[i].name != 'opponentKind')
          i,
    ];
  }

  static String _signed(num value) => value > 0 ? '+$value' : '$value';
}
