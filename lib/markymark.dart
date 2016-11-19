import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';
import 'package:markdown/markdown.dart';
import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'reload.dart';
import 'template.dart';

final List clients = [];
final Set<String> markdownExtensions = [".md", ".mdown", ".markdown"].toSet();

createServer(ArgResults result, callback(Directory dir, broadcast)) {
  final dir = new Directory(result.rest.isNotEmpty ? result.rest.first : '.');
  final host = result['host'];
  final port = int.parse(result['port']);

  final handler = new shelf.Cascade()
      .add(wsHandler())
      .add(markdownHandler(dir, result['watch']))
      .add(createStaticHandler(dir.path,
          defaultDocument: 'index.html', listDirectories: result['list-dirs']))
      .handler;

  return io.serve(handler, host, port).then((server) {
    if (result['watch']) {
      callback(dir, broadcast);
    }

    return server;
  });
}

broadcast(message) {
  for (var client in clients) {
    try {
      client.sink.add(JSON.encode(message));
    } catch (e) {
      stderr.writeln('Could not broadcast $message to $client. :(');
      stderr.writeln(e);
    }
  }
}

wsHandler() {
  return webSocketHandler(clients.add);
}

markdownHandler(Directory dir, bool watch) {
  return (shelf.Request request) {
    var extension = p.url.extension(request.url.path).toLowerCase();
    if (!markdownExtensions.contains(extension)) {
      // Let the static handler handle it.
      return new shelf.Response.notFound("Not a markdown file.");
    }

    var file = new File.fromUri(dir.uri.resolveUri(request.url));
    var markdown = file.readAsStringSync();
    var body = markdownToHtml(markdown);

    if (watch)
      body += livereload.replaceAll(
          "{{filename}}", file.absolute.uri.toString().replaceAll("'", "\\'"));

    var html = template
        .replaceAll("{{title}}", p.basenameWithoutExtension(file.path))
        .replaceAll("{{body}}", body);

    var headers = {HttpHeaders.CONTENT_TYPE: "text/html"};
    return new shelf.Response.ok(html, headers: headers);
  };
}
