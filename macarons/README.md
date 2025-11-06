# Macarons

A Flutter plugin package providing a collection of useful Flutter components and utilities.

## Overview

Macarons is a Flutter plugin that includes the **LazyImage** library - a lightweight, efficient image lazy-loading solution built without third-party dependencies.

## Components

### LazyImage

This is a powerful image lazy-loading library with efficient caching and cancellation support. Perfect for implementing image-heavy UIs like search results, galleries, or product listings.

**Location**: `lib/lazyimage/`

**Key Features**:
- ✅ Lazy loading - Images download only when needed
- ✅ Memory & disk caching - Fast access with persistence
- ✅ Request cancellation - Automatic cleanup on widget disposal
- ✅ Isolate-based downloads - Keeps main thread free
- ✅ Zero dependencies - Uses only Flutter SDK
- ✅ Auto-initialization - Works out of the box

## Quick Start

### Installation

Add macarons to your `pubspec.yaml`:

```yaml
dependencies:
  macarons:
    path: macarons  # or use git/pub.dev URL
```

### Using LazyImage

```dart
import 'package:macarons/lazyimage/LazyImage.dart';

LazyImage(
  url: 'https://example.com/image.jpg',
  width: 200,
  height: 200,
)
```

### Using LazyLoader (Low-level API)

```dart
import 'package:macarons/lazyimage/LazyLoader.dart';
import 'dart:typed_data';

final loader = LazyLoader('https://example.com/image.jpg');
final bytes = await loader.download();

if (bytes != null) {
  // Use image bytes
  final image = Image.memory(bytes);
}
```

## Documentation

For detailed documentation, API reference, and advanced usage examples, see:

- **[LazyImage Library Documentation](lib/lazyimage/README.md)** - Complete guide with examples

## Project Structure

```
macarons/
├── lib/
│   ├── lazyimage/           # LazyImage library
│   │   ├── cache/           # Cache implementation
│   │   │   ├── CacheManager.dart
│   │   │   ├── MemoryCache.dart
│   │   │   └── DiskCache.dart
│   │   ├── LazyImage.dart   # Main widget
│   │   ├── LazyLoader.dart  # Network loader
│   │   └── README.md        # Detailed docs
│   └── macarons.dart        # Plugin entry point
└── test/                     # Test suite
    └── lazyimage/           # LazyImage tests
```

## Requirements

- Flutter SDK: `>=3.3.0`
- Dart SDK: `^3.9.0`

## Platform Support

- ✅ Android
- ✅ iOS

## License

This plugin is part of the Algolia technical test implementation.
