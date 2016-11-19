import 'dart:io';

import 'package:markdown/markdown.dart';
import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';

const template = """
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-type" content="text/html;charset=UTF-8" />
<title>{{title}}</title>
<style>
body {
  max-width: 672px;
  margin: 48px auto;

  font: normal 16px/24px 'PT Serif', Georgia, serif;

  background: hsl(40, 40%, 97%);
  color: hsl(200, 20%, 20%);
}

code, pre {
  border-radius: 3px;
  background: #fff;
  color: hsl(200, 20%, 40%);
}

pre {
  padding: 12px;
  margin: -12px;

  font-size: 14px;
  line-height: 20px;
}

code {
  padding: 1px 4px;
}

h1 {
  margin: 24px 0;
  font: normal 48px/48px 'PT Sans', Helvetica, sans-serif;
}

h2 {
  margin: 48px 0 24px 0;
  font: bold 30px/48px 'PT Sans', Helvetica, sans-serif;
}

h3 {
  margin: 48px 0 24px 0;
  font: italic 24px/24px 'PT Sans', Helvetica, sans-serif;
}

p {
  margin: 24px 0;
}
</style>
</head>
<body>
<h1>{{title}}</h1>
{{body}}
</body>
</html>
""";

final Set<String> markdownExtensions = [".md", ".mdown", ".markdown"].toSet();

String rootDirectory = ".";

void main(List<String> args) {
  if (args.length == 1) {
    rootDirectory = args[0];
  } else if (args.length > 1) {
    print("Usage: markymark [dir]");
    print("");
    print("  Runs a simple static web server out of [dir]. If omitted, serves");
    print("  the current directory. Viewing a Markdown file will render it to");
    print("  HTML.");
    print("");
    exit(64);
  }

  var handler = new shelf.Cascade()
      .add(markdownHandler)
      .add(createStaticHandler(rootDirectory,
          defaultDocument: 'index.html', listDirectories: true))
      .handler;

  io.serve(handler, 'localhost', 8080).then((server) {
    print('Serving at http://${server.address.host}:${server.port}');
  });
}

shelf.Response markdownHandler(shelf.Request request) {
  var extension = p.url.extension(request.url.path).toLowerCase();
  if (!markdownExtensions.contains(extension)) {
    // Let the static handler handle it.
    return new shelf.Response.notFound("Not a markdown file.");
  }

  var parts = [rootDirectory]..addAll(request.url.pathSegments);
  var localPath = p.joinAll(parts);

  var markdown = new File(localPath).readAsStringSync();
  var body = markdownToHtml(markdown);

  var html = template
      .replaceAll("{{title}}", p.basenameWithoutExtension(localPath))
      .replaceAll("{{body}}", body);

  var headers = {HttpHeaders.CONTENT_TYPE: "text/html"};
  return new shelf.Response.ok(html, headers: headers);
}
