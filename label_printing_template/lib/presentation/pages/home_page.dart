import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../viewmodels/printing_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _qrController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the printing view model
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrintingViewModel>().initialize();
    });
  }

  @override
  void dispose() {
    _qrController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Label Printing Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => Navigator.pushNamed(context, '/labels'),
          ),
        ],
      ),
      body: Consumer2<PrintingViewModel, SettingsViewModel>(
        builder: (context, printingVM, settingsVM, child) {
          // Update controllers when data changes
          if (_qrController.text != printingVM.qrData) {
            _qrController.text = printingVM.qrData;
          }
          if (_contentController.text != printingVM.labelContent) {
            _contentController.text = printingVM.labelContent;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Status Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Printer Status:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(printingVM.state),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                printingVM.state.name.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (printingVM.selectedDevice != null)
                          Text(
                            'Connected: ${printingVM.selectedDevice!.name}',
                            style: const TextStyle(color: Colors.green),
                          )
                        else
                          const Text(
                            'No printer connected',
                            style: TextStyle(color: Colors.red),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // QR Code Preview
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'QR Code Preview',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        QrImageView(
                          data:
                              printingVM.qrData.isEmpty
                                  ? 'Sample QR Data'
                                  : printingVM.qrData,
                          version: QrVersions.auto,
                          size: 150.0,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Input Fields
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Label Content',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _contentController,
                          decoration: const InputDecoration(
                            labelText: 'Text to print on label',
                            border: OutlineInputBorder(),
                            hintText: 'Enter label content...',
                          ),
                          onChanged:
                              (value) => printingVM.setLabelContent(value),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'QR Code Data',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _qrController,
                          decoration: const InputDecoration(
                            labelText: 'QR code content',
                            border: OutlineInputBorder(),
                            hintText: 'Enter QR code data...',
                          ),
                          onChanged: (value) => printingVM.setQrData(value),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Printer Selection
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Printer Selection',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed:
                              () => _showPrinterSelectionDialog(
                                context,
                                printingVM,
                              ),
                          icon: const Icon(Icons.bluetooth_searching),
                          label: Text(
                            printingVM.selectedDevice == null
                                ? 'Select Printer'
                                : 'Change Printer (${printingVM.selectedDevice!.name})',
                          ),
                        ),
                        if (printingVM.selectedDevice != null) ...[
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => printingVM.disconnect(),
                            icon: const Icon(Icons.bluetooth_disabled),
                            label: const Text('Disconnect'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Print Actions
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Print Actions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed:
                                    _canPrint(printingVM)
                                        ? () => _printLabel(context, printingVM)
                                        : null,
                                icon:
                                    printingVM.state == PrintState.loading ||
                                            printingVM.state ==
                                                PrintState.waiting ||
                                            printingVM.state ==
                                                PrintState.printing
                                        ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                        : const Icon(Icons.print),
                                label: Text(
                                  _getPrintButtonText(printingVM.state),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed:
                                    printingVM.selectedDevice != null
                                        ? () => _testPrint(context, printingVM)
                                        : null,
                                icon: const Icon(Icons.science),
                                label: const Text('Test Print'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(PrintState state) {
    switch (state) {
      case PrintState.idle:
        return Colors.green;
      case PrintState.loading:
        return Colors.blue;
      case PrintState.waiting:
        return Colors.orange;
      case PrintState.printing:
        return Colors.purple;
    }
  }

  String _getPrintButtonText(PrintState state) {
    switch (state) {
      case PrintState.idle:
        return 'Print Label';
      case PrintState.loading:
        return 'Connecting...';
      case PrintState.waiting:
        return 'Preparing...';
      case PrintState.printing:
        return 'Printing...';
    }
  }

  bool _canPrint(PrintingViewModel printingVM) {
    return printingVM.state == PrintState.idle &&
        printingVM.selectedDevice != null &&
        printingVM.qrData.isNotEmpty;
  }

  void _showPrinterSelectionDialog(
    BuildContext context,
    PrintingViewModel printingVM,
  ) async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Printer'),
            content: const SizedBox(
              width: double.maxFinite,
              child: Text('Scanning for Bluetooth devices...'),
            ),
          ),
    );

    try {
      await printingVM.scanForDevices();
      if (mounted) {
        Navigator.pop(context);

        if (printingVM.availableDevices.isEmpty) {
          _showNoDevicesDialog(context);
        } else {
          _showDeviceListDialog(context, printingVM);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showErrorDialog(context, 'Error scanning for devices: $e');
      }
    }
  }

  void _showDeviceListDialog(
    BuildContext context,
    PrintingViewModel printingVM,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Printer'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: printingVM.availableDevices.length,
                itemBuilder: (context, index) {
                  final device = printingVM.availableDevices[index];
                  return ListTile(
                    leading: const Icon(Icons.print),
                    title: Text(device.name ?? 'Unknown Device'),
                    subtitle: Text(device.address),
                    onTap: () async {
                      Navigator.pop(context);
                      await printingVM.selectDevice(device);
                      await printingVM.connectToSelectedDevice();
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  void _showNoDevicesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('No Devices Found'),
            content: const Text(
              'No Bluetooth printers were found. Please make sure your printer is turned on and in pairing mode.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _printLabel(BuildContext context, PrintingViewModel printingVM) async {
    final success = await printingVM.printCurrentLabel();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Label printed successfully!' : 'Failed to print label',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _testPrint(BuildContext context, PrintingViewModel printingVM) async {
    final success = await printingVM.testPrint();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Test print successful!' : 'Test print failed',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }
}
