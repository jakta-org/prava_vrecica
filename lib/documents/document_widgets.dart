import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prava_vrecica/documents/document_model.dart';
import 'package:prava_vrecica/statistics/stats_widgets.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../statistics/statistics_provider.dart';
import 'document_preview_screen.dart';

class GenerateOrderWidget extends StatefulWidget {
  const GenerateOrderWidget({Key? key}) : super(key: key);

  @override
  State<GenerateOrderWidget> createState() => _GenerateOrderWidgetState();
}

class _GenerateOrderWidgetState extends State<GenerateOrderWidget> {
  DateTime? _periodStart;
  DateTime? _periodEnd;

  @override
  Widget build(BuildContext context) {
    final statisticsProvider = Provider.of<StatisticsProvider>(context, listen: false);
    final localization = AppLocalizations.of(context);

    var documentTitle = '';
    var documentDescription = '';

    return Container(
      decoration: childDecoration(context),
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsetsDirectional.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localization!.select_period,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectPeriodStart(context),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 8),
                        Text(
                          _periodStart == null
                              ? localization.start_date
                              : DateFormat.yMMMMd().format(_periodStart!),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () => _selectPeriodEnd(context),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 8),
                        Text(
                          _periodEnd == null
                              ? localization.end_date
                              : DateFormat.yMMMMd().format(_periodEnd!),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: localization.order_title,
              border: const OutlineInputBorder(),
              hintText: localization.order_title_prompt,
            ),
            onChanged: (value) {
              documentTitle = value;
            },
            maxLength: 30,
            maxLines: 1,
          ),
          const SizedBox(height: 2),
          TextFormField(
            decoration: InputDecoration(
              labelText: localization.order_description,
              border: const OutlineInputBorder(),
              hintText: localization.order_description_prompt,
            ),
            onChanged: (value) {
              documentDescription = value;
            },
            maxLength: 500,
            maxLines: 5,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.blue,
            ),
            child: TextButton(
              onPressed: () {
                _periodEnd ??= DateTime.now();
                _periodStart ??= _periodEnd?.subtract(const Duration(days: 7));
                //TODO: Should be changed so the statistics are fetched from the group statistics
                final categoryStats = statisticsProvider.getFilteredCategoryStats(entryFilter: (entry) => entry.time.isAfter(_periodStart!) && entry.time.isBefore(_periodEnd!));
                Map<String, int> categoriesCounts = {};
                for (var categoryStat in categoryStats) {
                  categoriesCounts[categoryStat.categoryName] = categoryStat.recycledCount;
                }
                CustomDocument document = CustomDocument(
                  type: CustomDocumentType.order,
                  title: documentTitle,
                  dateTime: DateTime.now(),
                  description: documentDescription,
                  periodStart: _periodStart!,
                  periodEnd: _periodEnd!,
                  categoriesCounts: categoriesCounts,
                );
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DocumentPreviewScreen(document: document))
                );
              },
              child: Text(
                localization.create_order,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectPeriodStart(BuildContext context) async {
    final initialDate = _periodStart ?? DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (selectedDate != null) {
      setState(() {
        _periodStart = selectedDate;
      });
    }
  }

  Future<void> _selectPeriodEnd(BuildContext context) async {
    final initialDate = _periodEnd ?? DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (selectedDate != null) {
      setState(() {
        _periodEnd = selectedDate;
      });
    }
  }
}