import 'dart:typed_data';
import '../LazyLoader.dart';
import 'MemoryCache.dart';
import 'DiskCache.dart';

/// Manages image caching and loading with memory and disk cache support.
class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  final MemoryCache _memoryCache = MemoryCache(maxSize: 50);
  final Map<String, Future<Uint8List?>> _loadingFutures = {};
  final Map<String, LazyLoader> _activeLoaders = {};
  bool _initialized = false;
  Future<void>? _initializationFuture;

  /// Initializes the cache manager.
  /// Can be called manually, but will auto-initialize on first use if not called.
  Future<void> initialize() async {
    if (_initialized) return;
    if (_initializationFuture != null) {
      return _initializationFuture!;
    }
    
    _initializationFuture = _doInitialize();
    await _initializationFuture!;
  }

  Future<void> _doInitialize() async {
    await DiskCache.initialize();
    _initialized = true;
  }

  /// Gets an image from cache or downloads it if not cached.
  /// Returns null if download fails or is cancelled.
  /// Auto-initializes the cache manager on first use if not already initialized.
  Future<Uint8List?> getImage(String url) async {
    // Auto-initialize on first use
    await initialize();

    // Check memory cache first
    final cached = _memoryCache.get(url);
    if (cached != null) {
      return cached;
    }

    // Check if already loading
    if (_loadingFutures.containsKey(url)) {
      return _loadingFutures[url];
    }

    // Check disk cache
    final diskCached = await DiskCache.get(url);
    if (diskCached != null) {
      _memoryCache.put(url, diskCached);
      return diskCached;
    }

    // Start downloading
    final loader = LazyLoader(url);
    _activeLoaders[url] = loader;

    final future = loader.download().then((bytes) {
      _loadingFutures.remove(url);
      _activeLoaders.remove(url);

      if (bytes != null) {
        // Store in both caches
        _memoryCache.put(url, bytes);
        DiskCache.put(url, bytes);
      }

      return bytes;
    });

    _loadingFutures[url] = future;
    return future;
  }

  /// Cancels loading for a specific URL.
  void cancelLoading(String url) {
    final loader = _activeLoaders.remove(url);
    loader?.cancel();
    _loadingFutures.remove(url);
  }

  /// Clears memory cache.
  void clearMemoryCache() {
    _memoryCache.clear();
  }

  /// Clears disk cache.
  Future<void> clearDiskCache() async {
    await DiskCache.clear();
  }

  /// Clears all caches.
  Future<void> clearAll() async {
    clearMemoryCache();
    await clearDiskCache();
  }

  /// Gets memory cache size.
  int get memoryCacheSize => _memoryCache.size;
}

