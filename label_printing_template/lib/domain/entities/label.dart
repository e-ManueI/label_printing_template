class Label {
  final String id;
  final String content;
  final String qrData;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  Label({
    required this.id,
    required this.content,
    required this.qrData,
    required this.createdAt,
    this.metadata = const {},
  });

  Label copyWith({
    String? id,
    String? content,
    String? qrData,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return Label(
      id: id ?? this.id,
      content: content ?? this.content,
      qrData: qrData ?? this.qrData,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Label && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Label(id: $id, content: $content, qrData: $qrData)';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'qrData': qrData,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory Label.fromMap(Map<String, dynamic> map) {
    return Label(
      id: map['id'] ?? '',
      content: map['content'] ?? '',
      qrData: map['qrData'] ?? '',
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }
}
