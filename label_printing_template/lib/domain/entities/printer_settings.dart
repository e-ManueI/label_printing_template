class PrinterSettings {
  final double paperWidth;
  final String unit;
  final int density;
  final int gap;
  final String printerType;
  final Map<String, dynamic> customSettings;

  PrinterSettings({
    required this.paperWidth,
    required this.unit,
    required this.density,
    required this.gap,
    required this.printerType,
    this.customSettings = const {},
  });

  factory PrinterSettings.defaultSettings() {
    return PrinterSettings(
      paperWidth: 58.0,
      unit: 'mm',
      density: 8,
      gap: 20,
      printerType: 'TSC',
    );
  }

  PrinterSettings copyWith({
    double? paperWidth,
    String? unit,
    int? density,
    int? gap,
    String? printerType,
    Map<String, dynamic>? customSettings,
  }) {
    return PrinterSettings(
      paperWidth: paperWidth ?? this.paperWidth,
      unit: unit ?? this.unit,
      density: density ?? this.density,
      gap: gap ?? this.gap,
      printerType: printerType ?? this.printerType,
      customSettings: customSettings ?? this.customSettings,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PrinterSettings &&
        other.paperWidth == paperWidth &&
        other.unit == unit &&
        other.density == density &&
        other.gap == gap &&
        other.printerType == printerType;
  }

  @override
  int get hashCode {
    return Object.hash(paperWidth, unit, density, gap, printerType);
  }

  @override
  String toString() {
    return 'PrinterSettings(paperWidth: $paperWidth, unit: $unit, density: $density, gap: $gap, printerType: $printerType)';
  }
}
