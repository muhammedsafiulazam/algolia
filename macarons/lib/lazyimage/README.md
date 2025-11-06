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
import 'package:macarons/LazyImage/lazy_image.dart';

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

Singleton class for managing image cache.

```dart
final cacheManager = CacheManager();

// Initialize (optional, called automatically)
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

## Architecture

### Components

1. **LazyImage**: The main widget that displays images
2. **CacheManager**: Manages caching and loading coordination
3. **MemoryCache**: LRU-based in-memory cache
4. **DiskCache**: Persistent file-based cache
5. **LazyLoader**: Handles async downloads with cancellation

### Performance Optimizations

- **LRU Cache**: Memory cache uses Least Recently Used eviction policy
- **Request Deduplication**: Multiple requests for the same URL share the same download
- **Automatic Cancellation**: Downloads are cancelled when widgets are disposed
- **Background Loading**: All network operations happen off the main thread
- **Memory Management**: Proper cleanup prevents memory leaks

## Requirements

- Flutter SDK: `>=3.3.0`
- Dart SDK: `^3.9.0`

## License

This library is part of the macarons package.

