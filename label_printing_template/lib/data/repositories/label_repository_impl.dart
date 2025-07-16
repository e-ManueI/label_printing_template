import 'dart:convert';
import '../../domain/repositories/label_repository.dart';
import '../../domain/entities/label.dart';
import '../datasources/local/storage_datasource.dart';

class LabelRepositoryImpl implements LabelRepository {
  final StorageDataSource _storageDataSource;

  LabelRepositoryImpl({StorageDataSource? storageDataSource})
    : _storageDataSource = storageDataSource ?? SharedPreferencesDataSource();

  @override
  Future<List<Label>> getAllLabels() async {
    try {
      final labelsData = await _storageDataSource.getSavedLabels();
      return labelsData.map((data) => Label.fromMap(data)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Label?> getLabelById(String id) async {
    try {
      final labels = await getAllLabels();
      return labels.where((label) => label.id == id).firstOrNull;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> saveLabel(Label label) async {
    try {
      final labels = await getAllLabels();
      labels.add(label);
      final labelsData = labels.map((l) => l.toMap()).toList();
      return await _storageDataSource.saveLabels(labelsData);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateLabel(Label updatedLabel) async {
    try {
      final labels = await getAllLabels();
      final index = labels.indexWhere((label) => label.id == updatedLabel.id);
      if (index != -1) {
        labels[index] = updatedLabel;
        final labelsData = labels.map((l) => l.toMap()).toList();
        return await _storageDataSource.saveLabels(labelsData);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteLabel(String id) async {
    try {
      final labels = await getAllLabels();
      labels.removeWhere((label) => label.id == id);
      final labelsData = labels.map((l) => l.toMap()).toList();
      return await _storageDataSource.saveLabels(labelsData);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Label>> searchLabels(String query) async {
    try {
      final labels = await getAllLabels();
      return labels.where((label) {
        return label.content.toLowerCase().contains(query.toLowerCase()) ||
            label.qrData.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Label>> getLabelsByDateRange(DateTime start, DateTime end) async {
    try {
      final labels = await getAllLabels();
      return labels.where((label) {
        return label.createdAt.isAfter(start) && label.createdAt.isBefore(end);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> getLabelStatistics() async {
    try {
      final labels = await getAllLabels();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final weekStart = today.subtract(Duration(days: today.weekday - 1));
      final monthStart = DateTime(now.year, now.month, 1);

      int todayCount = 0;
      int thisWeekCount = 0;
      int thisMonthCount = 0;

      for (final label in labels) {
        if (label.createdAt.isAfter(today)) {
          todayCount++;
        }
        if (label.createdAt.isAfter(weekStart)) {
          thisWeekCount++;
        }
        if (label.createdAt.isAfter(monthStart)) {
          thisMonthCount++;
        }
      }

      return {
        'total': labels.length,
        'today': todayCount,
        'thisWeek': thisWeekCount,
        'thisMonth': thisMonthCount,
      };
    } catch (e) {
      return {'total': 0, 'today': 0, 'thisWeek': 0, 'thisMonth': 0};
    }
  }

  Future<bool> exportLabels(String format) async {
    try {
      final labels = await getAllLabels();
      // Implementation for export functionality
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> importLabels(List<Label> labels) async {
    try {
      final existingLabels = await getAllLabels();
      existingLabels.addAll(labels);
      final labelsData = existingLabels.map((l) => l.toMap()).toList();
      return await _storageDataSource.saveLabels(labelsData);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Label>> getRecentLabels() async {
    try {
      final labels = await getAllLabels();
      labels.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return labels.take(10).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Label>> getLabelsCreatedToday() async {
    try {
      final labels = await getAllLabels();
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todayEnd = todayStart.add(Duration(days: 1));

      return labels.where((label) {
        return label.createdAt.isAfter(todayStart) &&
            label.createdAt.isBefore(todayEnd);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<String> exportLabelsToJson() async {
    try {
      final labels = await getAllLabels();
      final labelsData = labels.map((l) => l.toMap()).toList();
      return jsonEncode(labelsData);
    } catch (e) {
      return '[]';
    }
  }

  @override
  Future<bool> importLabelsFromJson(String jsonString) async {
    try {
      final labelsData = jsonDecode(jsonString) as List<dynamic>;
      final labels =
          labelsData
              .map((data) => Label.fromMap(data as Map<String, dynamic>))
              .toList();
      return await importLabels(labels);
    } catch (e) {
      return false;
    }
  }

  @override
  Label createLabel({
    required String content,
    required String qrData,
    Map<String, dynamic>? metadata,
  }) {
    return Label(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      qrData: qrData,
      createdAt: DateTime.now(),
      metadata: metadata ?? {},
    );
  }
}
