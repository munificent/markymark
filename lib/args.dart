import 'package:args/args.dart';

ArgParser createArgParser() {
  return new ArgParser()
    ..addFlag('help', abbr: 'h', help: 'Print this help information.', negatable: false)
    ..addFlag('list-dirs', help: 'List directory structure if no index file is found.', defaultsTo: true)
    ..addFlag('watch', abbr: 'w', help: 'Listen for file changes.', defaultsTo: true)
    ..addOption('host', help: 'The hostname for markymark to serve at.', defaultsTo: 'localhost')
    ..addOption('port', abbr: 'p', help: 'The port to listen on. Default: 8080', defaultsTo: '8080');
}
