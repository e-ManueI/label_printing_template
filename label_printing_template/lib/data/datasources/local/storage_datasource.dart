import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract class StorageDataSource {
  Future<bool> savePrinterSettings(Map<String, dynamic> settings);
  Future<Map<String, dynamic>?> loadPrinterSettings();
  Future<bool> saveLabels(List<Map<String, dynamic>> labels);
  Future<List<Map<String, dynamic>>> getSavedLabels();
  Future<bool> saveRecentLabels(List<Map<String, dynamic>> labels);
  Future<List<Map<String, dynamic>>> getRecentLabels();
  Future<bool> clearAllData();
}

class SharedPreferencesDataSource implements StorageDataSource {
  static const String _settingsKey = 'printer_settings';
  static const String _labelsKey = 'saved_labels';
  static const String _recentLabelsKey = 'recent_labels';

  @override
  Future<bool> savePrinterSettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setString(_settingsKey, jsonEncode(settings));
      return success;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>?> loadPrinterSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsString = prefs.getString(_settingsKey);

      if (settingsString != null) {
        return jsonDecode(settingsString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> saveLabels(List<Map<String, dynamic>> labels) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setString(_labelsKey, jsonEncode(labels));
      return success;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getSavedLabels() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final labelsString = prefs.getString(_labelsKey);

      if (labelsString != null) {
        final labelsJson = jsonDecode(labelsString) as List<dynamic>;
        return labelsJson.map((json) => json as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> saveRecentLabels(List<Map<String, dynamic>> labels) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setString(
        _recentLabelsKey,
        jsonEncode(labels),
      );
      return success;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRecentLabels() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final labelsString = prefs.getString(_recentLabelsKey);

      if (labelsString != null) {
        final labelsJson = jsonDecode(labelsString) as List<dynamic>;
        return labelsJson.map((json) => json as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.clear();
      return success;
    } catch (e) {
      return false;
    }
  }
}
