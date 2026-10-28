import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _channel = BasicMessageChannel<Object?>(
  FloatyChannels.messenger,
  JSONMessageCodec(),
);

void _answerWith(Object? reply) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockDecodedMessageHandler<Object?>(_channel, (_) async => reply);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockDecodedMessageHandler<Object?>(_channel, null),
  );

  test('returns once the overlay answers the ping', () async {
    _answerWith(FloatyChannels.pong);
    var closed = false;
    await OverlayReadiness.ensureReady(
      const ChatHeadConfig(),
      closeOverlay: () async => closed = true,
    );
    expect(closed, isFalse);
  });

  test('closes the overlay and throws when it never answers', () async {
    _answerWith(null);
    var closed = false;
    await expectLater(
      OverlayReadiness.ensureReady(
        const ChatHeadConfig(
          entryPoint: 'missing',
          readyTimeout: Duration(milliseconds: 250),
        ),
        closeOverlay: () async => closed = true,
      ),
      throwsA(
        isA<FloatyOverlayNotReadyException>()
            .having((e) => e.entryPoint, 'entryPoint', 'missing'),
      ),
    );
    expect(closed, isTrue);
  });

  test('a zero timeout skips the check', () async {
    _answerWith(null);
    var closed = false;
    await OverlayReadiness.ensureReady(
      const ChatHeadConfig(readyTimeout: Duration.zero),
      closeOverlay: () async => closed = true,
    );
    expect(closed, isFalse);
  });

  test('the exception explains the usual causes', () {
    const error = FloatyOverlayNotReadyException(
      entryPoint: 'overlayMain',
      timeout: Duration(seconds: 1),
    );
    expect(error.toString(), contains("@pragma('vm:entry-point')"));
    expect(error.toString(), contains('the root library'));
  });
}
