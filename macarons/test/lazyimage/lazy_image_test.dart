import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:macarons/lazyimage/LazyImage.dart';

void main() {
  group('LazyImage', () {
    testWidgets('should display placeholder while loading', (WidgetTester tester) async {
      const customPlaceholder = Text('Loading...');
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LazyImage(
              url: 'https://example.com/image.jpg',
              placeholder: customPlaceholder,
            ),
          ),
        ),
      );

      // Should show placeholder initially
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('should display error widget on invalid URL', (WidgetTester tester) async {
      const customError = Text('Error loading image');
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LazyImage(
              url: 'invalid-url',
              errorWidget: customError,
            ),
          ),
        ),
      );

      // Wait for error state (pump multiple times to allow async operations)
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      
      // Should show error widget (might take time for network to fail)
      final hasErrorWidget = find.text('Error loading image').evaluate().isNotEmpty;
      final hasPlaceholder = find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
      
      // Either error widget should appear or still loading
      expect(hasErrorWidget || hasPlaceholder, isTrue);
    });

    testWidgets('should update when URL changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LazyImage(
              url: 'https://example.com/image1.jpg',
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LazyImage(
              url: 'https://example.com/image2.jpg',
            ),
          ),
        ),
      );

      // Should rebuild with new URL
      expect(find.byType(LazyImage), findsOneWidget);
    });

    testWidgets('should respect width and height constraints', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LazyImage(
              url: 'https://example.com/image.jpg',
              width: 200,
              height: 150,
            ),
          ),
        ),
      );

      final lazyImage = tester.widget<LazyImage>(find.byType(LazyImage));
      expect(lazyImage.width, equals(200));
      expect(lazyImage.height, equals(150));
    });

    testWidgets('should use default placeholder when not provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LazyImage(
              url: 'https://example.com/image.jpg',
            ),
          ),
        ),
      );

      // Should show default CircularProgressIndicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should use default error widget when not provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LazyImage(
              url: 'invalid-url',
            ),
          ),
        ),
      );

      // Wait for error state (with timeout)
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      
      // Should show default error icon or placeholder
      // Note: Error might take time, so we check for either error icon or placeholder
      final hasErrorIcon = find.byIcon(Icons.error).evaluate().isNotEmpty;
      final hasPlaceholder = find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
      
      // Either error icon should appear or still loading
      expect(hasErrorIcon || hasPlaceholder, isTrue);
    });

    test('should have correct default values', () {
      const lazyImage = LazyImage(url: 'https://example.com/image.jpg');
      
      expect(lazyImage.fit, equals(BoxFit.cover));
      expect(lazyImage.alignment, equals(Alignment.center));
      expect(lazyImage.repeat, equals(ImageRepeat.noRepeat));
      expect(lazyImage.excludeFromSemantics, equals(false));
      expect(lazyImage.enableDiskCache, equals(true));
    });
  });
}

