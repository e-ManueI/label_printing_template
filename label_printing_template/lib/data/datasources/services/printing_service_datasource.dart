import 'package:bluetooth_print_plus/src/tsc_command.dart';
import 'package:label_printing_template/data/models/label_model.dart';
import 'package:label_printing_template/data/models/printer_settings_model.dart';
import 'package:label_printing_template/utils/logger.dart';

class PrintingService {
  static final PrintingService _instance = PrintingService._internal();
  factory PrintingService() => _instance;
  PrintingService._internal();

  /// Print a label using TSPL commands
  Future<bool> printLabel(
    LabelModel label,
    PrinterSettingsModel settings, {
    int copies = 1,
  }) async {
    try {
      logger.i('Starting print job for label: ${label.id}');

      final tsc = TscCommand();

      // Initialize printer
      await tsc.cleanCommand();
      await tsc.size(
        width: _convertToDots(settings.paperWidth, settings.unit),
        height: 320, // Default height
      );
      await tsc.gap(settings.gap);
      await tsc.density(settings.density);
      await tsc.cls();

      // Print QR code
      await tsc.qrCode(content: label.qrData, x: 40, y: 40, cellWidth: 5);

      // Print text content
      await tsc.text(content: label.content, x: 40, y: 200);

      // Execute print command
      await tsc.methodChannel.invokeMethod('print', {"count": copies});

      logger.i('Print job completed successfully');
      return true;
    } catch (e) {
      logger.e('Error printing label: $e');
      return false;
    }
  }

  /// Print multiple labels in a batch
  Future<bool> printBatch(
    List<LabelModel> labels,
    PrinterSettingsModel settings, {
    int copiesPerLabel = 1,
  }) async {
    try {
      logger.i('Starting batch print job for ${labels.length} labels');

      for (int i = 0; i < labels.length; i++) {
        final label = labels[i];
        logger.i('Printing label ${i + 1}/${labels.length}: ${label.id}');

        final success = await printLabel(
          label,
          settings,
          copies: copiesPerLabel,
        );
        if (!success) {
          logger.e('Failed to print label ${label.id}');
          return false;
        }

        // Add delay between prints to prevent buffer overflow
        if (i < labels.length - 1) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      logger.i('Batch print job completed successfully');
      return true;
    } catch (e) {
      logger.e('Error in batch printing: $e');
      return false;
    }
  }

  /// Test print functionality
  Future<bool> testPrint(PrinterSettingsModel settings) async {
    try {
      logger.i('Starting test print');

      final testLabel = LabelModel(
        id: 'test_${DateTime.now().millisecondsSinceEpoch}',
        content: 'TEST PRINT\n${DateTime.now().toString()}',
        qrData: 'TEST_QR_DATA',
        createdAt: DateTime.now(),
      );

      return await printLabel(testLabel, settings);
    } catch (e) {
      logger.e('Error in test print: $e');
      return false;
    }
  }

  /// Convert measurements to dots based on unit
  int _convertToDots(double value, String unit) {
    const dpi = 203; // Standard DPI for thermal printers

    switch (unit.toLowerCase()) {
      case 'mm':
        return (value * dpi / 25.4).round();
      case 'inch':
        return (value * dpi).round();
      case 'dots':
        return value.round();
      default:
        return (value * dpi / 25.4).round(); // Default to mm
    }
  }

  /// Get printer status
  Future<Map<String, dynamic>> getPrinterStatus() async {
    try {
      // This would typically query the printer for status information
      // For now, return a basic status
      return {
        'status': 'ready',
        'paper': 'ok',
        'head': 'ok',
        'temperature': 'normal',
      };
    } catch (e) {
      logger.e('Error getting printer status: $e');
      return {'status': 'error', 'error': e.toString()};
    }
  }
}
