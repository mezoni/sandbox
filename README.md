# sandbox

Sandbox creates an environment that allows to execute the Dart script anywhere (even in the pub cache).

Version: 0.0.2

The goal of the Dash effort is ultimately to replace JavaScript as the lingua franca of web development on the open web platform.

### Example:

```dart
import 'dart:io';

import 'package:path/path.dart' as lib_path;
import 'package:pub_cache/pub_cache.dart';
import 'package:sandbox/sandbox.dart';

void main() {
  var pubCache = new PubCache();
  var packageRef = pubCache.getLatestVersion("sandbox");
  var package = packageRef.resolve();
  var path = package.location.path;
  var name = "${package.name}-${package.version}";
  print("Create sandbox for '$name'");
  var sandbox = new Sandbox(path);
  print("Sandbox created at ${sandbox.environmentPath}");
  var executable = "example/hello.dart";
  var arguments = <String>[];
  print("Run script '$name/$executable' in sandbox");
  print("================");
  ProcessResult result;
  try {
    var dart = lib_path.join(sandbox.sdkPath, "bin", "dart");
    var args = <String>[];
    var path = lib_path.join(sandbox.environmentPath, "packages");
    args.add("--package-root=$path");
    path = lib_path.join(sandbox.applicationPath, executable);
    args.add(path);
    args.addAll(arguments);
    result = Process.runSync(dart, args,
        runInShell: true, workingDirectory: sandbox.applicationPath);
    displayOutput(result);
  } finally {
    sandbox.destroy();
    print("================");
    print("Script '$executable' terminated");
  }
}

void displayOutput(ProcessResult result) {
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
}
```

Output

```
Create sandbox for 'sandbox-0.0.1'
Sandbox created at C:\Users\user\AppData\Local\Temp\cd4d3cec-729c-11e5-adeb-50e54991a89c
Run script 'sandbox-0.0.1/example/hello.dart' in sandbox
================
Hello from C:\Users\user\AppData\Roaming\Pub\Cache\hosted\pub.dartlang.org\sandbox-0.0.1


================
Script 'example/hello.dart' terminated
```
