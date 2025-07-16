import 'package:flutter/foundation.dart';
import '../../domain/entities/label.dart';
import '../../domain/repositories/label_repository.dart';
import '../../data/repositories/label_repository_impl.dart';

class LabelViewModel extends ChangeNotifier {
  final LabelRepository _labelRepository;

  LabelViewModel({LabelRepository? labelRepository})
    : _labelRepository = labelRepository ?? LabelRepositoryImpl();

  List<Label> _labels = [];
  List<Label> _filteredLabels = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  List<Label> get labels => _labels;
  List<Label> get filteredLabels => _filteredLabels;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadLabels() async {
    _setLoading(true);
    try {
      _labels = await _labelRepository.getAllLabels();
      _applySearch();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createLabel({
    required String content,
    required String qrData,
  }) async {
    _setLoading(true);
    try {
      final label = Label(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        qrData: qrData,
        createdAt: DateTime.now(),
      );

      final success = await _labelRepository.saveLabel(label);
      if (success) {
        await loadLabels();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateLabel(Label label) async {
    _setLoading(true);
    try {
      final success = await _labelRepository.updateLabel(label);
      if (success) {
        await loadLabels();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteLabel(String id) async {
    _setLoading(true);
    try {
      final success = await _labelRepository.deleteLabel(id);
      if (success) {
        await loadLabels();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void searchLabels(String query) {
    _searchQuery = query;
    _applySearch();
  }

  void clearSearch() {
    _searchQuery = '';
    _applySearch();
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredLabels = List.from(_labels);
    } else {
      _filteredLabels =
          _labels.where((label) {
            return label.content.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                label.qrData.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> getLabelStatistics() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final weekStart = today.subtract(Duration(days: today.weekday - 1));
      final monthStart = DateTime(now.year, now.month, 1);

      int todayCount = 0;
      int thisWeekCount = 0;
      int thisMonthCount = 0;

      for (final label in _labels) {
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
        'total': _labels.length,
        'today': todayCount,
        'thisWeek': thisWeekCount,
        'thisMonth': thisMonthCount,
      };
    } catch (e) {
      return {'total': 0, 'today': 0, 'thisWeek': 0, 'thisMonth': 0};
    }
  }

  void refresh() {
    loadLabels();
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
