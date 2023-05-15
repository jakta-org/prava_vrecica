import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prava_vrecica/documents/document_model.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../ai/categorization_provider.dart';
import 'document_provider.dart';

class DocumentPreviewScreen extends StatelessWidget {
  final CustomDocument document;

  const DocumentPreviewScreen({Key? key, required this.document}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final documentProvider = Provider.of<DocumentProvider>(context, listen: false);
    final localizations = AppLocalizations.of(context)!;
    final categorizationProvider = Provider.of<CategorizationProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            localizations.pdf_preview
        ),
      ),
      body: PdfPreview(
        build: (context) => documentProvider.createDocument(document, localizations, categorizationProvider),
      )
    );
  }
}