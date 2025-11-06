import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

/// Handles asynchronous image downloading with cancellation support using isolates.
/// Downloads run in isolates to keep the main thread completely free.
class LazyLoader {
  final String url;
  Isolate? _isolate;
  ReceivePort? _receivePort;
  SendPort? _sendPort;
  bool _cancelled = false;
  Completer<Uint8List?>? _completer;

  LazyLoader(this.url);

  /// Downloads the image from the URL using an isolate.
  /// Returns the image bytes if successful, null if cancelled or failed.
  Future<Uint8List?> download() async {
    if (_cancelled) {
      return null;
    }

    _completer = Completer<Uint8List?>();
    _receivePort = ReceivePort();

    try {
      // Use Isolate.spawn (not Isolate.run) because we need:
      // 1. Cancellation support - can send cancel commands via SendPort
      // 2. Bidirectional communication - need to receive progress/results
      // 3. Long-running operations - downloads can take time, need to check cancellation
      // Isolate.run is simpler but doesn't support cancellation or ongoing communication
      _isolate = await Isolate.spawn(
        _downloadIsolate,
        _IsolateMessage(
          url: url,
          sendPort: _receivePort!.sendPort,
        ),
      );

      // Listen for messages from isolate
      StreamSubscription? subscription;
      subscription = _receivePort!.listen((message) {
        if (message is _IsolateResponse) {
          if (!_cancelled) {
            _completer?.complete(message.bytes);
          }
          subscription?.cancel();
          _cleanup();
        } else if (message is SendPort) {
          _sendPort = message;
        }
      });

      // Set up timeout for download
      Timer? timeoutTimer;
      timeoutTimer = Timer(const Duration(seconds: 30), () {
        if (_completer != null && !_completer!.isCompleted) {
          cancel();
        }
      });

      final result = await _completer!.future;
      timeoutTimer?.cancel();
      return result;
    } catch (e) {
      _cleanup();
      if (!_completer!.isCompleted) {
        _completer?.complete(null);
      }
      return null;
    }
  }

  void _cleanup() {
    if (_sendPort != null) {
      try {
        _sendPort!.send(_IsolateCommand.cancel);
      } catch (e) {
        // Ignore errors when sending cancel
      }
    }
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _receivePort?.close();
    _receivePort = null;
    _sendPort = null;
  }

  /// Cancels the download request for this URL.
  /// This will stop the download immediately and clean up resources.
  void cancel() {
    if (_cancelled) {
      return; // Already cancelled
    }
    
    _cancelled = true;
    _cleanup();
    
    // Complete the completer if it exists and isn't already completed
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(null);
    }
  }

  /// Isolate entry point for downloading images.
  static void _downloadIsolate(_IsolateMessage message) async {
    final receivePort = ReceivePort();
    message.sendPort.send(receivePort.sendPort);

    bool cancelled = false;
    HttpClient? client;
    
    // Listen for cancellation commands
    final subscription = receivePort.listen((command) {
      if (command == _IsolateCommand.cancel) {
        cancelled = true;
        // Close the HTTP client immediately when cancelled
        client?.close(force: true);
        receivePort.close();
      }
    });

    try {
      client = HttpClient();
      final uri = Uri.parse(message.url);
      
      // Check cancellation before making request
      if (cancelled) {
        message.sendPort.send(_IsolateResponse(bytes: null));
        subscription.cancel();
        receivePort.close();
        return;
      }
      
      final request = await client.getUrl(uri);
      final response = await request.close();

      // Check cancellation after getting response
      if (cancelled) {
        message.sendPort.send(_IsolateResponse(bytes: null));
        subscription.cancel();
        receivePort.close();
        return;
      }

      if (response.statusCode == HttpStatus.ok) {
        final bytes = <int>[];
        
        // Read response chunks with cancellation checks
        await for (final chunk in response) {
          if (cancelled) {
            // Stop reading and close connection
            client?.close(force: true);
            message.sendPort.send(_IsolateResponse(bytes: null));
            subscription.cancel();
            receivePort.close();
            return;
          }
          bytes.addAll(chunk);
        }

        // Final cancellation check before sending result
        if (!cancelled) {
          message.sendPort.send(_IsolateResponse(bytes: Uint8List.fromList(bytes)));
        } else {
          message.sendPort.send(_IsolateResponse(bytes: null));
        }
      } else {
        message.sendPort.send(_IsolateResponse(bytes: null));
      }
    } catch (e) {
      // Only send error response if not cancelled
      if (!cancelled) {
        try {
          message.sendPort.send(_IsolateResponse(bytes: null));
        } catch (e) {
          // Port might be closed if cancelled
        }
      }
    } finally {
      // Ensure cleanup
      client?.close(force: true);
      subscription.cancel();
      receivePort.close();
    }
  }
}

/// Message sent to isolate.
class _IsolateMessage {
  final String url;
  final SendPort sendPort;

  _IsolateMessage({
    required this.url,
    required this.sendPort,
  });
}

/// Response from isolate.
class _IsolateResponse {
  final Uint8List? bytes;

  _IsolateResponse({required this.bytes});
}

/// Commands for isolate communication.
enum _IsolateCommand {
  cancel,
}
