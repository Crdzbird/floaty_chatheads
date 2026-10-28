import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads/testing.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/messenger_delivery.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FloatyChatheadsPlatform.instance = FakeFloatyPlatform();
  });

  group('FloatyDataBuilder', () {
    testWidgets('accumulates list data correctly', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyDataBuilder<List<String>>(
            initialData: const [],
            onData: (msgs, raw) => raw is Map && raw['text'] is String
                ? [...msgs, raw['text'] as String]
                : msgs,
            builder: (context, data) => Text('len:${data.length}'),
          ),
        ),
      );

      expect(find.text('len:0'), findsOneWidget);

      await deliverMessengerMessageNow({'text': 'hello'});
      await tester.pump();
      expect(find.text('len:1'), findsOneWidget);

      await deliverMessengerMessageNow({'text': 'world'});
      await tester.pump();
      expect(find.text('len:2'), findsOneWidget);
    });

    testWidgets('ignores irrelevant messages', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyDataBuilder<int>(
            initialData: 10,
            onData: (current, raw) => raw is Map && raw['count'] is int
                ? raw['count'] as int
                : current,
            builder: (context, data) => Text('$data'),
          ),
        ),
      );

      await deliverMessengerMessageNow('not a map');
      await tester.pump();
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('cancels subscription on unmount', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyDataBuilder<int>(
            initialData: 0,
            onData: (current, raw) => current + 1,
            builder: (context, data) => Text('$data'),
          ),
        ),
      );

      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox.shrink(),
        ),
      );

      await deliverMessengerMessageNow('after unmount');
      await tester.pump();
    });
  });
}
