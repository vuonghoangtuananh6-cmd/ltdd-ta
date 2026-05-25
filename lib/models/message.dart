import 'package:uuid/uuid.dart';

class Message {
  final String id;
  final String senderId;
  final String senderName;
  final bool isFromAdmin;
  final String content;
  final int timestamp;

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.isFromAdmin,
    required this.content,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? const Uuid().v4(),
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      isFromAdmin: json['isFromAdmin'] ?? false,
      content: json['content'] ?? '',
      timestamp: json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'isFromAdmin': isFromAdmin,
      'content': content,
      'timestamp': timestamp,
    };
  }
}
