import 'dart:io';

import 'package:markdown/markdown.dart';
import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';
import 'package:yaml/yaml.dart';

const template = """
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-type" content="text/html;charset=UTF-8" />
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Source+Code+Pro&family=Source+Serif+Pro:ital,wght@0,300;0,400;0,600;1,400&display=swap" rel="stylesheet"> 
<style>
html {
  background: hsl(0, 0%, 90%);
}

body {
  max-width: 720px;
  margin: 0 auto;
  padding: 48px;

  font: normal 17px/24px 'Source Serif Pro', Georgia, serif;

  background: hsl(0, 0%, 100%);
  color: hsl(0, 0%, 20%);
}

code, pre {
  font-family: 'Source Code Pro', monospace;
  border-radius: 3px;
  background: hsl(0, 0%, 97%);
  color: hsl(0, 0%, 40%);
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

pre code {
  padding: 0;
}

h1 {
  margin: 24px 0;
  font: normal 48px/48px 'Source Serif Pro', Georgia, serif;
}

h2 {
  margin: 48px 0 24px 0;
  font: bold 30px/48px 'Source Serif Pro', Georgia, serif;
}

h3 {
  margin: 48px 0 24px 0;
  font: italic 24px/24px 'Source Serif Pro', Georgia, serif;
}

p {
  margin: 24px 0;
}

li > p:first-child {
  margin-top: 0;
}

li > p:last-child {
  margin-bottom: 0;
}

li + li {
  margin-top: 12px;
}
</style>
<title>{{title}}</title>
</head>
<body>
{{header}}{{body}}
</body>
</html>
""";

final titlePattern = new RegExp("^# (.*)");
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
      .add(createStaticHandler(rootDirectory, defaultDocument: 'index.html', listDirectories: true))
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

  // try to process any yaml front matter
  final sections = markdown.split("---");
  var frontMatter;
  if (sections.length == 3) {
    frontMatter = loadYaml(sections[1]);
    markdown = sections[2];
  }

  var body = markdownToHtml(markdown);

  var header = "";
  var title = p.basenameWithoutExtension(localPath);
  var match = titlePattern.firstMatch(markdown);
  if (match != null) {
    title = match[1]!;
  } else if (frontMatter["title"] != null) {
    title = frontMatter["title"];
  } else {
    header = "<h1>$title</h2>\n";
  }

  var html = template.replaceAll("{{title}}", title).replaceAll("{{header}}", header).replaceAll("{{body}}", body);

  var headers = {HttpHeaders.contentTypeHeader: "text/html"};
  return new shelf.Response.ok(html, headers: headers);
}
