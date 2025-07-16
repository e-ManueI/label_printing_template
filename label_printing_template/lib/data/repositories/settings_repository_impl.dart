import '../../domain/repositories/settings_repository.dart';
import '../../domain/entities/printer_settings.dart';
import '../datasources/local/storage_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final StorageDataSource _storageDataSource;

  SettingsRepositoryImpl({StorageDataSource? storageDataSource})
    : _storageDataSource = storageDataSource ?? SharedPreferencesDataSource();

  @override
  Future<PrinterSettings> loadSettings() async {
    try {
      final data = await _storageDataSource.loadPrinterSettings();
      if (data != null) {
        return PrinterSettings(
          paperWidth: data['paperWidth'] ?? 58.0,
          unit: data['unit'] ?? 'mm',
          density: data['density'] ?? 8,
          gap: data['gap'] ?? 20,
          printerType: data['printerType'] ?? 'TSC',
          customSettings: Map<String, dynamic>.from(
            data['customSettings'] ?? {},
          ),
        );
      }
      return PrinterSettings.defaultSettings();
    } catch (e) {
      return PrinterSettings.defaultSettings();
    }
  }

  @override
  Future<bool> saveSettings(PrinterSettings settings) async {
    try {
      final data = {
        'paperWidth': settings.paperWidth,
        'unit': settings.unit,
        'density': settings.density,
        'gap': settings.gap,
        'printerType': settings.printerType,
        'customSettings': settings.customSettings,
      };
      await _storageDataSource.savePrinterSettings(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateSettings({
    double? paperWidth,
    String? unit,
    int? density,
    int? gap,
    String? printerType,
    Map<String, dynamic>? customSettings,
  }) async {
    try {
      final currentSettings = await loadSettings();
      final updatedSettings = currentSettings.copyWith(
        paperWidth: paperWidth,
        unit: unit,
        density: density,
        gap: gap,
        printerType: printerType,
        customSettings: customSettings,
      );
      return await saveSettings(updatedSettings);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> resetToDefaults() async {
    try {
      final defaultSettings = PrinterSettings.defaultSettings();
      return await saveSettings(defaultSettings);
    } catch (e) {
      return false;
    }
  }

  @override
  bool validateSettings(PrinterSettings settings) {
    return settings.paperWidth > 0 &&
        settings.density >= 1 &&
        settings.density <= 15 &&
        settings.gap >= 0 &&
        getAvailableUnits().contains(settings.unit) &&
        getAvailablePrinterTypes().contains(settings.printerType);
  }

  @override
  List<String> getAvailableUnits() {
    return ['mm', 'inch', 'dots'];
  }

  @override
  List<String> getAvailablePrinterTypes() {
    return ['Zebra', 'TSC', 'Citizen', 'Generic'];
  }

  @override
  Map<String, int> getDensityRange() {
    return {'min': 1, 'max': 15, 'default': 8};
  }

  @override
  Map<String, Map<String, double>> getPaperWidthRanges() {
    return {
      'mm': {'min': 20.0, 'max': 100.0, 'default': 58.0},
      'inch': {'min': 0.8, 'max': 4.0, 'default': 2.3},
      'dots': {'min': 384, 'max': 1920, 'default': 576},
    };
  }

  @override
  double convertPaperWidth(double width, String fromUnit, String toUnit) {
    if (fromUnit == toUnit) return width;

    // Convert to mm first
    double mmWidth;
    switch (fromUnit) {
      case 'mm':
        mmWidth = width;
        break;
      case 'inch':
        mmWidth = width * 25.4;
        break;
      case 'dots':
        mmWidth = width * 0.125; // Assuming 203 DPI
        break;
      default:
        mmWidth = width;
    }

    // Convert from mm to target unit
    switch (toUnit) {
      case 'mm':
        return mmWidth;
      case 'inch':
        return mmWidth / 25.4;
      case 'dots':
        return mmWidth / 0.125;
      default:
        return mmWidth;
    }
  }
}
