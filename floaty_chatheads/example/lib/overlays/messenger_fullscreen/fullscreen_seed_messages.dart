import 'fullscreen_chat_message.dart';

/// Returns a new, growable list with the conversation the overlay starts
/// with.
List<FullscreenChatMessage> fullscreenSeedMessages() => [
  const FullscreenChatMessage(
    text: 'Hey! How are you?',
    isMe: false,
    time: '10:30 AM',
  ),
  const FullscreenChatMessage(
    text: "I'm good! Working on the project",
    isMe: true,
    time: '10:31 AM',
  ),
  const FullscreenChatMessage(
    text: "Nice, how's it going?",
    isMe: false,
    time: '10:31 AM',
  ),
  const FullscreenChatMessage(
    text: 'Pretty well! Almost done with the chat overlay feature',
    isMe: true,
    time: '10:32 AM',
  ),
  const FullscreenChatMessage(
    text: 'That sounds awesome! Can I see a demo?',
    isMe: false,
    time: '10:33 AM',
  ),
];
