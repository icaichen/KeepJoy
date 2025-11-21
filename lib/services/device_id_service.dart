import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Service to generate and persist a unique device ID
/// This ID is used to track which device made changes for sync conflict resolution
class DeviceIdService {
  static const _deviceIdKey = 'device_id';
  static const _deviceNameKey = 'device_name';

  static DeviceIdService? _instance;
  static DeviceIdService get instance {
    _instance ??= DeviceIdService._();
    return _instance!;
  }

  DeviceIdService._();

  String? _cachedDeviceId;
  String? _cachedDeviceName;

  /// Get the unique device ID for this device
  /// Generates one if it doesn't exist
  Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }

    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_deviceIdKey);

    if (deviceId == null) {
      // Generate new device ID
      deviceId = const Uuid().v4();
      await prefs.setString(_deviceIdKey, deviceId);
      debugPrint('📱 Generated new device ID: $deviceId');
    }

    _cachedDeviceId = deviceId;
    return deviceId;
  }

  /// Get a human-readable device name
  Future<String> getDeviceName() async {
    if (_cachedDeviceName != null) {
      return _cachedDeviceName!;
    }

    final prefs = await SharedPreferences.getInstance();
    String? deviceName = prefs.getString(_deviceNameKey);

    if (deviceName == null) {
      // Generate device name based on platform
      deviceName = _generateDeviceName();
      await prefs.setString(_deviceNameKey, deviceName);
      debugPrint('📱 Generated device name: $deviceName');
    }

    _cachedDeviceName = deviceName;
    return deviceName;
  }

  /// Generate a device name based on platform info
  String _generateDeviceName() {
    if (kIsWeb) {
      return 'Web Browser';
    } else if (Platform.isAndroid) {
      return 'Android Device';
    } else if (Platform.isIOS) {
      return 'iPhone/iPad';
    } else if (Platform.isMacOS) {
      return 'Mac';
    } else if (Platform.isWindows) {
      return 'Windows PC';
    } else if (Platform.isLinux) {
      return 'Linux';
    } else {
      return 'Unknown Device';
    }
  }

  /// Set a custom device name (optional, for user preference)
  Future<void> setDeviceName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_deviceNameKey, name);
    _cachedDeviceName = name;
    debugPrint('📱 Device name set to: $name');
  }

  /// Clear cached values (for testing)
  void clearCache() {
    _cachedDeviceId = null;
    _cachedDeviceName = null;
  }

  /// Reset device ID (for testing or troubleshooting)
  Future<void> resetDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deviceIdKey);
    await prefs.remove(_deviceNameKey);
    clearCache();
    debugPrint('📱 Device ID reset');
  }
}
