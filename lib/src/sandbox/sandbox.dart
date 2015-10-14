part of sandbox;

class Sandbox {
  final String applicationPath;

  String environmentPath;

  String sdkPath;

  Sandbox(this.applicationPath) {
    if (applicationPath == null) {
      throw new ArgumentError.notNull("applicationPath");
    }

    _createTemporaryDirectory();
    _createPubspecFile();
    _createLinkToLibDirectory();
    _findDartSdk();
    _getDependencies();
  }

  void destroy() {
    _deleteTemporaryDirectory();
  }

  void _createLinkToLibDirectory() {
    var path = lib_path.join(applicationPath, "lib");
    var directory = new Directory(path);
    if (directory.existsSync()) {
      path = lib_path.join(environmentPath, "lib");
      var link = new Link(path);
      link.createSync(directory.absolute.path);
    }
  }

  void _createPubspecFile() {
    var path = lib_path.join(applicationPath, "pubspec.yaml");
    var file = new File(path);
    if (!file.existsSync()) {
      throw new FileSystemException("File not found", path);
    }

    var contents = file.readAsStringSync();
    path = lib_path.join(environmentPath, "pubspec.yaml");
    file = new File(path);
    file.writeAsStringSync(contents);
  }

  void _createTemporaryDirectory() {
    environmentPath = Directory.systemTemp.createTempSync().path;
  }

  void _deleteTemporaryDirectory() {
    var directory = new Directory(environmentPath);
    for (var file in directory.listSync(recursive: true, followLinks: false)) {
      if (file is Link) {
        try {
          file.deleteSync();
        } catch (s) {}
      }
    }

    directory.deleteSync(recursive: true);
  }

  void _findDartSdk() {
    var executable = Platform.executable;
    var s = Platform.pathSeparator;
    if (!executable.contains(s)) {
      if (Platform.isLinux) {
        executable = new Link("/proc/$pid/exe").resolveSymbolicLinksSync();
      }
    }

    if (Platform.isWindows) {
      if (!executable.toLowerCase().endsWith(".exe")) {
        executable = "$executable.exe";
      }
    }

    var file = new File(executable);
    if (file.existsSync()) {
      var parent = file.absolute.parent;
      parent = parent.parent;
      var path = parent.path;
      var dartAPI = "$path${s}include${s}dart_api.h";
      if (new File(dartAPI).existsSync()) {
        sdkPath = path;
        return;
      }
    }

    if (sdkPath == null) {
      throw new StateError("Dart SDK not found");
      return;
    }
  }

  void _getDependencies() {
    var result = _pubGet();
    if (result.exitCode != 0) {
      stdout.writeAll(result.stdout);
      stderr.writeAll(result.stderr);
      throw new StateError("Unable to get dependencies");
    }
  }

  ProcessResult _pubGet() {
    var arguments = <String>["get"];
    return _runPub(arguments, workingDirectory: environmentPath);
  }

  ProcessResult _runPub(List<String> arguments, {String workingDirectory}) {
    var path = lib_path.join(sdkPath, "bin", "pub");
    return Process.runSync(path, arguments,
        runInShell: true, workingDirectory: workingDirectory);
  }
}
