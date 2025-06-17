import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  /// NEW FIELDS
  final String senderId;
  final String receiverId;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    required this.senderId,
    required this.receiverId,
  });

  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    String? senderId,
    String? receiverId,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      text: json['text'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
    'senderId': senderId,
    'receiverId': receiverId,
  };

  factory ChatMessage.empty() {
    return ChatMessage(
      id: '',
      text: '',
      isUser: false,
      timestamp: DateTime.fromMillisecondsSinceEpoch(0),
      senderId: '',
      receiverId: '',
    );
  }

  @override
  List<Object?> get props => [
    id,
    text,
    isUser,
    timestamp,
    senderId,
    receiverId,
  ];
}
