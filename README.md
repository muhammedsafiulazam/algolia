# Algolia Flutter Project

This project contains the **macarons** plugin, which provides a collection of Flutter utilities and components.

## Project Structure

```
algolia/
├── macarons/                    # Flutter plugin package
│   └── lib/
│       └── lazyimage/          # LazyImage library
│           ├── cache/          # Cache implementation
│           ├── LazyImage.dart  # Main widget
│           ├── LazyLoader.dart # Network loader
│           └── README.md       # Detailed documentation
└── lib/
    └── main.dart              # Demo application
```

## Macarons Plugin

**Macarons** is a Flutter plugin that provides a collection of useful Flutter components and utilities.

### Components

#### LazyImage

This is a lightweight Flutter library for lazy-loading images with efficient caching and cancellation support. Built without third-party dependencies, using only Flutter's built-in capabilities.

**Location**: `macarons/lib/lazyimage/`

**Features**:
- ✅ **Lazy Loading**: Images are downloaded only when needed
- ✅ **Async Downloads**: Non-blocking image loading using isolates
- ✅ **Request Cancellation**: Automatically cancels downloads when widgets are disposed
- ✅ **Memory Cache**: LRU-based in-memory cache for fast access (50 images)
- ✅ **Disk Cache**: Persistent storage for images (survives app restarts)
- ✅ **Zero Dependencies**: Uses only Flutter SDK and Dart standard library
- ✅ **Memory Efficient**: Prevents memory leaks with proper cleanup
- ✅ **Clean API**: Simple and intuitive widget interface
- ✅ **Auto-Initialization**: Cache manager initializes automatically on first use

## Quick Start

### Installation

Add macarons to your `pubspec.yaml`:

```yaml
dependencies:
  macarons:
    path: macarons
```

### Using LazyImage

#### Basic Usage

```dart
import 'package:macarons/lazyimage/LazyImage.dart';

LazyImage(
  url: 'https://example.com/image.jpg',
  width: 200,
  height: 200,
)
```

#### With Custom Placeholder and Error Widget

```dart
LazyImage(
  url: 'https://example.com/image.jpg',
  width: 200,
  height: 200,
  placeholder: CircularProgressIndicator(),
  errorWidget: Icon(Icons.error),
  fit: BoxFit.cover,
)
```

#### In a List (Search Results Example)

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

## Architecture

### LazyImage Components

1. **LazyImage** (`LazyImage.dart`): Main widget for displaying lazy-loaded images
2. **CacheManager** (`cache/CacheManager.dart`): Manages caching and loading coordination
3. **MemoryCache** (`cache/MemoryCache.dart`): LRU-based in-memory cache
4. **DiskCache** (`cache/DiskCache.dart`): Persistent file-based cache
5. **LazyLoader** (`LazyLoader.dart`): Handles async downloads with cancellation using isolates

### How It Works

```
Request Image
    ↓
Check Memory Cache → Hit? Return immediately
    ↓ Miss
Check Disk Cache → Hit? Load to Memory + Return
    ↓ Miss
Download in Isolate → Save to Memory + Disk → Return
```

### Performance Optimizations

- **Isolates**: Network downloads and disk I/O run in isolates to keep the main thread completely free
- **LRU Cache**: Memory cache uses Least Recently Used eviction policy
- **Request Deduplication**: Multiple requests for the same URL share the same download
- **Automatic Cancellation**: Downloads are cancelled when widgets are disposed
- **Auto-Initialization**: Cache manager initializes automatically on first use
- **Background Loading**: All network operations happen off the main thread
- **Memory Management**: Proper cleanup prevents memory leaks

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

## Demo

The project includes a demo application in `lib/main.dart` that showcases the LazyImage library with a list of images.

Run the demo:

```bash
flutter run
```

## Requirements

- Flutter SDK: `>=3.3.0`
- Dart SDK: `^3.9.0`

## Platform Support

- ✅ Android
- ✅ iOS

## Documentation

For detailed documentation, see:
- [LazyImage Library README](macarons/lib/lazyimage/README.md)

## License

This project is part of the Algolia technical test implementation.
