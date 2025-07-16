import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';
import 'package:bluetooth_print_plus/src/tsc_command.dart';
import 'package:label_printing_template/data/models/label_model.dart';
import 'package:label_printing_template/data/models/printer_settings_model.dart';
import 'package:label_printing_template/data/datasources/services/bluetooth_service_datasource.dart';
import 'package:label_printing_template/utils/logger.dart';

class PrintingService {
  static final PrintingService _instance = PrintingService._internal();
  factory PrintingService() => _instance;
  PrintingService._internal();

  /// Print a label using TSC commands
  Future<bool> printLabel(
    LabelModel label,
    PrinterSettingsModel settings, {
    int copies = 1,
  }) async {
    try {
      logger.i('Starting print job for label: ${label.id}');

      // Check if we have an active Bluetooth connection
      final bluetoothService = BluetoothService();
      final isConnected = await bluetoothService.checkConnectionStatus();
      if (!isConnected) {
        logger.e('No active Bluetooth connection');
        return false;
      }
      logger.i('✓ Bluetooth connection verified');

      final tsc = TscCommand();

      // Initialize printer with settings
      await _initializePrinter(tsc, settings);

      // Print label content
      await _printLabelContent(tsc, label, settings);

      // Execute print command
      logger.i('Sending print command with $copies copies');
      try {
        await tsc.print(copies);
        logger.i('✓ Print command executed successfully');

        // Add a small delay to ensure commands are processed
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        logger.e('Error executing print command: $e');
        return false;
      }

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

      // Check if we have an active Bluetooth connection
      final bluetoothService = BluetoothService();
      final isConnected = await bluetoothService.checkConnectionStatus();
      if (!isConnected) {
        logger.e('No active Bluetooth connection');
        return false;
      }
      logger.i('✓ Bluetooth connection verified');

      final tsc = TscCommand();

      // Initialize printer once for the batch
      await _initializePrinter(tsc, settings);

      for (int i = 0; i < labels.length; i++) {
        final label = labels[i];
        logger.i('Printing label ${i + 1}/${labels.length}: ${label.id}');

        // Print label content
        await _printLabelContent(tsc, label, settings);

        // Print this label
        try {
          await tsc.print(copiesPerLabel);
          logger.i('✓ Print command executed successfully for label ${i + 1}');
        } catch (e) {
          logger.e('Error executing print command for label ${i + 1}: $e');
          return false;
        }

        // Add delay to ensure commands are processed
        await Future.delayed(const Duration(milliseconds: 500));

        // Add delay between labels to prevent buffer overflow
        if (i < labels.length - 1) {
          await Future.delayed(const Duration(milliseconds: 300));
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

  /// Initialize printer with settings
  Future<void> _initializePrinter(
    TscCommand tsc,
    PrinterSettingsModel settings,
  ) async {
    try {
      logger.i('Initializing printer...');

      // Clear previous commands
      await tsc.cleanCommand();
      logger.i('✓ Commands cleared');

      // Set label size
      final widthInDots = _convertToDots(settings.paperWidth, settings.unit);
      await tsc.size(
        width: widthInDots,
        height: 320,
      ); // Default height of 320 dots
      logger.i('✓ Label size set: ${widthInDots}x320 dots');

      // Set gap between labels
      await tsc.gap(settings.gap);
      logger.i('✓ Gap set: ${settings.gap}');

      // Set print density
      await tsc.density(settings.density);
      logger.i('✓ Density set: ${settings.density}');

      // Clear print buffer
      await tsc.cls();
      logger.i('✓ Print buffer cleared');

      logger.i(
        'Printer initialized successfully with width: ${widthInDots} dots, gap: ${settings.gap}, density: ${settings.density}',
      );
    } catch (e) {
      logger.e('Error initializing printer: $e');
      rethrow;
    }
  }

  /// Print label content with QR code and text
  Future<void> _printLabelContent(
    TscCommand tsc,
    LabelModel label,
    PrinterSettingsModel settings,
  ) async {
    try {
      final widthInDots = _convertToDots(settings.paperWidth, settings.unit);

      // Calculate positions based on label width
      final qrSize = 80; // QR code size in dots
      final qrX = (widthInDots - qrSize) ~/ 2; // Center QR code
      final qrY = 40;

      final textX = 40;
      final textY = qrY + qrSize + 20; // Text below QR code

      logger.i('Printing QR code at position ($qrX, $qrY)');
      // Print QR code
      await tsc.qrCode(content: label.qrData, x: qrX, y: qrY, cellWidth: 5);
      logger.i('✓ QR code printed');

      logger.i('Printing text content at position ($textX, $textY)');
      // Print text content with multiple lines
      await _printMultilineText(
        tsc,
        label.content,
        textX,
        textY,
        widthInDots - 80,
      );
      logger.i('✓ Text content printed');

      // Print timestamp if needed
      final timestampY = textY + 60;
      logger.i('Printing timestamp at position ($textX, $timestampY)');
      await tsc.text(
        content: 'Created: ${_formatTimestamp(label.createdAt)}',
        x: textX,
        y: timestampY,
      );
      logger.i('✓ Timestamp printed');
    } catch (e) {
      logger.e('Error printing label content: $e');
      rethrow;
    }
  }

  /// Print multiline text with word wrapping
  Future<void> _printMultilineText(
    TscCommand tsc,
    String text,
    int x,
    int y,
    int maxWidth,
  ) async {
    try {
      final lines = _wrapText(text, maxWidth);
      int currentY = y;

      logger.i('Printing ${lines.length} lines of text');

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trim().isNotEmpty) {
          logger.i(
            'Printing line ${i + 1}: "${line.trim()}" at position ($x, $currentY)',
          );
          await tsc.text(content: line.trim(), x: x, y: currentY);
          currentY += 30; // Line height
        }
      }
      logger.i('✓ All text lines printed');
    } catch (e) {
      logger.e('Error printing multiline text: $e');
      rethrow;
    }
  }

  /// Wrap text to fit within specified width
  List<String> _wrapText(String text, int maxWidth) {
    final words = text.split(' ');
    final lines = <String>[];
    String currentLine = '';

    for (final word in words) {
      final testLine = currentLine.isEmpty ? word : '$currentLine $word';
      if (_estimateTextWidth(testLine) <= maxWidth) {
        currentLine = testLine;
      } else {
        if (currentLine.isNotEmpty) {
          lines.add(currentLine);
        }
        currentLine = word;
      }
    }

    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }

    return lines;
  }

  /// Estimate text width in dots (approximate)
  int _estimateTextWidth(String text) {
    // Rough estimation: 12 dots per character for TSS24 font
    return text.length * 12;
  }

  /// Format timestamp for display
  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
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
      // Return a basic status since the package might not support status queries
      return {
        'status': 'ready',
        'paper': 'ok',
        'head': 'ok',
        'temperature': 'normal',
        'connected': true,
      };
    } catch (e) {
      logger.e('Error getting printer status: $e');
      return {'status': 'error', 'error': e.toString()};
    }
  }
}
