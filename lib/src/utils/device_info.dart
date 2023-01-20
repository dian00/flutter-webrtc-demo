import 'dart:io';

class DeviceInfo {
  static String get label {
    return 'Flutter ' + Platform.operatingSystem + '(' + Platform.localHostname + ")";
  }

  static String get userAgent {
    // ttgo version
    return 'ttgo-user/' + Platform.operatingSystem + '-plugin 0.0.1';
  }
}
