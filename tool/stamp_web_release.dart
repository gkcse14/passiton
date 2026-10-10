import 'dart:io';

/// Give each deployment unique loader and app URLs, independently of CDN caches.
({String index, String bootstrap}) stampRelease(
  String index,
  String bootstrap,
  String revision,
) {
  if (!RegExp(r'^[a-f0-9]{7,40}$').hasMatch(revision)) {
    throw ArgumentError('A Git revision is required.');
  }
  const loader = 'src="flutter_bootstrap.js"';
  final entrypoint = RegExp(r'"mainJsPath"\s*:\s*"main.dart.js"');
  if (!index.contains(loader) || !entrypoint.hasMatch(bootstrap)) {
    throw StateError(
      'Flutter output changed; refusing an unversioned release.',
    );
  }
  return (
    index: index.replaceFirst(
      loader,
      'src="flutter_bootstrap.js?release=$revision"',
    ),
    bootstrap: bootstrap.replaceAll(
      entrypoint,
      '"mainJsPath":"main.dart.js?release=$revision"',
    ),
  );
}

void main(List<String> arguments) {
  if (arguments.length != 1) {
    throw ArgumentError('Usage: dart tool/stamp_web_release.dart <git-sha>');
  }
  final index = File('build/web/index.html');
  final bootstrap = File('build/web/flutter_bootstrap.js');
  final result = stampRelease(
    index.readAsStringSync(),
    bootstrap.readAsStringSync(),
    arguments.single,
  );
  index.writeAsStringSync(result.index);
  bootstrap.writeAsStringSync(result.bootstrap);
  stdout.writeln('Versioned web release ${arguments.single}');
}
