import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/chatheads_harness.dart';
import '../helpers/mock_floaty_chatheads_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  useSyntheticImageEncoder();

  group('FloatyChatheads', () {
    late MockFloatyChatheadsPlatform platform;

    setUp(() => platform = installMockChatheadsPlatform());

    setUpAll(registerChatheadsFallbacks);

    tearDown(FloatyChatheads.dispose);

    test('closeChatHead delegates to platform', () async {
      when(() => platform.closeChatHead()).thenAnswer((_) async {});
      await FloatyChatheads.closeChatHead();
      verify(() => platform.closeChatHead()).called(1);
    });

    test('isActive delegates to platform', () async {
      when(() => platform.isActive()).thenAnswer((_) async => false);
      expect(await FloatyChatheads.isActive(), isFalse);
    });

    test('addChatHead delegates to platform', () async {
      when(() => platform.addChatHead(any())).thenAnswer((_) async {});
      await FloatyChatheads.addChatHead(id: 'bubble1');
      verify(() => platform.addChatHead(any())).called(1);
    });

    test('removeChatHead delegates to platform', () async {
      when(() => platform.removeChatHead(any())).thenAnswer((_) async {});
      await FloatyChatheads.removeChatHead('bubble1');
      verify(() => platform.removeChatHead('bubble1')).called(1);
    });

    test('updateBadge delegates to platform', () async {
      when(() => platform.updateBadge(any())).thenAnswer((_) async {});
      await FloatyChatheads.updateBadge(5);
      verify(() => platform.updateBadge(5)).called(1);
    });

    test('expandChatHead delegates to platform', () async {
      when(() => platform.expandChatHead()).thenAnswer((_) async {});
      await FloatyChatheads.expandChatHead();
      verify(() => platform.expandChatHead()).called(1);
    });

    test('collapseChatHead delegates to platform', () async {
      when(() => platform.collapseChatHead()).thenAnswer((_) async {});
      await FloatyChatheads.collapseChatHead();
      verify(() => platform.collapseChatHead()).called(1);
    });
  });
}
