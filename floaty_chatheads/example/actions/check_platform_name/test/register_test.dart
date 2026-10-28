import 'package:check_platform_name/check_platform_name.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers/mock_registry.dart';

void main() {
  test('can be registered', () {
    final registry = MockRegistry();
    when(
      () => registry.registerAction(
        any(),
        any(),
        shortHandIs: any(named: 'shortHandIs'),
      ),
    ).thenAnswer((_) {});

    register(registry);

    verify(
      () => registry.registerAction(
        any(that: equals('checkPlatformName')),
        any(that: equals(CheckPlatformName.new)),
        shortHandIs: any(named: 'shortHandIs', that: isNull),
      ),
    ).called(1);
  });
}
