import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'macarons_method_channel.dart';

abstract class MacaronsPlatform extends PlatformInterface {
  /// Constructs a MacaronsPlatform.
  MacaronsPlatform() : super(token: _token);

  static final Object _token = Object();

  static MacaronsPlatform _instance = MethodChannelMacarons();

  /// The default instance of [MacaronsPlatform] to use.
  ///
  /// Defaults to [MethodChannelMacarons].
  static MacaronsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MacaronsPlatform] when
  /// they register themselves.
  static set instance(MacaronsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
