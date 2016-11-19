#!/usr/bin/env dart
import 'dart:io';
import 'package:markymark/args.dart';
import 'package:markymark/markymark.dart';
import 'package:path/path.dart' as p;

final parser = createArgParser();

main(List<String> args) {
  try {
    var result = parser.parse(args);

    if (result['help']) return printUsage(args);

    return createServer(result, callback).then((server) {
      print('Serving at http://${server.address.host}:${server.port}');
    });
  } catch (e) {
    if (e is FormatException) {
      return printUsage(args);
    }
  }
}

printUsage(List<String> args) {
  print("Usage: markymark [options...] [dir]");
  print("");
  print("Runs a simple static web server out of [dir]. If omitted, serves");
  print("the current directory. Viewing a Markdown file will render it to");
  print("HTML. Rendered HTML pages will auto-reload on changes.");
  print("");
  print("Options:");
  print("");
  print(parser.usage);

  if (!args.contains('--help') && !args.contains('-h')) exit(64);
}

callback(Directory dir, broadcast) {
  dir.watch(recursive: true).listen((e) {
    if (!markdownExtensions.contains(p.url.extension(e.path).toLowerCase()))
      return;

    print('The following file changed: ${e.path}');

    final relative = p.relative(e.path, from: dir.absolute.path);
    broadcast({'filename': dir.absolute.uri.resolve(relative).toString()});
  });

  print('Watching directory: ${dir.absolute.path}');
}
