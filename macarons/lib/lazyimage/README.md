# LazyImage Library

This is a lightweight Flutter library for lazy-loading images with efficient caching and cancellation support. Built without third-party dependencies, using only Flutter's built-in capabilities.

## Features

- ✅ **Lazy Loading**: Images are downloaded only when needed
- ✅ **Async Downloads**: Non-blocking image loading on background threads
- ✅ **Request Cancellation**: Automatically cancels downloads when widgets are disposed
- ✅ **Memory Cache**: LRU-based in-memory cache for fast access
- ✅ **Disk Cache**: Persistent storage for images (survives app restarts)
- ✅ **Zero Dependencies**: Uses only Flutter SDK and Dart standard library
- ✅ **Memory Efficient**: Prevents memory leaks with proper cleanup
- ✅ **Clean API**: Simple and intuitive widget interface

## Usage

### Basic Example

```dart
import 'package:macarons/lazyimage/LazyImage.dart';

LazyImage(
  url: 'https://example.com/image.jpg',
  width: 200,
  height: 200,
)
```

### With Placeholder and Error Widget

```dart
LazyImage(
  url: 'https://example.com/image.jpg',
  width: 200,
  height: 200,
  placeholder: CircularProgressIndicator(),
  errorWidget: Icon(Icons.error),
)
```

### In a List (Search Results Example)

```dart
ListView.builder(
  itemCount: searchResults.length,
  itemBuilder: (context, index) {
    final hit = searchResults[index];
    return ListTile(
      leading: LazyImage(
        url: hit.imageUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      ),
      title: Text(hit.title),
    );
  },
)
```

## API Reference

### LazyImage Widget

The main widget for lazy-loading images.

#### Properties

- `url` (required): The URL of the image to load
- `width`: The width of the image
- `height`: The height of the image
- `placeholder`: Widget to display while loading (default: `CircularProgressIndicator`)
- `errorWidget`: Widget to display on error (default: `Icon(Icons.error)`)
- `fit`: How to inscribe the image (`BoxFit`, default: `BoxFit.cover`)
- `alignment`: Image alignment (default: `Alignment.center`)
- `repeat`: How to repeat the image (default: `ImageRepeat.noRepeat`)
- `color`: Color to blend with the image
- `colorFilter`: Color filter to apply
- `semanticLabel`: Semantic label for accessibility
- `excludeFromSemantics`: Whether to exclude from semantics
- `enableDiskCache`: Whether to enable disk caching (default: `true`)

### CacheManager

Singleton class for managing image cache. Auto-initializes on first use, so manual initialization is optional.

```dart
import 'package:macarons/lazyimage/cache/CacheManager.dart';

final cacheManager = CacheManager();

// Initialize (optional - auto-initializes on first use)
await cacheManager.initialize();

// Clear memory cache
cacheManager.clearMemoryCache();

// Clear disk cache
await cacheManager.clearDiskCache();

// Clear all caches
await cacheManager.clearAll();

// Get cache size
final size = cacheManager.memoryCacheSize;
```

### LazyLoader

Low-level class for downloading images directly without caching. Useful when you need fine-grained control over downloads or want to implement custom caching logic.

```dart
import 'package:macarons/lazyimage/LazyLoader.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

// Create a loader for a specific URL
final loader = LazyLoader('https://example.com/image.jpg');

// Download the image (runs in isolate)
final bytes = await loader.download();

if (bytes != null) {
  // Use the image bytes
  final image = Image.memory(bytes);
  // ... display image
} else {
  // Download failed or was cancelled
  print('Failed to load image');
}

// Cancel download if needed
loader.cancel();
```

#### Advanced Usage: Manual Download Management

```dart
import 'package:macarons/lazyimage/LazyLoader.dart';
import 'dart:async';
import 'dart:typed_data';

// Download with cancellation support
Future<void> downloadImage(String url) async {
  final loader = LazyLoader(url);
  
  // Start download
  final downloadFuture = loader.download();
  
  // You can cancel it anytime
  Timer(Duration(seconds: 5), () {
    loader.cancel(); // Cancel after 5 seconds
  });
  
  final bytes = await downloadFuture;
  
  if (bytes != null) {
    // Process image bytes
    processImage(bytes);
  }
}

// Multiple downloads with individual cancellation
class ImageDownloader {
  final Map<String, LazyLoader> _loaders = {};
  
  Future<Uint8List?> download(String url) async {
    // Cancel previous download for same URL if exists
    _loaders[url]?.cancel();
    
    final loader = LazyLoader(url);
    _loaders[url] = loader;
    
    try {
      final bytes = await loader.download();
      _loaders.remove(url);
      return bytes;
    } catch (e) {
      _loaders.remove(url);
      return null;
    }
  }
  
  void cancel(String url) {
    _loaders[url]?.cancel();
    _loaders.remove(url);
  }
  
  void cancelAll() {
    for (final loader in _loaders.values) {
      loader.cancel();
    }
    _loaders.clear();
  }
}
```

#### When to Use LazyLoader Directly

- **Custom caching logic**: When you need to implement your own caching strategy
- **Background downloads**: When downloading images outside of widget context
- **Batch processing**: When downloading multiple images with custom coordination
- **Progress tracking**: When you need to track download progress (can be extended)
- **Custom error handling**: When you need fine-grained error handling

**Note**: For most use cases, `LazyImage` widget or `CacheManager` are recommended as they provide caching and easier integration with Flutter widgets.

## Architecture

### Components

1. **LazyImage**: The main widget that displays images
2. **CacheManager** (`cache/CacheManager.dart`): Manages caching and loading coordination
3. **MemoryCache** (`cache/MemoryCache.dart`): LRU-based in-memory cache
4. **DiskCache** (`cache/DiskCache.dart`): Persistent file-based cache
5. **LazyLoader**: Handles async downloads with cancellation using isolates

### Project Structure

```
lazyimage/
├── cache/
│   ├── CacheManager.dart    # Main cache coordinator
│   ├── MemoryCache.dart      # In-memory LRU cache
│   └── DiskCache.dart        # Persistent file cache
├── LazyImage.dart            # Main widget
├── LazyLoader.dart           # Network download handler
└── README.md
```

### Performance Optimizations

- **Isolates**: Network downloads and disk I/O run in isolates to keep the main thread completely free
- **LRU Cache**: Memory cache uses Least Recently Used eviction policy
- **Request Deduplication**: Multiple requests for the same URL share the same download
- **Automatic Cancellation**: Downloads are cancelled when widgets are disposed
- **Auto-Initialization**: Cache manager initializes automatically on first use
- **Background Loading**: All network operations happen off the main thread
- **Memory Management**: Proper cleanup prevents memory leaks

## Requirements

- Flutter SDK: `>=3.3.0`
- Dart SDK: `^3.9.0`

## License

This library is part of the macarons package.

