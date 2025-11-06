library macarons;

export 'lazyimage/LazyImage.dart';

import 'macarons_platform_interface.dart';

class Macarons {
  Future<String?> getPlatformVersion() {
    return MacaronsPlatform.instance.getPlatformVersion();
  }
}
