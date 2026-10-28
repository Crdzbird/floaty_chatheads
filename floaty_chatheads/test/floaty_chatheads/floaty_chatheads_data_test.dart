import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/chatheads_harness.dart';
import '../helpers/messenger_delivery.dart';
import '../helpers/mock_floaty_chatheads_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  useSyntheticImageEncoder();

  group('FloatyChatheads', () {
    late MockFloatyChatheadsPlatform platform;

    setUp(() => platform = installMockChatheadsPlatform());

    setUpAll(registerChatheadsFallbacks);

    tearDown(FloatyChatheads.dispose);

    test('shareData sends via BasicMessageChannel', () async {
      await FloatyChatheads.shareData('test-data');
    });

    test('onData returns broadcast stream', () {
      FloatyChatheads.onData
        ..listen((_) {})
        ..listen((_) {});
    });

    test('onData message handler forwards data', () async {
      final values = <Object?>[];
      FloatyChatheads.onData.listen(values.add);

      await deliverMessengerMessage('overlay-msg');
      expect(values, contains('overlay-msg'));
    });

    test('updateChatHeadIcon delegates to platform', () async {
      when(
        () => platform.updateChatHeadIcon(any(), any(), any(), any()),
      ).thenAnswer((_) async {});
      final bytes = Uint8List.fromList([1, 2, 3, 4]);
      await FloatyChatheads.updateChatHeadIcon(
        rgbaBytes: bytes,
        width: 1,
        height: 1,
        id: 'bubble1',
      );
      verify(
        () => platform.updateChatHeadIcon('bubble1', bytes, 1, 1),
      ).called(1);
    });

    testWidgets('addChatHead with iconWidget renders and delegates', (
      tester,
    ) async {
      when(() => platform.addChatHead(any())).thenAnswer((_) async {});
      await FloatyChatheads.addChatHead(
        id: 'w1',
        iconWidget: const SizedBox(width: 10, height: 10),
        iconSize: 10,
        iconPixelRatio: 1,
      );
      final captured = verify(
        () => platform.addChatHead(captureAny()),
      ).captured;
      final config = captured.first as AddChatHeadConfig;
      expect(config.id, 'w1');
      expect(config.iconSource, isNotNull);
    });

    test('dispose detaches message handler', () {
      FloatyChatheads.onData;
      FloatyChatheads.dispose();
      FloatyChatheads.dispose();
    });
  });
}
