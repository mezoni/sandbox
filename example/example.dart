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
