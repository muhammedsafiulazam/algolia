import 'package:flutter_test/flutter_test.dart';
import 'package:macarons/macarons.dart';
import 'package:macarons/macarons_platform_interface.dart';
import 'package:macarons/macarons_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMacaronsPlatform
    with MockPlatformInterfaceMixin
    implements MacaronsPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final MacaronsPlatform initialPlatform = MacaronsPlatform.instance;

  test('$MethodChannelMacarons is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMacarons>());
  });

  test('getPlatformVersion', () async {
    Macarons macaronsPlugin = Macarons();
    MockMacaronsPlatform fakePlatform = MockMacaronsPlatform();
    MacaronsPlatform.instance = fakePlatform;

    expect(await macaronsPlugin.getPlatformVersion(), '42');
  });
}
