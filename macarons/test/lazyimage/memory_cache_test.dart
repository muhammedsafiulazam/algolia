import 'package:flutter_test/flutter_test.dart';
import 'package:macarons/lazyimage/cache/MemoryCache.dart';
import 'dart:typed_data';

void main() {
  group('MemoryCache', () {
    test('should return null for non-existent key', () {
      final cache = MemoryCache();
      expect(cache.get('non-existent'), isNull);
    });

    test('should store and retrieve values', () {
      final cache = MemoryCache();
      final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      
      cache.put('key1', bytes);
      final retrieved = cache.get('key1');
      
      expect(retrieved, equals(bytes));
      expect(retrieved, isNotNull);
    });

    test('should update existing entry', () {
      final cache = MemoryCache();
      final bytes1 = Uint8List.fromList([1, 2, 3]);
      final bytes2 = Uint8List.fromList([4, 5, 6]);
      
      cache.put('key1', bytes1);
      cache.put('key1', bytes2);
      
      expect(cache.get('key1'), equals(bytes2));
      expect(cache.size, equals(1));
    });

    test('should evict least recently used when max size reached', () {
      final cache = MemoryCache(maxSize: 3);
      
      cache.put('key1', Uint8List.fromList([1]));
      cache.put('key2', Uint8List.fromList([2]));
      cache.put('key3', Uint8List.fromList([3]));
      
      // All 3 entries should be present
      expect(cache.size, equals(3));
      expect(cache.get('key1'), isNotNull);
      expect(cache.get('key2'), isNotNull);
      expect(cache.get('key3'), isNotNull);
      
      // Add 4th entry - should evict key1 (least recently used)
      cache.put('key4', Uint8List.fromList([4]));
      
      expect(cache.size, equals(3));
      expect(cache.get('key1'), isNull); // Should be evicted
      expect(cache.get('key2'), isNotNull);
      expect(cache.get('key3'), isNotNull);
      expect(cache.get('key4'), isNotNull);
    });

    test('should move accessed item to most recently used', () {
      final cache = MemoryCache(maxSize: 3);
      
      cache.put('key1', Uint8List.fromList([1]));
      cache.put('key2', Uint8List.fromList([2]));
      cache.put('key3', Uint8List.fromList([3]));
      
      // Access key1 to make it most recently used
      cache.get('key1');
      
      // Add 4th entry - should evict key2 (not key1)
      cache.put('key4', Uint8List.fromList([4]));
      
      expect(cache.get('key1'), isNotNull); // Should still be present
      expect(cache.get('key2'), isNull); // Should be evicted
      expect(cache.get('key3'), isNotNull);
      expect(cache.get('key4'), isNotNull);
    });

    test('should remove specific key', () {
      final cache = MemoryCache();
      
      cache.put('key1', Uint8List.fromList([1]));
      cache.put('key2', Uint8List.fromList([2]));
      
      expect(cache.size, equals(2));
      
      cache.remove('key1');
      
      expect(cache.size, equals(1));
      expect(cache.get('key1'), isNull);
      expect(cache.get('key2'), isNotNull);
    });

    test('should clear all entries', () {
      final cache = MemoryCache();
      
      cache.put('key1', Uint8List.fromList([1]));
      cache.put('key2', Uint8List.fromList([2]));
      cache.put('key3', Uint8List.fromList([3]));
      
      expect(cache.size, equals(3));
      
      cache.clear();
      
      expect(cache.size, equals(0));
      expect(cache.get('key1'), isNull);
      expect(cache.get('key2'), isNull);
      expect(cache.get('key3'), isNull);
    });

    test('should check if key exists', () {
      final cache = MemoryCache();
      
      expect(cache.containsKey('key1'), isFalse);
      
      cache.put('key1', Uint8List.fromList([1]));
      
      expect(cache.containsKey('key1'), isTrue);
      expect(cache.containsKey('key2'), isFalse);
    });

    test('should return correct size', () {
      final cache = MemoryCache();
      
      expect(cache.size, equals(0));
      
      cache.put('key1', Uint8List.fromList([1]));
      expect(cache.size, equals(1));
      
      cache.put('key2', Uint8List.fromList([2]));
      expect(cache.size, equals(2));
      
      cache.remove('key1');
      expect(cache.size, equals(1));
    });
  });
}

