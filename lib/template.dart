import 'dart:io';

class Template {
  String value;
  Template(this.value);
  Template.fromFile(String path) : value = File(path).readAsStringSync();
  Template.fromCurrentPath(String path) : value = File('${Directory.current.path}$path').readAsStringSync();
  static Future<Template> fromFileAsync(String path) async => Template(await File(path).readAsString());
  static Future<Template> fromCurrentPathAsync(String path) async => Template(await File('${Directory.current.path}$path').readAsString());

  String fill (Map<String, dynamic> data) {
    String newValue = value;
    data.forEach((key, value) {
      newValue = newValue.replaceAll(RegExp('<\\s*var\\s+$key\\s*\\/?\\s*>'), value is Iterable ? value.join('\n') : value is Template ? value.value : value.toString());
    });
    return newValue.replaceAll(RegExp(r'<\s*func\s+.+?\s*/?\s*>.+?<\s*/func\s*>\s*', dotAll: true), '');
  }
  String blank () => fill({});

  Template grab (String func) {
    final match = RegExp('<\\s*func\\s+.+?\\s*>\\s*(.+?)\\s*<\\s*\\/func\\s*>\\s*', dotAll: true).firstMatch(value);
    if (match == null) throw FuncNotFoundError('func $func not found');
    return Template(match.group(1)!);
  }

  @override
  String toString () => value;
}

extension StringToTemplate on String {
  Template asTemplate() => Template(this);
}

class FuncNotFoundError implements Exception {
  String cause;
  FuncNotFoundError(this.cause);
}