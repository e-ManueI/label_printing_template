import 'package:flutter/foundation.dart';
import '../../domain/repositories/printing_repository.dart';
import '../../domain/repositories/bluetooth_repository.dart';
import '../../domain/entities/label.dart';
import '../../domain/entities/printer_settings.dart';
import '../../data/repositories/printing_repository_impl.dart';
import '../../data/repositories/bluetooth_repository_impl.dart';

enum PrintState { idle, loading, waiting, printing }

class PrintingViewModel extends ChangeNotifier {
  final PrintingRepository _printingRepository;
  final BluetoothRepository _bluetoothRepository;

  PrintingViewModel({
    PrintingRepository? printingRepository,
    BluetoothRepository? bluetoothRepository,
  }) : _printingRepository = printingRepository ?? PrintingRepositoryImpl(),
       _bluetoothRepository = bluetoothRepository ?? BluetoothRepositoryImpl();

  PrintState _state = PrintState.idle;
  String _qrData = '';
  String _labelContent = '';
  List<BluetoothDevice> _availableDevices = [];
  BluetoothDevice? _selectedDevice;

  PrintState get state => _state;
  String get qrData => _qrData;
  String get labelContent => _labelContent;
  List<BluetoothDevice> get availableDevices => _availableDevices;
  BluetoothDevice? get selectedDevice => _selectedDevice;

  Future<void> initialize() async {
    _setState(PrintState.loading);
    try {
      await _bluetoothRepository.initialize();
      _setState(PrintState.idle);
    } catch (e) {
      _setState(PrintState.idle);
    }
  }

  void setQrData(String data) {
    _qrData = data;
    notifyListeners();
  }

  void setLabelContent(String content) {
    _labelContent = content;
    notifyListeners();
  }

  Future<void> scanForDevices() async {
    _setState(PrintState.loading);
    try {
      _availableDevices = await _bluetoothRepository.scanForDevices();
      _setState(PrintState.idle);
    } catch (e) {
      _setState(PrintState.idle);
      rethrow;
    }
  }

  Future<void> selectDevice(BluetoothDevice device) async {
    _selectedDevice = device;
    notifyListeners();
  }

  Future<void> connectToSelectedDevice() async {
    if (_selectedDevice == null) return;

    _setState(PrintState.loading);
    try {
      await _bluetoothRepository.connect(_selectedDevice!);
      _setState(PrintState.idle);
    } catch (e) {
      _setState(PrintState.idle);
      rethrow;
    }
  }

  Future<void> disconnect() async {
    if (_selectedDevice == null) return;

    _setState(PrintState.loading);
    try {
      await _bluetoothRepository.disconnect();
      _selectedDevice = null;
      _setState(PrintState.idle);
    } catch (e) {
      _setState(PrintState.idle);
      rethrow;
    }
  }

  Future<bool> printCurrentLabel() async {
    if (_selectedDevice == null || _qrData.isEmpty) return false;

    _setState(PrintState.printing);
    try {
      final label = Label(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: _labelContent,
        qrData: _qrData,
        createdAt: DateTime.now(),
      );
      final settings = PrinterSettings.defaultSettings();
      final success = await _printingRepository.printLabel(label, settings);
      _setState(PrintState.idle);
      return success;
    } catch (e) {
      _setState(PrintState.idle);
      return false;
    }
  }

  Future<bool> testPrint() async {
    if (_selectedDevice == null) return false;

    _setState(PrintState.printing);
    try {
      final settings = PrinterSettings.defaultSettings();
      final success = await _printingRepository.testPrint(settings);
      _setState(PrintState.idle);
      return success;
    } catch (e) {
      _setState(PrintState.idle);
      return false;
    }
  }

  void _setState(PrintState newState) {
    _state = newState;
    notifyListeners();
  }
}
