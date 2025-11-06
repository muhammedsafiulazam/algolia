import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:macarons/lazyimage/cache/CacheManager.dart';

/// A widget that lazily loads and displays images from a URL.
///
/// The image is downloaded asynchronously when the widget is built,
/// and the download can be cancelled if the widget is disposed before
/// the download completes.
///
/// Example:
/// ```dart
/// LazyImage(
///   url: 'https://example.com/image.jpg',
///   width: 200,
///   height: 200,
///   placeholder: CircularProgressIndicator(),
///   errorWidget: Icon(Icons.error),
/// )
/// ```
class LazyImage extends StatefulWidget {
  /// The URL of the image to load.
  final String url;

  /// The width of the image.
  final double? width;

  /// The height of the image.
  final double? height;

  /// Widget to display while the image is loading.
  final Widget? placeholder;

  /// Widget to display if the image fails to load.
  final Widget? errorWidget;

  /// How to inscribe the image into the space allocated during layout.
  final BoxFit fit;

  /// The alignment of the image within its bounds.
  final AlignmentGeometry alignment;

  /// How to repeat the image if it doesn't fill its bounds.
  final ImageRepeat repeat;

  /// The color to blend with the image.
  final Color? color;

  /// The color filter to apply to the image.
  final ColorFilter? colorFilter;

  /// The semantic label for the image.
  final String? semanticLabel;

  /// Whether to exclude this image from semantics.
  final bool excludeFromSemantics;

  /// Whether to enable disk caching.
  final bool enableDiskCache;

  const LazyImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.color,
    this.colorFilter,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.enableDiskCache = true,
  });

  @override
  State<LazyImage> createState() => _LazyImageState();
}

class _LazyImageState extends State<LazyImage> {
  Uint8List? _mImageBytes;
  bool _isLoading = true;
  bool _hasError = false;
  final _mCacheManager = CacheManager();

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(LazyImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _mCacheManager.cancelLoading(oldWidget.url);
      _mImageBytes = null;
      _isLoading = true;
      _hasError = false;
      _loadImage();
    }
  }

  @override
  void dispose() {
    _mCacheManager.cancelLoading(widget.url);
    super.dispose();
  }

  Future<void> _loadImage() async {
    try {
      final bytes = await _mCacheManager.getImage(widget.url);
      if (mounted) {
        setState(() {
          _mImageBytes = bytes;
          _isLoading = false;
          _hasError = bytes == null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: widget.placeholder ?? const Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasError || _mImageBytes == null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: widget.errorWidget ?? const Icon(Icons.error),
      );
    }

    final image = Image.memory(
      _mImageBytes!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      alignment: widget.alignment,
      repeat: widget.repeat,
      color: widget.color,
      semanticLabel: widget.semanticLabel,
      excludeFromSemantics: widget.excludeFromSemantics,
    );

    if (widget.colorFilter != null) {
      return ColorFiltered(
        colorFilter: widget.colorFilter!,
        child: image,
      );
    }

    return image;
  }
}
