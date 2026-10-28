import 'package:floaty_chatheads/floaty_chatheads.dart';
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

    group('onClosed', () {
      test('returns a broadcast stream', () {
        FloatyChatheads.onClosed
          ..listen((_) {})
          ..listen((_) {});
      });

      test('disposes animation when matching ID is closed', () async {
        when(() => platform.showChatHead(any())).thenAnswer((_) async {});
        when(
          () => platform.updateChatHeadIcon(any(), any(), any(), any()),
        ).thenAnswer((_) async {});

        await FloatyChatheads.showChatHead(
          iconBuilder: (_) => const SizedBox(width: 10, height: 10),
          animateIcon: true,
          iconSize: 10,
          iconPixelRatio: 1,
        );
        expect(FloatyChatheads.isIconAnimating, isTrue);

        FloatyChatheads.onClosed.listen((_) {});

        await deliverMessengerMessage({
          '__floaty__': '_floaty_closed',
          '_floaty_closed': {'id': 'default'},
        });
        expect(FloatyChatheads.isIconAnimating, isFalse);
      });

      test(
        'does not dispose animation when non-matching ID is closed',
        () async {
          when(() => platform.showChatHead(any())).thenAnswer((_) async {});
          when(
            () => platform.updateChatHeadIcon(any(), any(), any(), any()),
          ).thenAnswer((_) async {});

          await FloatyChatheads.showChatHead(
            iconBuilder: (_) => const SizedBox(width: 10, height: 10),
            animateIcon: true,
            iconSize: 10,
            iconPixelRatio: 1,
          );
          expect(FloatyChatheads.isIconAnimating, isTrue);

          FloatyChatheads.onClosed.listen((_) {});

          await deliverMessengerMessage({
            '__floaty__': '_floaty_closed',
            '_floaty_closed': {'id': 'other-bubble'},
          });
          expect(FloatyChatheads.isIconAnimating, isTrue);
        },
      );
    });
  });
}
