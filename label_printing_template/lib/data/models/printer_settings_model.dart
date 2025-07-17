class PrinterSettingsModel {
  final double paperWidth;
  final double paperHeight;
  final String unit;
  final int density;
  final int gap;
  final String printerType;
  final Map<String, dynamic> customSettings;
  final int? dpi;

  PrinterSettingsModel({
    required this.paperWidth,
    required this.paperHeight,
    required this.unit,
    required this.density,
    required this.gap,
    required this.printerType,
    this.customSettings = const {},
    this.dpi,
  });

  factory PrinterSettingsModel.defaultSettings() {
    return PrinterSettingsModel(
      paperWidth: 58.0,
      paperHeight: 58.0,
      unit: 'mm',
      density: 8,
      gap: 20,
      printerType: 'TSC',
    );
  }

  factory PrinterSettingsModel.fromJson(Map<String, dynamic> json) {
    return PrinterSettingsModel(
      paperWidth: json['paperWidth']?.toDouble() ?? 58.0,
      paperHeight: json['paperHeight']?.toDouble() ?? 58.0,
      unit: json['unit'] as String? ?? 'mm',
      density: json['density'] as int? ?? 8,
      gap: json['gap'] as int? ?? 20,
      printerType: json['printerType'] as String? ?? 'TSC',
      customSettings: json['customSettings'] as Map<String, dynamic>? ?? {},
      dpi: json['dpi'] as int? ?? 8,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paperWidth': paperWidth,
      'paperHeight': paperHeight,
      'unit': unit,
      'density': density,
      'gap': gap,
      'printerType': printerType,
      'customSettings': customSettings,
      'dpi': dpi,
    };
  }

  PrinterSettingsModel copyWith({
    double? paperWidth,
    double? paperHeight,
    String? unit,
    int? density,
    int? gap,
    String? printerType,
    Map<String, dynamic>? customSettings,
    int? dpi,
  }) {
    return PrinterSettingsModel(
      paperWidth: paperWidth ?? this.paperWidth,
      paperHeight: paperHeight ?? this.paperHeight,
      unit: unit ?? this.unit,
      density: density ?? this.density,
      gap: gap ?? this.gap,
      printerType: printerType ?? this.printerType,
      customSettings: customSettings ?? this.customSettings,
      dpi: dpi ?? this.dpi,
    );
  }
}
