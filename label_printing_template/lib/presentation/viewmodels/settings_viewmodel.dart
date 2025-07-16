import 'package:flutter/foundation.dart';
import '../../domain/entities/printer_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../data/repositories/settings_repository_impl.dart';

class SettingsViewModel extends ChangeNotifier {
  final SettingsRepository _settingsRepository;
  
  SettingsViewModel({SettingsRepository? settingsRepository}) 
      : _settingsRepository = settingsRepository ?? SettingsRepositoryImpl();

  PrinterSettings? _settings;
  bool _isLoading = false;
  String? _error;

  PrinterSettings? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSettings() async {
    _setLoading(true);
    try {
      _settings = await _settingsRepository.loadSettings();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> saveSettings(PrinterSettings settings) async {
    _setLoading(true);
    try {
      await _settingsRepository.saveSettings(settings);
      _settings = settings;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> setPaperWidth(double width) async {
    if (_settings != null) {
      final updatedSettings = _settings!.copyWith(paperWidth: width);
      await saveSettings(updatedSettings);
    }
  }

  Future<void> setUnit(String unit) async {
    if (_settings != null) {
      final updatedSettings = _settings!.copyWith(unit: unit);
      await saveSettings(updatedSettings);
    }
  }

  Future<void> setDensity(int density) async {
    if (_settings != null) {
      final updatedSettings = _settings!.copyWith(density: density);
      await saveSettings(updatedSettings);
    }
  }

  Future<void> setGap(int gap) async {
    if (_settings != null) {
      final updatedSettings = _settings!.copyWith(gap: gap);
      await saveSettings(updatedSettings);
    }
  }

  Future<void> setPrinterType(String printerType) async {
    if (_settings != null) {
      final updatedSettings = _settings!.copyWith(printerType: printerType);
      await saveSettings(updatedSettings);
    }
  }

  Future<void> resetToDefaults() async {
    final defaultSettings = PrinterSettings.defaultSettings();
    await saveSettings(defaultSettings);
  }

  List<String> getAvailableUnits() {
    return ['mm', 'inch', 'dots'];
  }

  List<String> getAvailablePrinterTypes() {
    return ['Zebra', 'TSC', 'Citizen', 'Generic'];
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
} 