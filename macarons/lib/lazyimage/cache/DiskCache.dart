import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:isolate';

/// Disk cache for persistent image storage.
/// Uses the system's temporary directory for caching.
/// File I/O operations run in isolates using Isolate.run to keep the main thread free.
class DiskCache {

  static Directory? _cacheDir;
  static String _cacheDirName = 'lazyimage_cache';
  static bool _initialized = false;

  /// Initializes the cache directory.
  /// Uses the system temp directory if available.
  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      // Try to use system temp directory
      final systemTemp = Directory.systemTemp;
      if (await systemTemp.exists()) {
        _cacheDir = Directory('${systemTemp.path}/${_cacheDirName}');
        await _cacheDir!.create(recursive: true);
      }
    } catch (e) {
      // If initialization fails, disable disk cache
      _cacheDir = null;
    }
  }

  /// Gets an image from disk cache.
  /// Uses Isolate.run for file I/O to keep main thread free.
  /// Isolate.run is simpler than spawn for one-off operations that don't need cancellation.
  static Future<Uint8List?> get(String key) async {
    if (_cacheDir == null) return null;

    try {
      final path = '${_cacheDir!.path}/${_sanitizeKey(key)}';
      return await Isolate.run(() => _readFileInIsolate(path));
    } catch (e) {
      // Ignore errors
      return null;
    }
  }

  /// Puts an image into disk cache.
  /// Uses Isolate.run for file I/O to keep main thread free.
  /// Isolate.run is simpler than spawn for one-off operations that don't need cancellation.
  static Future<void> put(String key, Uint8List value) async {
    if (_cacheDir == null) return;

    try {
      final path = '${_cacheDir!.path}/${_sanitizeKey(key)}';
      await Isolate.run(() => _writeFileInIsolate(path, value));
    } catch (e) {
      // Ignore errors
    }
  }

  /// Removes an image from disk cache.
  static Future<void> remove(String key) async {
    if (_cacheDir == null) return;

    try {
      final file = File('${_cacheDir!.path}/${_sanitizeKey(key)}');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Ignore errors
    }
  }

  /// Clears all cached images.
  static Future<void> clear() async {
    if (_cacheDir == null) return;

    try {
      if (await _cacheDir!.exists()) {
        await for (final entity in _cacheDir!.list()) {
          await entity.delete(recursive: true);
        }
      }
    } catch (e) {
      // Ignore errors
    }
  }

  /// Sanitizes a URL key to be filesystem-safe.
  static String _sanitizeKey(String key) {
    // Use base64 encoding to create a safe filename
    final bytes = utf8.encode(key);
    final base64Key = base64Encode(bytes);
    return base64Key.replaceAll(RegExp(r'[^\w\-_\.]'), '_');
  }

  /// Reads file in isolate - static function for Isolate.run.
  static Future<Uint8List?> _readFileInIsolate(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
    } catch (e) {
      // Ignore errors
    }
    return null;
  }

  /// Writes file in isolate - static function for Isolate.run.
  static Future<void> _writeFileInIsolate(String path, Uint8List bytes) async {
    try {
      final file = File(path);
      await file.writeAsBytes(bytes);
    } catch (e) {
      // Ignore errors
    }
  }
}
