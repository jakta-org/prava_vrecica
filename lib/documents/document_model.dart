import '../providers/ai_model_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class CustomDocument {
  CustomDocumentType type;
  String title;
  pw.MemoryImage? image;
  DateTime? dateTime;
  DateTime? periodStart;
  DateTime? periodEnd;
  String? description;
  List<Recognition>? detectedObjects;
  Map<String, int>? objectCounts;
  Map<String, int>? categoriesCounts;

  CustomDocument({required this.type, required this.title, this.image, this.dateTime, this.detectedObjects, this.objectCounts, this.categoriesCounts, this.description, this.periodStart, this.periodEnd});
}

enum CustomDocumentType {
  ticket,
  invoice,
  receipt,
  order,
}