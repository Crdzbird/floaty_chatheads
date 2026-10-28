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
    testWidgets('renders with initialData before any messages', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyDataBuilder<int>(
            initialData: 42,
            onData: (current, raw) => current,
            builder: (context, data) => Text('$data'),
          ),
        ),
      );

      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('calls onData reducer and rebuilds when data arrives', (
      tester,
    ) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FloatyDataBuilder<int>(
            initialData: 0,
            onData: (current, raw) => raw is Map && raw['count'] is int
                ? raw['count'] as int
                : current,
            builder: (context, data) => Text('count:$data'),
          ),
        ),
      );

      expect(find.text('count:0'), findsOneWidget);

      await deliverMessengerMessageNow({'count': 5});
      await tester.pump();

      expect(find.text('count:5'), findsOneWidget);
    });
  });
}
