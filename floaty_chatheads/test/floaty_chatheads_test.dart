import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFloatyChatheadsPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements FloatyChatheadsPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FloatyChatheads', () {
    late MockFloatyChatheadsPlatform platform;

    setUp(() {
      platform = MockFloatyChatheadsPlatform();
      FloatyChatheadsPlatform.instance = platform;
    });

    setUpAll(() {
      registerFallbackValue(const ChatHeadConfig());
      registerFallbackValue(const AddChatHeadConfig(id: ''));
    });

    test('checkPermission delegates to platform', () async {
      when(() => platform.checkPermission()).thenAnswer((_) async => true);
      expect(await FloatyChatheads.checkPermission(), isTrue);
      verify(() => platform.checkPermission()).called(1);
    });

    test('requestPermission delegates to platform', () async {
      when(() => platform.requestPermission()).thenAnswer((_) async => true);
      expect(await FloatyChatheads.requestPermission(), isTrue);
    });

    test('showChatHead delegates to platform', () async {
      when(() => platform.showChatHead(any())).thenAnswer((_) async {});
      await FloatyChatheads.showChatHead();
      verify(() => platform.showChatHead(any())).called(1);
    });

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
  });
}
