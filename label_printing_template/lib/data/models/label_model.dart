class LabelModel {
  final String id;
  final String content;
  final String qrData;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  LabelModel({
    required this.id,
    required this.content,
    required this.qrData,
    required this.createdAt,
    this.metadata = const {},
  });

  factory LabelModel.fromJson(Map<String, dynamic> json) {
    return LabelModel(
      id: json['id'] as String,
      content: json['content'] as String,
      qrData: json['qrData'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'qrData': qrData,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  LabelModel copyWith({
    String? id,
    String? content,
    String? qrData,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return LabelModel(
      id: id ?? this.id,
      content: content ?? this.content,
      qrData: qrData ?? this.qrData,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }
}
