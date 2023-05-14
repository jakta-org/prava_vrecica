import 'package:flutter/material.dart';
import '../documents/document_model.dart';
import '../documents/document_preview_screen.dart';
import '../screens/preview_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Widget createTicketButton(PreviewScreenState state) {
  var localizations = AppLocalizations.of(state.context)!;

  void generateTicketPreview(String title, String description) {
    final document = CustomDocument(
      type: CustomDocumentType.ticket,
      title: title,
      image: state.memoryImage,
      dateTime: DateTime.now(),
      detectedObjects: state.widget.recognitions,
      description: description,
    );
    Navigator.pushReplacement(
        state.context,
        MaterialPageRoute(
            builder: (context) => DocumentPreviewScreen(document: document)));
  }

  return Container(
    margin: const EdgeInsetsDirectional.only(top: 35, end: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: () {
            showDialog(
                context: state.context,
                builder: (context) {
                  String ticketTitle = '';
                  String ticketDescription = '';

                  return AlertDialog(
                    title: Text(localizations.create_ticket_text),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextField(
                          decoration: InputDecoration(
                            hintText: localizations.ticket_title_prompt,
                            label: Text(localizations.ticket_title),
                          ),
                          onChanged: (value) {
                            ticketTitle = value;
                          },
                          maxLength: 30,
                        ),
                        TextField(
                          decoration: InputDecoration(
                            hintText: localizations.ticket_description_prompt,
                            label: Text(localizations.ticket_description),
                          ),
                          onChanged: (value) {
                            ticketDescription = value;
                          },
                          maxLines: 5,
                          maxLength: 500,
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text(localizations.cancel),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      ElevatedButton(
                          onPressed: () {
                            generateTicketPreview(
                                ticketTitle, ticketDescription);
                          },
                          child: Text(localizations.create_ticket))
                    ],
                  );
                });
          },
          child: Text(localizations.create_ticket),
        ),
      ],
    ),
  );
}