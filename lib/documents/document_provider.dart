import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:prava_vrecica/documents/document_model.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:prava_vrecica/ai/categorization_provider.dart';

class DocumentProvider extends ChangeNotifier {
  pw.MemoryImage logo;
  late pw.Font font;
  late pw.Font fontBold;

  DocumentProvider(this.logo) {
    init();
  }

  void init() async {
    font = pw.Font.ttf(await rootBundle.load('assets/fonts/roboto/Roboto-Regular.ttf'));
    fontBold = pw.Font.ttf(await rootBundle.load('assets/fonts/roboto/Roboto-Bold.ttf'));
  }

  Future<Uint8List> createDocument(CustomDocument document, AppLocalizations localizations, CategorizationProvider? categorizationProvider) async {
    if (kDebugMode) {
      print('Creating document');
    }
    pw.Document pdf = pw.Document();
    try {
      switch (document.type) {
        case CustomDocumentType.ticket:
          pdf = createTicket(document, localizations, categorizationProvider!);
          break;
        case CustomDocumentType.invoice:
          pdf = createInvoice(document);
          break;
        case CustomDocumentType.receipt:
          pdf = createReceipt(document);
          break;
        case CustomDocumentType.order:
          pdf = createOrder(document, localizations);
          break;
      }
      if (kDebugMode) {
        print ('Document created');
      }
    } catch (e) {
      if (kDebugMode) {
        print ('Error creating document: $e');
      }
    }
    return pdf.save();
  }

  pw.TextStyle _getFont(double fontSize) {
    return pw.TextStyle(fontSize: fontSize, font: font);
  }

  pw.TextStyle _getFontBold(double fontSize) {
    return pw.TextStyle(fontSize: fontSize, font: fontBold);
  }

  pw.Document createTicket(CustomDocument document, AppLocalizations localizations, CategorizationProvider categorizationProvider) {
    final pdf = pw.Document();
    final dateTime = document.dateTime!;
    final validObjects = document.detectedObjects!.where((element) => element.valid).toList();
    final title = document.title;
    final items = validObjects.map((e) => e.label).toSet().map((e) => {'label': categorizationProvider.objectsList.objects.firstWhere((element) => element.label == e).name, 'count': validObjects.where((element) => element.label == e).length}).toList();
    final description = document.description!;

    pdf.addPage(pw.Page(
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(title, style: _getFontBold(24)),
              pw.Image(logo, width: 50, height: 50),
            ],
          ),
          pw.SizedBox(height: 10),

          // Date and Time
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('${localizations.date}: ${dateTime.day}/${dateTime.month}/${dateTime.year}', style: _getFont(16)),
              pw.Text('${localizations.time}: ${dateTime.hour}:${dateTime.minute}', style: _getFont(16)),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text(localizations.ticket_text, style: _getFont(14)),
          pw.SizedBox(height: 20),

          // Items
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [pw.Text(localizations.items, style: _getFontBold(20))]
          ),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            border: null,
            cellAlignment: pw.Alignment.center,
            headerStyle: _getFont(16),
            cellStyle: _getFont(14),
            headers: [localizations.items, localizations.count],
            data: items.map((item) => [item['label'], item['count'].toString()]).toList(),
          ),
          pw.SizedBox(height: 20),

          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                  child: pw.Container(
                    constraints: const pw.BoxConstraints(maxWidth: 300),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(localizations.description, style: _getFontBold(20)),
                        pw.SizedBox(height: 10),
                        pw.Text(description, style: _getFont(16)),
                      ],
                    ),
                  ),
                flex: 1,
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(localizations.image, style: _getFontBold(20)),
                  pw.SizedBox(height: 20),
                  pw.Image(document.image!, width: 300, height: 300),
                ]
              ),
            ]
          ),
        ],
      ),
    ));

    if (kDebugMode) {
      print ('Created ticket');
    }

    return pdf;
  }

  pw.Document createInvoice(CustomDocument document) {
    final pdf = pw.Document();
    return pdf;
  }

  pw.Document createReceipt(CustomDocument document) {
    final pdf = pw.Document();
    return pdf;
  }

  pw.Document createOrder(CustomDocument document, AppLocalizations localizations) {
    final pdf = pw.Document();
    final dateTime = document.dateTime!;
    final categoriesCounts = document.categoriesCounts!;
    final description = document.description!;
    final periodStart = document.periodStart!;
    final periodEnd = document.periodEnd!;

    pdf.addPage(pw.Page(
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(localizations.order, style: _getFontBold(24)),
              pw.Image(logo, width: 50, height: 50),
            ],
          ),
          pw.SizedBox(height: 10),

          // Date and Time
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('${localizations.date}: ${dateTime.day}/${dateTime.month}/${dateTime.year}', style: _getFont(16)),
              pw.Text('${localizations.time}: ${dateTime.hour}:${dateTime.minute}', style: _getFont(16)),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text(localizations.order_text, style: _getFont(14)),
          pw.SizedBox(height: 20),

          pw.Text('${localizations.period}: ${periodStart.day}/${periodStart.month}/${periodStart.year} - ${periodEnd.day}/${periodEnd.month}/${periodEnd.year}', style: _getFontBold(16)),
          // Items
          pw.SizedBox(height: 20),
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [pw.Text(localizations.items, style: _getFontBold(20))]
          ),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            border: null,
            cellAlignment: pw.Alignment.center,
            headerStyle: _getFontBold(16),
            cellStyle: _getFont(14),
            headers: [localizations.category, localizations.count],
            data: categoriesCounts.entries.map((e) => [e.key, e.value.toString()]).toList()
          ),
          pw.SizedBox(height: 20),
          pw.Text(localizations.description, style: _getFontBold(20)),
          pw.SizedBox(height: 10),
          pw.Text(description, style: _getFont(16)),
        ]
      )
    ));

    return pdf;
  }

}