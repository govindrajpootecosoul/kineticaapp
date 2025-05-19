import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

bool checkPlatform() {
  if (kIsWeb) {
    print("Running on Web");
  }
  // else if (Platform.isAndroid) {
  //   print("Running on Android");
  // } else if (Platform.isIOS) {
  //   print("Running on iOS");
  // } else if (Platform.isWindows) {
  //   print("Running on Windows");
  // } else if (Platform.isMacOS) {
  //   print("Running on macOS");
  // } else if (Platform.isLinux) {
  //   print("Running on Linux");
  // }
  return kIsWeb;
}
