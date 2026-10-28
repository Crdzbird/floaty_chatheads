import 'package:check_platform_name/check_platform_name.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttium/fluttium.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/action_for_platform.dart';
import '../helpers/mock_semantics_node.dart';
import '../helpers/mock_tester.dart';

void main() {
  group(CheckPlatformName, () {
    late Tester tester;
    late SemanticsNode node;

    setUp(() {
      tester = MockTester();
      node = MockSemanticsNode();

      when(() => tester.find(any())).thenAnswer((_) async => node);
    });

    test('executes returns true if node was found', () async {
      const action = CheckPlatformName();

      expect(await action.execute(tester), isTrue);
    });

    test('executes returns false if node was not found', () async {
      when(() => tester.find(any())).thenAnswer((_) async => null);

      const action = CheckPlatformName();

      expect(await action.execute(tester), isFalse);
    });

    test('show correct description for every platform', () {
      const platforms = ['Android', 'iOS', 'Web', 'Linux', 'MacOS', 'Windows'];

      for (final platform in platforms) {
        expect(
          actionForPlatform(platform).description(),
          equals('Check platform name: "$platform"'),
        );
      }
    });

    test('throws UnsupportedError on unknown platform', () {
      final action = actionForPlatform('Fuchsia');

      expect(action.description, throwsUnsupportedError);
    });
  });
}
