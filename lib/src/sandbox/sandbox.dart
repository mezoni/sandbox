part of sandbox;

class Sandbox {
  final String applicationPath;

  Sandbox(this.applicationPath) {
    if (applicationPath == null) {
      throw new ArgumentError.notNull(applicationPath);
    }
  }

  ProcessResult runSync(String executable, List<String> arguments,
      {String workingDirectory,
      Map<String, String> environment,
      bool includeParentEnvironment: true,
      bool runInShell: false,
      Encoding stdoutEncoding: SYSTEM_ENCODING,
      Encoding stderrEncoding: SYSTEM_ENCODING}) {
    if (executable == null) {
      throw new ArgumentError.notNull("executable");
    }

    if (arguments == null) {
      throw new ArgumentError.notNull("arguments");
    }

    if (!lib_path.isRelative(executable)) {
      throw new ArgumentError.value(
          executable, executable, "Not a relative path");
    }

    ProcessResult result;
    var env = new _Environment(applicationPath);
    try {
      var dart = lib_path.join(env.dartSdk, "bin", "dart");
      var args = <String>[];
      var path = lib_path.join(env.environmentPath, "packages");
      args.add("--package-root=$path");
      path = lib_path.join(applicationPath, executable);
      args.add(path);
      args.addAll(arguments);
      result = Process.runSync(dart, args,
          environment: environment,
          includeParentEnvironment: includeParentEnvironment,
          runInShell: runInShell,
          stderrEncoding: stderrEncoding,
          stdoutEncoding: stdoutEncoding,
          workingDirectory: workingDirectory);
    } finally {
      env.destroy();
    }

    return result;
  }

  String _readPubspec() {
    var path = lib_path.join(applicationPath, "pubspec.yaml");
    var file = new File(path);
    if (!file.existsSync()) {
      throw new FileSystemException("File not found: $path");
    }

    return file.readAsStringSync();
  }
}
