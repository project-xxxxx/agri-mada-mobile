import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/local_db/models/parcelle_local.dart';
import '../../../scan/domain/entities/declared_severity.dart';
import '../../../scan/domain/entities/organe.dart';
import '../../domain/entities/resultat_scan.dart';

class ExportStrings {
  const ExportStrings({
    required this.csvDate,
    required this.csvPlot,
    required this.csvDisease,
    required this.csvSeverity,
    required this.csvCertainty,
    required this.csvOrgans,
    required this.csvTreatment,
    required this.pdfGeneratedBy,
    required this.pdfTitle,
    required this.pdfAllPlots,
    required this.pdfPlotLabel,
    required this.pdfDateLabel,
    required this.noPlot,
    required this.diseaseName,
    required this.severityLabel,
    required this.certaintyLabel,
    required this.organName,
  });

  final String csvDate;
  final String csvPlot;
  final String csvDisease;
  final String csvSeverity;
  final String csvCertainty;
  final String csvOrgans;
  final String csvTreatment;
  final String pdfGeneratedBy;
  final String pdfTitle;
  final String pdfAllPlots;
  final String Function(String) pdfPlotLabel;
  final String Function(String) pdfDateLabel;

  final String noPlot;

  /// Nom traduit d'une fiche ; null quand l'app n'a rien nommé (ADR-006).
  final String Function(String? label) diseaseName;

  /// Libellé traduit d'une gravité déclarée (code de [DeclaredSeverity]).
  final String Function(String? code) severityLabel;

  /// Libellé traduit d'une certitude : probable, possible, incertain.
  final String Function(String? code) certaintyLabel;

  final String Function(Organe organe) organName;
}

class ExportService {
  ExportService();

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  Future<String> exportCsv({
    required List<ResultatScan> resultats,
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
        strings.csvCertainty,
        strings.csvOrgans,
        strings.csvTreatment,
      ],
      ...resultats.map(
        (resultat) => [
          _dateFormat.format(resultat.date),
          _parcelleLabel(resultat.parcelleLocalId, parcellesById, strings),
          strings.diseaseName(resultat.ficheId),
          strings.severityLabel(resultat.graviteDeclaree),
          strings.certaintyLabel(resultat.certitude),
          _organes(resultat, strings),
          '—', // L'app n'enregistre aucun traitement appliqué
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
    required List<ResultatScan> resultats,
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
        : _parcelleLabel(parcelleId, parcellesById, strings);

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
                  _PdfHeaderCell(strings.csvCertainty),
                  _PdfHeaderCell(strings.csvOrgans),
                  _PdfHeaderCell(strings.csvTreatment),
                ],
              ),
              ...resultats.map(
                (resultat) => pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.white),
                  children: [
                    _PdfBodyCell(_dateFormat.format(resultat.date)),
                    _PdfBodyCell(
                      _parcelleLabel(resultat.parcelleLocalId, parcellesById, strings),
                    ),
                    _PdfBodyCell(strings.diseaseName(resultat.ficheId)),
                    _PdfBodyCell(
                      strings.severityLabel(resultat.graviteDeclaree),
                      backgroundColor: _severityColor(resultat.graviteDeclaree),
                      textColor: PdfColors.white,
                    ),
                    _PdfBodyCell(strings.certaintyLabel(resultat.certitude)),
                    _PdfBodyCell(_organes(resultat, strings)),
                    _PdfBodyCell('—'), // L'app n'enregistre aucun traitement
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

  String _parcelleLabel(
    int? parcelleId,
    Map<int, ParcelleLocal> parcellesById,
    ExportStrings strings,
  ) {
    // Un scan rapide peut n'être rattaché à aucune parcelle (tâche P2.6).
    if (parcelleId == null) return strings.noPlot;
    final parcelle = parcellesById[parcelleId];
    return parcelle?.nomParcelle ?? 'Parcelle $parcelleId';
  }

  String _organes(ResultatScan resultat, ExportStrings strings) =>
      resultat.organes.isEmpty
          ? '—'
          : resultat.organes.map(strings.organName).join(' + ');

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
  });

  final String label;
  final PdfColor? backgroundColor;
  final PdfColor? textColor;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerLeft,
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
