import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';
import 'package:label_printing_template/utils/logger.dart';

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  BluetoothDevice? _connectedDevice;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  /// Scan for available Bluetooth devices
  Future<List<BluetoothDevice>> scanForDevices({
    Duration timeout = const Duration(seconds: 4),
  }) async {
    try {
      logger.i('Starting Bluetooth device scan...');

      // Stop any ongoing scan first
      await BluetoothPrintPlus.stopScan();

      // Start new scan
      await BluetoothPrintPlus.startScan(timeout: timeout);

      // Wait for scan results
      final devices = await BluetoothPrintPlus.scanResults.first;
      logger.i('Found ${devices.length} Bluetooth devices');

      // Stop scan after getting results
      await BluetoothPrintPlus.stopScan();

      return devices;
    } catch (e) {
      logger.e('Error scanning for Bluetooth devices: $e');
      // Ensure scan is stopped even if error occurs
      try {
        await BluetoothPrintPlus.stopScan();
      } catch (_) {}
      rethrow;
    }
  }

  /// Connect to a specific Bluetooth device
  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      logger.i('Connecting to device: ${device.name}');
      await BluetoothPrintPlus.connect(device);
      _connectedDevice = device;
      logger.i('Successfully connected to ${device.name}');
      return true;
    } catch (e) {
      logger.e('Error connecting to device: $e');
      return false;
    }
  }

  /// Disconnect from the current device
  Future<void> disconnect() async {
    try {
      if (_connectedDevice != null) {
        logger.i('Disconnecting from ${_connectedDevice!.name}');
        await BluetoothPrintPlus.disconnect();
        _connectedDevice = null;
        logger.i('Successfully disconnected');
      }
    } catch (e) {
      logger.e('Error disconnecting: $e');
    }
  }

  /// Check if currently connected to a device
  bool get isConnected => _connectedDevice != null;

  /// Get the current connection status
  Future<bool> checkConnectionStatus() async {
    try {
      // Use the package's connection status
      final isConnected = await BluetoothPrintPlus.isConnected;
      logger.i('Connection status check: $isConnected');
      return isConnected;
    } catch (e) {
      logger.e('Error checking connection status: $e');
      return false;
    }
  }

  /// Get bonded (paired) devices
  Future<List<BluetoothDevice>> getBondedDevices() async {
    try {
      logger.i('Getting bonded devices...');
      // Note: The bluetooth_print_plus package doesn't have a direct getBondedDevices method
      // This would typically be handled by the platform-specific implementation
      // For now, we'll return an empty list and handle this in the repository layer
      logger.i(
        'Bonded devices functionality not directly available in this package',
      );
      return [];
    } catch (e) {
      logger.e('Error getting bonded devices: $e');
      return [];
    }
  }

  /// Get current connection state
  Future<bool> getCurrentConnectionState() async {
    try {
      return await BluetoothPrintPlus.isConnected;
    } catch (e) {
      logger.e('Error getting current connection state: $e');
      return false;
    }
  }
}
