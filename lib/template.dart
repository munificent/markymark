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
