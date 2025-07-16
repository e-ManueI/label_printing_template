// Simple BluetoothDevice class for the domain layer
class BluetoothDevice {
  final String name;
  final String address;
  final String type;
  final int bondState;

  BluetoothDevice({
    required this.name,
    required this.address,
    this.type = 'Unknown',
    this.bondState = 0,
  });
}

abstract class BluetoothRepository {
  Future<List<BluetoothDevice>> getAvailableDevices({
    Duration timeout = const Duration(seconds: 4),
  });
  Future<bool> connectToDevice(BluetoothDevice device);
  Future<void> disconnect();
  BluetoothDevice? getConnectedDevice();
  bool isConnected();
  Future<bool> checkConnectionStatus();
  Future<List<BluetoothDevice>> getBondedDevices();
  Map<String, dynamic> getDeviceInfo(BluetoothDevice device);
  Future<bool> isBluetoothEnabled();

  // Additional methods for convenience
  Future<void> initialize();
  Future<List<BluetoothDevice>> scanForDevices();
  Future<void> connect(BluetoothDevice device);
}
