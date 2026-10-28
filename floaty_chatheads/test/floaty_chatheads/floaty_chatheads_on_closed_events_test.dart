import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/chatheads_harness.dart';
import '../helpers/messenger_delivery.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  useSyntheticImageEncoder();

  group('FloatyChatheads', () {
    setUp(installMockChatheadsPlatform);

    setUpAll(registerChatheadsFallbacks);

    tearDown(FloatyChatheads.dispose);

    group('onClosed', () {
      test('emits chathead ID from system envelope', () async {
        final ids = <String>[];
        FloatyChatheads.onClosed.listen(ids.add);

        await deliverMessengerMessage({
          '__floaty__': '_floaty_closed',
          '_floaty_closed': {'id': 'bubble1'},
        });
        expect(ids, ['bubble1']);
      });

      test('defaults to "default" when id is absent', () async {
        final ids = <String>[];
        FloatyChatheads.onClosed.listen(ids.add);

        await deliverMessengerMessage({
          '__floaty__': '_floaty_closed',
          '_floaty_closed': <String, dynamic>{},
        });
        expect(ids, ['default']);
      });

      test('dispose unregisters handler and stops emitting', () async {
        final ids = <String>[];
        FloatyChatheads.onClosed.listen(ids.add);

        FloatyChatheads.dispose();

        await deliverMessengerMessage({
          '__floaty__': '_floaty_closed',
          '_floaty_closed': {'id': 'bubble2'},
        });
        expect(ids, isEmpty);
      });

      test('re-attaches handler after dispose + re-access', () async {
        FloatyChatheads.onClosed;
        FloatyChatheads.dispose();

        final ids = <String>[];
        FloatyChatheads.onClosed.listen(ids.add);

        await deliverMessengerMessage({
          '__floaty__': '_floaty_closed',
          '_floaty_closed': {'id': 'bubble3'},
        });
        expect(ids, ['bubble3']);
      });
    });
  });
}
