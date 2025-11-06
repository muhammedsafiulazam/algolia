import 'package:flutter_test/flutter_test.dart';
import 'package:macarons/lazyimage/cache/CacheManager.dart';
import 'dart:typed_data';

void main() {
  group('CacheManager', () {
    late CacheManager cacheManager;

    setUp(() {
      cacheManager = CacheManager();
      // Clear caches before each test
      cacheManager.clearMemoryCache();
    });

    test('should be a singleton', () {
      final instance1 = CacheManager();
      final instance2 = CacheManager();
      
      expect(instance1, same(instance2));
    });

    test('should initialize successfully', () async {
      await cacheManager.initialize();
      // Should not throw
      expect(cacheManager, isNotNull);
    });

    test('should return correct memory cache size', () {
      expect(cacheManager.memoryCacheSize, equals(0));
    });

    test('should clear memory cache', () {
      cacheManager.clearMemoryCache();
      expect(cacheManager.memoryCacheSize, equals(0));
    });

    test('should clear disk cache without error', () async {
      await cacheManager.clearDiskCache();
      // Should not throw
      expect(cacheManager, isNotNull);
    });

    test('should clear all caches without error', () async {
      await cacheManager.clearAll();
      expect(cacheManager.memoryCacheSize, equals(0));
    });

    test('should cancel loading for URL', () {
      // Should not throw even if URL is not loading
      cacheManager.cancelLoading('non-existent-url');
      expect(cacheManager, isNotNull);
    });

    test('should handle multiple initialization calls', () async {
      await cacheManager.initialize();
      await cacheManager.initialize(); // Second call should not cause issues
      expect(cacheManager, isNotNull);
    });
  });
}

