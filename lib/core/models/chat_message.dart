class ChatMessage {
  final String text;
  final bool isUser;
  final bool isMarkdown;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isMarkdown = false,
  });
}