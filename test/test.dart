import 'package:sandbox/sandbox.dart';

void main() {
  //var appPath = "/home/andrew/.pub-cache/hosted/pub.dartlang.org/unsafe_extension-0.0.22";
  var appPath = "c:/users/user/appdata/roaming/pub/cache/hosted/pub.dartlang.org/unsafe_extension-0.0.22";
  var sandbox = new Sandbox(appPath);
  var result = sandbox.runSync("bin/setup.dart", [], workingDirectory: appPath);
  if (result.stdout is List) {
    print(new String.fromCharCodes(result.stdout));
  } else if (result.stdout is String) {
    print(result.stdout);
  }

  if (result.stderr is List) {
    print(new String.fromCharCodes(result.stderr));
  } else if (result.stderr is String) {
    print(result.stderr);
  }

  print(result.exitCode);
}