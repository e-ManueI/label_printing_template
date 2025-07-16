import '../../domain/repositories/printing_repository.dart';
import '../../domain/entities/label.dart';
import '../../domain/entities/printer_settings.dart';
import '../datasources/services/printing_service_datasource.dart';
import '../models/label_model.dart';
import '../models/printer_settings_model.dart';
import '../../utils/logger.dart';

class PrintingRepositoryImpl implements PrintingRepository {
  final PrintingService _printingService = PrintingService();

  @override
  Future<bool> printLabel(
    Label label,
    PrinterSettings settings, {
    int copies = 1,
  }) async {
    try {
      logger.i('Printing label: ${label.id}');

      // Convert domain entities to models
      final labelModel = _convertToLabelModel(label);
      final settingsModel = _convertToPrinterSettingsModel(settings);

      return await _printingService.printLabel(
        labelModel,
        settingsModel,
        copies: copies,
      );
    } catch (e) {
      logger.e('Error printing label: $e');
      return false;
    }
  }

  @override
  Future<bool> printBatch(
    List<Label> labels,
    PrinterSettings settings, {
    int copiesPerLabel = 1,
  }) async {
    try {
      logger.i('Printing batch of ${labels.length} labels');

      // Convert domain entities to models
      final labelModels = labels.map(_convertToLabelModel).toList();
      final settingsModel = _convertToPrinterSettingsModel(settings);

      return await _printingService.printBatch(
        labelModels,
        settingsModel,
        copiesPerLabel: copiesPerLabel,
      );
    } catch (e) {
      logger.e('Error printing batch: $e');
      return false;
    }
  }

  @override
  Future<bool> testPrint(PrinterSettings settings) async {
    try {
      logger.i('Starting test print');
      final settingsModel = _convertToPrinterSettingsModel(settings);
      return await _printingService.testPrint(settingsModel);
    } catch (e) {
      logger.e('Error in test print: $e');
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> getPrinterStatus() async {
    try {
      logger.i('Getting printer status');
      return await _printingService.getPrinterStatus();
    } catch (e) {
      logger.e('Error getting printer status: $e');
      return {'status': 'error', 'error': e.toString()};
    }
  }

  @override
  bool validateLabel(Label label) {
    return label.content.isNotEmpty && label.qrData.isNotEmpty;
  }

  @override
  bool validateSettings(PrinterSettings settings) {
    return settings.paperWidth > 0 &&
        settings.density >= 1 &&
        settings.density <= 15 &&
        settings.gap >= 0;
  }

  @override
  Label createDefaultLabel({String? content, String? qrData}) {
    return Label(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content ?? 'Default Label',
      qrData: qrData ?? 'DEFAULT_QR',
      createdAt: DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> prepareLabelForPrinting(Label label) {
    return {
      'content': label.content,
      'qrData': label.qrData,
      'timestamp': label.createdAt.toIso8601String(),
    };
  }

  /// Convert domain Label to LabelModel
  LabelModel _convertToLabelModel(Label label) {
    return LabelModel(
      id: label.id,
      content: label.content,
      qrData: label.qrData,
      createdAt: label.createdAt,
    );
  }

  /// Convert domain PrinterSettings to PrinterSettingsModel
  PrinterSettingsModel _convertToPrinterSettingsModel(
    PrinterSettings settings,
  ) {
    return PrinterSettingsModel(
      paperWidth: settings.paperWidth,
      density: settings.density,
      gap: settings.gap,
      unit: settings.unit,
      printerType: settings.printerType,
      customSettings: settings.customSettings,
    );
  }
}
