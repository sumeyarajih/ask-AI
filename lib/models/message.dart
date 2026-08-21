class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? attachmentName; 
  final bool isStreaming;

  Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.attachmentName,
    this.isStreaming = false,
  });

  Message copyWith({
    String? text,
    bool? isUser,
    DateTime? timestamp,
    String? attachmentName,
    bool? isStreaming,
  }) {
    return Message(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      attachmentName: attachmentName ?? this.attachmentName,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }
}