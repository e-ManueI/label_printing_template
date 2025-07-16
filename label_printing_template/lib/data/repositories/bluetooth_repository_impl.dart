import '../../domain/repositories/bluetooth_repository.dart';
import '../datasources/services/bluetooth_service_datasource.dart';
import '../../utils/logger.dart';

class BluetoothRepositoryImpl implements BluetoothRepository {
  final BluetoothService _bluetoothService = BluetoothService();

  @override
  Future<List<BluetoothDevice>> getAvailableDevices({
    Duration timeout = const Duration(seconds: 4),
  }) async {
    try {
      logger.i('Getting available Bluetooth devices...');
      final devices = await _bluetoothService.scanForDevices(timeout: timeout);
      return devices
          .map(
            (device) => BluetoothDevice(
              name: device.name ?? 'Unknown Device',
              address: device.address ?? '',
              type: 'Unknown',
              bondState: 0,
            ),
          )
          .toList();
    } catch (e) {
      logger.e('Error getting available devices: $e');
      return [];
    }
  }

  @override
  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      logger.i('Connecting to device: ${device.name}');
      final bluetoothDevice = await _findBluetoothDevice(device.address);
      if (bluetoothDevice != null) {
        return await _bluetoothService.connectToDevice(bluetoothDevice);
      }
      return false;
    } catch (e) {
      logger.e('Error connecting to device: $e');
      return false;
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      logger.i('Disconnecting from current device');
      await _bluetoothService.disconnect();
    } catch (e) {
      logger.e('Error disconnecting: $e');
    }
  }

  @override
  BluetoothDevice? getConnectedDevice() {
    final device = _bluetoothService.connectedDevice;
    if (device != null) {
      return BluetoothDevice(
        name: device.name ?? 'Unknown Device',
        address: device.address ?? '',
        type: 'Unknown',
        bondState: 0,
      );
    }
    return null;
  }

  @override
  bool isConnected() {
    return _bluetoothService.isConnected;
  }

  @override
  Future<bool> checkConnectionStatus() async {
    try {
      return await _bluetoothService.checkConnectionStatus();
    } catch (e) {
      logger.e('Error checking connection status: $e');
      return false;
    }
  }

  @override
  Future<List<BluetoothDevice>> getBondedDevices() async {
    try {
      logger.i('Getting bonded devices...');
      final devices = await _bluetoothService.getBondedDevices();
      return devices
          .map(
            (device) => BluetoothDevice(
              name: device.name ?? 'Unknown Device',
              address: device.address ?? '',
              type: 'Unknown',
              bondState: 0,
            ),
          )
          .toList();
    } catch (e) {
      logger.e('Error getting bonded devices: $e');
      return [];
    }
  }

  @override
  Map<String, dynamic> getDeviceInfo(BluetoothDevice device) {
    return {
      'name': device.name,
      'address': device.address,
      'type': device.type,
      'bondState': device.bondState,
    };
  }

  @override
  Future<bool> isBluetoothEnabled() async {
    try {
      // The bluetooth_print_plus package handles this internally
      // We'll assume it's enabled if we can scan for devices
      final devices = await getAvailableDevices();
      return true;
    } catch (e) {
      logger.e('Error checking Bluetooth status: $e');
      return false;
    }
  }

  @override
  Future<List<BluetoothDevice>> scanForDevices() async {
    return await getAvailableDevices();
  }

  @override
  Future<void> initialize() async {
    try {
      logger.i('Initializing Bluetooth service...');
      // The bluetooth_print_plus package initializes automatically
      // We just need to ensure we're ready to scan
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      logger.e('Error initializing Bluetooth: $e');
    }
  }

  @override
  Future<void> connect(BluetoothDevice device) async {
    await connectToDevice(device);
  }

  /// Helper method to find a BluetoothDevice from the service by address
  Future<dynamic> _findBluetoothDevice(String address) async {
    try {
      final devices = await _bluetoothService.scanForDevices();
      for (final device in devices) {
        if (device.address == address) {
          return device;
        }
      }
      return null;
    } catch (e) {
      logger.e('Error finding Bluetooth device: $e');
      return null;
    }
  }
}
