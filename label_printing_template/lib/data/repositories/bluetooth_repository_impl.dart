import '../../domain/repositories/bluetooth_repository.dart';

class BluetoothRepositoryImpl implements BluetoothRepository {
  BluetoothDevice? _connectedDevice;

  @override
  Future<List<BluetoothDevice>> getAvailableDevices({
    Duration timeout = const Duration(seconds: 4),
  }) async {
    // Mock implementation
    await Future.delayed(Duration(milliseconds: 500));
    return [
      BluetoothDevice(name: 'Test Printer 1', address: '00:11:22:33:44:55'),
      BluetoothDevice(name: 'Test Printer 2', address: 'AA:BB:CC:DD:EE:FF'),
    ];
  }

  @override
  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      await Future.delayed(Duration(milliseconds: 1000));
      _connectedDevice = device;
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> disconnect() async {
    await Future.delayed(Duration(milliseconds: 500));
    _connectedDevice = null;
  }

  @override
  BluetoothDevice? getConnectedDevice() {
    return _connectedDevice;
  }

  @override
  bool isConnected() {
    return _connectedDevice != null;
  }

  @override
  Future<bool> checkConnectionStatus() async {
    return _connectedDevice != null;
  }

  @override
  Future<List<BluetoothDevice>> getBondedDevices() async {
    return await getAvailableDevices();
  }

  @override
  Map<String, dynamic> getDeviceInfo(BluetoothDevice device) {
    final mockDevice = device;
    return {
      'name': mockDevice.name,
      'address': mockDevice.address,
      'type': mockDevice.type,
      'bondState': mockDevice.bondState,
    };
  }

  @override
  Future<bool> isBluetoothEnabled() async {
    return true; // Mock enabled
  }

  // Additional method for scanning devices
  @override
  Future<List<BluetoothDevice>> scanForDevices() async {
    return await getAvailableDevices();
  }

  // Additional method for initialization
  @override
  Future<void> initialize() async {
    await Future.delayed(Duration(milliseconds: 100));
  }

  // Additional method for connecting with device parameter
  @override
  Future<void> connect(BluetoothDevice device) async {
    await connectToDevice(device);
  }
}
