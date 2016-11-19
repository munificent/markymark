I write a lot of Markdown. Like, a *lot* of Markdown. I even wrote a
[whole book][gpp] in it once. Hell, I'm writing some right this very second.

[gpp]: http://gameprogrammingpatterns.com/
When I'm not writing it inside a comment box on Reddit, I'm probably writing
it on my laptop. I've tried a few different "Markdown editors" as well as
Atom's Markdown preview but, well, I like my text editor already. In fact, I
*don't* want to see the rendered Markdown as I type. I like it to be an
explicit (but fast) mode switch because it helps me mentally switch from
writing to reading. That way I read what I *wrote* and not what I *think* I
wrote.

Markymark is a simple solution to that. It's a tiny command line Dart app. It
spins up a little static web server in a directory. Navigate to a Markdown file
and it renders it to HTML. Refresh your browser and it re-renders.

It's also got a little CSS baked that is, to my eye at least, nice looking.

## Installation

Assuming you've already got [Dart][] installed and [pub's bin directory on your
PATH][pub], it's just:

[dart]: https://www.dartlang.org/
[pub]: https://www.dartlang.org/tools/pub/cmd/pub-global

```sh
$ pub global activate markymark
```

## Usage

From any directory, run:

```sh
$ markymark
```

You can also pass an explicit directory path to it:

```sh
$ markymark /some/groovy/directory/
```

Point your browser at `localhost:8080` and you're good to go.

Ctrl-C to kill the server.
