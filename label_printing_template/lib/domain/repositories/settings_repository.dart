import '../entities/printer_settings.dart';

abstract class SettingsRepository {
  Future<PrinterSettings> loadSettings();
  Future<bool> saveSettings(PrinterSettings settings);
  Future<bool> updateSettings({
    double? paperWidth,
    String? unit,
    int? density,
    int? gap,
    String? printerType,
    Map<String, dynamic>? customSettings,
  });
  Future<bool> resetToDefaults();
  bool validateSettings(PrinterSettings settings);
  List<String> getAvailableUnits();
  List<String> getAvailablePrinterTypes();
  Map<String, int> getDensityRange();
  Map<String, Map<String, double>> getPaperWidthRanges();
  double convertPaperWidth(double width, String fromUnit, String toUnit);
}
