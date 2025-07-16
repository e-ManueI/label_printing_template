import '../entities/label.dart';
import '../entities/printer_settings.dart';

abstract class PrintingRepository {
  Future<bool> printLabel(
    Label label,
    PrinterSettings settings, {
    int copies = 1,
  });
  Future<bool> printBatch(
    List<Label> labels,
    PrinterSettings settings, {
    int copiesPerLabel = 1,
  });
  Future<bool> testPrint(PrinterSettings settings);
  Future<Map<String, dynamic>> getPrinterStatus();
  bool validateLabel(Label label);
  bool validateSettings(PrinterSettings settings);
  Label createDefaultLabel({String? content, String? qrData});
  Map<String, dynamic> prepareLabelForPrinting(Label label);
}
