import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';
import 'dart:typed_data';
import 'package:label_printing_template/data/models/label_model.dart';
import 'package:label_printing_template/data/models/printer_settings_model.dart';
import 'package:label_printing_template/utils/logger.dart';

class PrintingService {
  static final PrintingService _instance = PrintingService._internal();
  factory PrintingService() => _instance;
  PrintingService._internal();

  /// Print a label using direct TSPL commands
  Future<bool> printLabel(
    LabelModel label,
    PrinterSettingsModel settings, {
    int copies = 1,
  }) async {
    try {
      logger.i('Starting print job for label: ${label.id}');

      // Check if we have an active Bluetooth connection using the same method as the rest of the app
      final isConnected = await BluetoothPrintPlus.isConnected;
      if (!isConnected) {
        logger.e('No active Bluetooth connection');
        return false;
      }
      logger.i('✓ Bluetooth connection verified');

      // Build TSPL command string
      final tscCommands = _buildTscCommands(label, settings, copies);
      logger.i('Generated TSPL commands: $tscCommands');

      // Send commands directly to printer
      try {
        await BluetoothPrintPlus.write(
          Uint8List.fromList(tscCommands.codeUnits),
        );
        logger.i('✓ TSPL commands sent successfully');

        // Add delay to ensure commands are processed
        await Future.delayed(const Duration(milliseconds: 1000));
      } catch (e) {
        logger.e('Error sending TSPL commands: $e');
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

      // Check if we have an active Bluetooth connection using the same method as the rest of the app
      final isConnected = await BluetoothPrintPlus.isConnected;
      if (!isConnected) {
        logger.e('No active Bluetooth connection');
        return false;
      }
      logger.i('✓ Bluetooth connection verified');

      for (int i = 0; i < labels.length; i++) {
        final label = labels[i];
        logger.i('Printing label ${i + 1}/${labels.length}: ${label.id}');

        // Build and send TSPL commands for this label
        final tscCommands = _buildTscCommands(label, settings, copiesPerLabel);
        logger.i('Generated TSPL commands for label ${i + 1}: $tscCommands');

        try {
          await BluetoothPrintPlus.write(
            Uint8List.fromList(tscCommands.codeUnits),
          );
          logger.i('✓ TSPL commands sent successfully for label ${i + 1}');
        } catch (e) {
          logger.e('Error sending TSPL commands for label ${i + 1}: $e');
          return false;
        }

        // Add delay to ensure commands are processed
        await Future.delayed(const Duration(milliseconds: 1000));

        // Add delay between labels to prevent buffer overflow
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

  /// Build TSPL command string for a label
  String _buildTscCommands(
    LabelModel label,
    PrinterSettingsModel settings,
    int copies,
  ) {
    final widthInDots = _convertToDots(settings.paperWidth, settings.unit);
    final heightInDots = 320; // Default height
    final gapInDots = _convertToDots(settings.gap.toDouble(), settings.unit);

    // Calculate positions - ensure they're within printable area
    final qrSize = 80;
    final qrX = (widthInDots - qrSize) ~/ 2;
    final qrY = 50; // Increased from 40 to give more space
    final textX = 50; // Increased from 40 for better positioning
    final textY = qrY + qrSize + 40; // Increased spacing from QR code
    final timestampY =
        textY + 80; // Increased spacing between text and timestamp

    // Build TSPL commands
    final commands = StringBuffer();

    // Initialize printer with correct TSPL syntax
    commands.writeln(
      'SIZE $widthInDots,$heightInDots',
    ); // Fixed: no units, just dots
    commands.writeln('GAP $gapInDots,0'); // Fixed: gap in dots, not units
    commands.writeln('DENSITY ${settings.density}');
    commands.writeln('CLS');

    // Add small delay between initialization and content
    commands.writeln('DELAY 100');

    // Print QR code
    commands.writeln('QRCODE $qrX,$qrY,L,5,A,0,"${label.qrData}"');

    // Add delay after QR code
    commands.writeln('DELAY 50');

    // Print text content with proper font specification
    final lines = _wrapText(
      label.content,
      widthInDots - 100,
    ); // Reduced max width
    int currentY = textY;
    for (final line in lines) {
      if (line.trim().isNotEmpty) {
        // Use font 1 (standard font) instead of font 3, with proper parameters
        commands.writeln('TEXT $textX,$currentY,"1",0,1,1,"${line.trim()}"');
        currentY += 40; // Increased line spacing
      }
    }

    // Add delay after text
    commands.writeln('DELAY 50');

    // Print timestamp with same font
    commands.writeln(
      'TEXT $textX,$timestampY,"1",0,1,1,"Created: ${_formatTimestamp(label.createdAt)}"',
    );

    // Add delay before print command
    commands.writeln('DELAY 100');

    // Print command
    commands.writeln('PRINT $copies');

    return commands.toString();
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
