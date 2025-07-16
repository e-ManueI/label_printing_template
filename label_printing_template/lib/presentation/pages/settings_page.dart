import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Load settings when the screen is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsViewModel>().loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<SettingsViewModel>().clearError();
            },
          ),
        ],
      ),
      body: Consumer<SettingsViewModel>(
        builder: (context, settingsVM, child) {
          if (settingsVM.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (settingsVM.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${settingsVM.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      settingsVM.clearError();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (settingsVM.settings == null) {
            return const Center(child: Text('Loading settings...'));
          }

          final settings = settingsVM.settings!;
          final paperWidthController = TextEditingController(
            text: settings.paperWidth.toString(),
          );
          final densityController = TextEditingController(
            text: settings.density.toString(),
          );
          final gapController = TextEditingController(
            text: settings.gap.toString(),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Paper Width
                const Text(
                  'Paper Width',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: paperWidthController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    suffixText: settings.unit,
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (value) {
                    final width = double.tryParse(value);
                    if (width != null) {
                      settingsVM.setPaperWidth(width);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Units of Measurement
                const Text(
                  'Units of Measurement',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: settings.unit,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items:
                      settingsVM.getAvailableUnits().map((unit) {
                        String displayName;
                        switch (unit) {
                          case 'mm':
                            displayName = 'Millimeters (mm)';
                            break;
                          case 'inch':
                            displayName = 'Inches (in)';
                            break;
                          case 'dots':
                            displayName = 'Dots';
                            break;
                          default:
                            displayName = unit;
                        }
                        return DropdownMenuItem(
                          value: unit,
                          child: Text(displayName),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      settingsVM.setUnit(value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Density
                const Text(
                  'Print Density',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: densityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    helperText: 'Range: 1-15 (Default: 8)',
                  ),
                  onSubmitted: (value) {
                    final density = int.tryParse(value);
                    if (density != null && density >= 1 && density <= 15) {
                      settingsVM.setDensity(density);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Gap
                const Text(
                  'Label Gap',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: gapController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    helperText: 'Gap between labels in dots',
                  ),
                  onSubmitted: (value) {
                    final gap = int.tryParse(value);
                    if (gap != null && gap >= 0) {
                      settingsVM.setGap(gap);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Printer Type
                const Text(
                  'Printer Type',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value:
                      settingsVM.getAvailablePrinterTypes().contains(
                            settings.printerType,
                          )
                          ? settings.printerType
                          : 'TSC',
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items:
                      settingsVM.getAvailablePrinterTypes().map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      settingsVM.setPrinterType(value);
                    }
                  },
                ),
                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => settingsVM.resetToDefaults(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: const Text('Reset to Defaults'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Save & Back'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
