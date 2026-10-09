import 'package:flutter_test/flutter_test.dart';
import '../tool/stamp_web_release.dart';

void main() {
  test('release stamps both URLs and preserves the repository base path', () {
    final result = stampRelease(
      '<base href="/passiton/"><script src="flutter_bootstrap.js" async></script>',
      '_flutter.buildConfig = {"builds":[{"mainJsPath":"main.dart.js"}]};',
      'ba9da88',
    );
    expect(result.index, contains('/passiton/'));
    expect(result.index, contains('flutter_bootstrap.js?release=ba9da88'));
    expect(result.bootstrap, contains('main.dart.js?release=ba9da88'));
  });
  test(
    'unexpected Flutter output fails instead of silently skipping cache busting',
    () {
      expect(
        () => stampRelease('changed', 'changed', 'ba9da88'),
        throwsStateError,
      );
      expect(() => stampRelease('', '', '../bad'), throwsArgumentError);
    },
  );
}
