import 'dart:typed_data';
import 'dart:collection';

/// In-memory cache for images with LRU eviction policy.
class MemoryCache {
  final int maxSize;
  final LinkedHashMap<String, Uint8List> _cache = LinkedHashMap();

  MemoryCache({this.maxSize = 50});

  /// Gets an image from cache.
  Uint8List? get(String key) {
    final value = _cache.remove(key);
    if (value != null) {
      // Move to end (most recently used)
      _cache[key] = value;
      return value;
    }
    return null;
  }

  /// Puts an image into cache.
  void put(String key, Uint8List value) {
    if (_cache.containsKey(key)) {
      // Update existing entry
      _cache.remove(key);
    } else if (_cache.length >= maxSize) {
      // Remove least recently used (first entry)
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = value;
  }

  /// Removes an image from cache.
  void remove(String key) {
    _cache.remove(key);
  }

  /// Clears all cached images.
  void clear() {
    _cache.clear();
  }

  /// Gets the current cache size.
  int get size => _cache.length;

  /// Checks if cache contains the key.
  bool containsKey(String key) => _cache.containsKey(key);
}

