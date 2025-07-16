import '../entities/label.dart';

abstract class LabelRepository {
  Future<List<Label>> getAllLabels();
  Future<List<Label>> getRecentLabels();
  Future<Label?> getLabelById(String labelId);
  Future<List<Label>> searchLabels(String query);
  Future<List<Label>> getLabelsByDateRange(DateTime start, DateTime end);
  Future<List<Label>> getLabelsCreatedToday();
  Future<bool> saveLabel(Label label);
  Future<bool> updateLabel(Label label);
  Future<bool> deleteLabel(String labelId);
  Future<Map<String, dynamic>> getLabelStatistics();
  Future<String> exportLabelsToJson();
  Future<bool> importLabelsFromJson(String jsonString);
  Label createLabel({
    required String content,
    required String qrData,
    Map<String, dynamic>? metadata,
  });
}
