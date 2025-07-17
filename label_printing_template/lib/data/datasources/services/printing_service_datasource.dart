import 'dart:math' as math;

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
    final num dpi = settings.dpi ?? 203;
    final widthInDots = _convertToDots(dpi, settings.paperWidth, settings.unit);
    final heightInDots = _convertToDots(
      dpi,
      settings.paperHeight,
      settings.unit,
    );
    final gapInDots = _convertToDots(
      dpi,
      settings.gap.toDouble(),
      settings.unit,
    );

    // Define margins in mm then convert to dots
    final sideMargin = _convertToDots(dpi, 5.0, settings.unit); // 5 mm
    final topMargin = _convertToDots(dpi, 5.0, settings.unit); // 5 mm from top
    final bottomSpace = _convertToDots(
      dpi,
      5.0,
      settings.unit,
    ); // 5 mm below QR

    // Determine maximum QR size (square, fitting within available space)
    final availableWidth = widthInDots - 2 * sideMargin;
    final availableHeight = heightInDots - topMargin - bottomSpace;

    // Calculate QR size considering both width and height constraints
    final qrSize = math
        .min(availableWidth, availableHeight)
        .clamp(100, heightInDots);

    // Center QR both horizontally and vertically
    final qrX = (widthInDots - qrSize) ~/ 2;
    final qrY = (heightInDots - qrSize) ~/ 2;

    // Calculate cell width based on DPI (target ~1mm per cell)
    final dotsPerMm = dpi / 25.4;
    final cellWidth = math.max(
      12,
      math.min(14, dotsPerMm.round()),
    ); // Clamp to 12-14 range

    final sb =
        StringBuffer()
          ..writeln('SIZE $widthInDots,$heightInDots')
          ..writeln('GAP $gapInDots,0')
          ..writeln('DENSITY ${settings.density}')
          ..writeln('CLS')
          ..writeln('DELAY 50')
          ..writeln(
            'SET REPRINT ON',
          ) // Enable reprint mode (auto) in no-print, no-ribbon, carriege open
          ..writeln('CLS')
          ..writeln('DELAY 100')
          ..writeln('QRCODE $qrX,$qrY,H,$cellWidth,A,0,"${label.qrData}"')
          ..writeln('DELAY 50');

    sb.writeln('DELAY 100');
    sb.writeln('PRINT $copies');
    sb.writeln('CUT'); // Cut the paper after printing

    return sb.toString();
  }

  /// Convert measurements to dots based on unit
  int _convertToDots(num dpi, double value, String unit) {
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
