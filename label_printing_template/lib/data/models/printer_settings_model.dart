class PrinterSettingsModel {
  final double paperWidth;
  final String unit;
  final int density;
  final int gap;
  final String printerType;
  final Map<String, dynamic> customSettings;

  PrinterSettingsModel({
    required this.paperWidth,
    required this.unit,
    required this.density,
    required this.gap,
    required this.printerType,
    this.customSettings = const {},
  });

  factory PrinterSettingsModel.defaultSettings() {
    return PrinterSettingsModel(
      paperWidth: 58.0,
      unit: 'mm',
      density: 8,
      gap: 20,
      printerType: 'TSPL',
    );
  }

  factory PrinterSettingsModel.fromJson(Map<String, dynamic> json) {
    return PrinterSettingsModel(
      paperWidth: json['paperWidth']?.toDouble() ?? 58.0,
      unit: json['unit'] as String? ?? 'mm',
      density: json['density'] as int? ?? 8,
      gap: json['gap'] as int? ?? 20,
      printerType: json['printerType'] as String? ?? 'TSPL',
      customSettings: json['customSettings'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paperWidth': paperWidth,
      'unit': unit,
      'density': density,
      'gap': gap,
      'printerType': printerType,
      'customSettings': customSettings,
    };
  }

  PrinterSettingsModel copyWith({
    double? paperWidth,
    String? unit,
    int? density,
    int? gap,
    String? printerType,
    Map<String, dynamic>? customSettings,
  }) {
    return PrinterSettingsModel(
      paperWidth: paperWidth ?? this.paperWidth,
      unit: unit ?? this.unit,
      density: density ?? this.density,
      gap: gap ?? this.gap,
      printerType: printerType ?? this.printerType,
      customSettings: customSettings ?? this.customSettings,
    );
  }
}
