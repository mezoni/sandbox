import "dart:convert";
import "dart:io";

import 'package:binary_generator/constants_generator/constants_generator.dart';
import 'package:binary_generator/library_generator/library_generator.dart';
import 'package:libc/headers.dart';
import 'package:libpq93_bindings/headers.dart';

void main() {
  var libraries = <String>["Libpq93"];
  for (var library in libraries) {
    _generateLibrary(library);
  }

  var defenitions = <String>["Libpq93"];
  for (var defenition in defenitions) {
    _generateConstants(defenition);
  }
}

void _generateConstants(String libraryName) {
  var lowercaseName = libraryName.toLowerCase();
  var header = "$lowercaseName.def.h";
  var headers = <String, String>{};
  var filename = "$lowercaseName.def";
  headers.addAll(LIBC_HEADERS);
  headers.addAll(LIBPQ93_HEADERS);
  var directives = <String>["part of ${_PACKAGE_NAME}"];
  var links = <String>[header];
  var options = new ConstantsGeneratorOptions(
      constants: null,
      directives: directives,
      header: header,
      headers: headers,
      links: links,
      name: "${libraryName}Def");
  var generator = new ConstantsGenerator();
  var lines = generator.generate(options);
  var path = "lib/src/$_PACKAGE_NAME/${filename}.dart";
  var file = new File(path);
  file.createSync(recursive: true);
  file.writeAsStringSync(lines.join("\n"));
}

void _generateLibrary(String libraryName) {
  var lowercaseName = libraryName.toLowerCase();
  var header = "$lowercaseName.lib.h";
  var headers = <String, String>{};
  var filename = "$lowercaseName.lib";
  headers.addAll(LIBC_HEADERS);
  headers.addAll(LIBPQ93_HEADERS);
  var directives = <String>["part of ${_PACKAGE_NAME}"];
  var links = <String>[header];
  var options = new LibraryGeneratorOptions(
      constants: const [],
      directives: directives,
      header: header,
      headers: headers,
      links: links,
      name: "${libraryName}Lib");
  var generator = new LibraryGenerator();
  var lines = generator.generate(options);
  var path = "lib/src/$_PACKAGE_NAME/${filename}.dart";
  var file = new File(path);
  file.createSync(recursive: true);
  file.writeAsStringSync(lines.join("\n"));
}

const String _PACKAGE_NAME = "libpq93_bindings";

void _addImport(String url, List directives) {
  directives.add("import \"$url\"");
}