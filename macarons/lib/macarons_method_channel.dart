import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'macarons_platform_interface.dart';

/// An implementation of [MacaronsPlatform] that uses method channels.
class MethodChannelMacarons extends MacaronsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('macarons');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
