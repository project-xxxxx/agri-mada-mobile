import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/local_db/models/diagnostic_local.dart';
import '../../../../core/local_db/models/parcelle_local.dart';
import '../../../scan/domain/entities/declared_severity.dart';

class ExportStrings {
  const ExportStrings({
    required this.csvDate,
    required this.csvPlot,
    required this.csvDisease,
    required this.csvSeverity,
    required this.csvConfidence,
    required this.csvRecommendations,
    required this.csvTreatment,
    required this.pdfGeneratedBy,
    required this.pdfTitle,
    required this.pdfAllPlots,
    required this.pdfPlotLabel,
    required this.pdfDateLabel,
    required this.diseaseName,
    required this.severityLabel,
  });

  final String csvDate;
  final String csvPlot;
  final String csvDisease;
  final String csvSeverity;
  final String csvConfidence;
  final String csvRecommendations;
  final String csvTreatment;
  final String pdfGeneratedBy;
  final String pdfTitle;
  final String pdfAllPlots;
  final String Function(String) pdfPlotLabel;
  final String Function(String) pdfDateLabel;

  /// Nom traduit d'une étiquette du modèle.
  final String Function(String label) diseaseName;

  /// Libellé traduit d'une gravité déclarée (code de [DeclaredSeverity]).
  final String Function(String? code) severityLabel;
}

class ExportService {
  ExportService();

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  Future<String> exportCsv({
    required List<DiagnosticLocal> diagnostics,
    required Map<int, ParcelleLocal> parcellesById,
    required ExportStrings strings,
    int? parcelleId,
  }) async {
    final directory = await _ensureExportDirectory();
    final fileName = _buildFileName('csv', parcelleId);
    final file = File('${directory.path}/$fileName');

    final rows = <List<String>>[
      [
        strings.csvDate,
        strings.csvPlot,
        strings.csvDisease,
        strings.csvSeverity,
        strings.csvConfidence,
        strings.csvRecommendations,
        strings.csvTreatment,
      ],
      ...diagnostics.map(
        (diagnostic) => [
          _dateFormat.format(diagnostic.dateDiagnostic),
          _parcelleLabel(diagnostic.parcelleLocalId, parcellesById),
          strings.diseaseName(diagnostic.maladieDetectee),
          strings.severityLabel(diagnostic.niveauGravite),
          _confidencePercent(diagnostic.confiance),
          _normalizeText(diagnostic.recommandations),
          '—', // Pas de champ 'traitement appliqué' dans le modèle
        ],
      ),
    ];

    final csvData = const ListToCsvConverter(
      fieldDelimiter: ';',
      textDelimiter: '"',
      eol: '\r\n',
    ).convert(rows);

    final bomBytes = <int>[0xEF, 0xBB, 0xBF, ...utf8.encode(csvData)];
    await file.writeAsBytes(bomBytes, flush: true);
    return file.path;
  }

  Future<String> exportPdf({
    required List<DiagnosticLocal> diagnostics,
    required Map<int, ParcelleLocal> parcellesById,
    required ExportStrings strings,
    int? parcelleId,
  }) async {
    final directory = await _ensureExportDirectory();
    final fileName = _buildFileName('pdf', parcelleId);
    final file = File('${directory.path}/$fileName');

    final pdf = pw.Document();
    final logo = await _loadLogo();
    final exportDate = _dateFormat.format(DateTime.now());
    final parcelleLabel = parcelleId == null
        ? strings.pdfAllPlots
        : _parcelleLabel(parcelleId, parcellesById);

    pdf.addPage(
      pw.MultiPage(
        pageTheme: const pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(24),
        ),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            strings.pdfGeneratedBy,
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ),
        build: (context) => [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (logo != null) ...[
                pw.Container(
                  width: 64,
                  height: 64,
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Image(logo, fit: pw.BoxFit.cover),
                ),
                pw.SizedBox(width: 16),
              ],
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'AgriMada',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(strings.pdfTitle,
                        style: const pw.TextStyle(fontSize: 12)),
                    pw.SizedBox(height: 4),
                    pw.Text(strings.pdfPlotLabel(parcelleLabel),
                        style: const pw.TextStyle(fontSize: 11)),
                    pw.Text(strings.pdfDateLabel(exportDate),
                        style: const pw.TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.6),
            columnWidths: const {
              0: pw.FlexColumnWidth(1.2),
              1: pw.FlexColumnWidth(1.2),
              2: pw.FlexColumnWidth(1.3),
              3: pw.FlexColumnWidth(0.9),
              4: pw.FlexColumnWidth(0.8),
              5: pw.FlexColumnWidth(1.8),
              6: pw.FlexColumnWidth(1.4),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.green),
                children: [
                  _PdfHeaderCell(strings.csvDate),
                  _PdfHeaderCell(strings.csvPlot),
                  _PdfHeaderCell(strings.csvDisease),
                  _PdfHeaderCell(strings.csvSeverity),
                  _PdfHeaderCell(strings.csvConfidence),
                  _PdfHeaderCell(strings.csvRecommendations),
                  _PdfHeaderCell(strings.csvTreatment),
                ],
              ),
              ...diagnostics.map(
                (diagnostic) => pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.white),
                  children: [
                    _PdfBodyCell(_dateFormat.format(diagnostic.dateDiagnostic)),
                    _PdfBodyCell(
                      _parcelleLabel(diagnostic.parcelleLocalId, parcellesById),
                    ),
                    _PdfBodyCell(strings.diseaseName(diagnostic.maladieDetectee)),
                    _PdfBodyCell(
                      strings.severityLabel(diagnostic.niveauGravite),
                      backgroundColor: _severityColor(diagnostic.niveauGravite),
                      textColor: PdfColors.white,
                    ),
                    _PdfBodyCell(
                      _confidencePercent(diagnostic.confiance),
                      alignment: pw.Alignment.centerRight,
                    ),
                    _PdfBodyCell(_normalizeText(diagnostic.recommandations)),
                    _PdfBodyCell('—'), // Pas de champ 'traitement appliqué'
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    await file.writeAsBytes(await pdf.save(), flush: true);
    return file.path;
  }

  Future<Directory> _ensureExportDirectory() async {
    final base = await getApplicationDocumentsDirectory();
    final directory = Directory('${base.path}/exports');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  String _buildFileName(String extension, int? parcelleId) {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final suffix =
        parcelleId == null ? 'toutes_parcelles' : 'parcelle_$parcelleId';
    return 'agri_mada_journal_${suffix}_$timestamp.$extension';
  }

  String _parcelleLabel(int parcelleId, Map<int, ParcelleLocal> parcellesById) {
    final parcelle = parcellesById[parcelleId];
    return parcelle?.nomParcelle ?? 'Parcelle $parcelleId';
  }

  String _confidencePercent(double? confidence) {
    final value = confidence == null ? 0 : (confidence * 100).round();
    return '$value';
  }

  String _normalizeText(String? value) {
    final text = value?.trim();
    return (text == null || text.isEmpty) ? '—' : text;
  }

  PdfColor _severityColor(String? code) =>
      switch (DeclaredSeverity.fromCode(code)) {
        DeclaredSeverity.quelquesPlants => PdfColors.green,
        DeclaredSeverity.moinsDunTiers => PdfColors.orange,
        DeclaredSeverity.plusDunTiers => PdfColors.red,
        null => PdfColors.grey700,
      };

  Future<pw.ImageProvider?> _loadLogo() async {
    try {
      final imageBytes = await rootBundle.load('assets/images/logo.png');
      return pw.MemoryImage(imageBytes.buffer.asUint8List());
    } catch (_) {
      return null;
    }
  }
}

class _PdfHeaderCell extends pw.StatelessWidget {
  _PdfHeaderCell(this.label);

  final String label;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: pw.Text(
        label,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    );
  }
}

class _PdfBodyCell extends pw.StatelessWidget {
  _PdfBodyCell(
    this.label, {
    this.backgroundColor,
    this.textColor,
    this.alignment,
  });

  final String label;
  final PdfColor? backgroundColor;
  final PdfColor? textColor;
  final pw.Alignment? alignment;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Container(
      alignment: alignment ?? pw.Alignment.centerLeft,
      color: backgroundColor,
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: pw.Text(
        label,
        style: pw.TextStyle(
          fontSize: 9,
          color: textColor ?? PdfColors.black,
        ),
      ),
    );
  }
}
