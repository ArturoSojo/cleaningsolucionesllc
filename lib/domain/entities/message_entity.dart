import 'package:equatable/equatable.dart';

enum MessageType { text, image, system }

class MessageEntity extends Equatable {
  final String id;
  final String orderId;
  final String senderId;
  final String senderName;
  final bool isAdmin;
  final String content;
  final MessageType type;
  final DateTime createdAt;
  final bool isRead;

  const MessageEntity({
    required this.id,
    required this.orderId,
    required this.senderId,
    required this.senderName,
    required this.isAdmin,
    required this.content,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  bool get isImage => type == MessageType.image;
  bool get isText => type == MessageType.text;
  bool get isSystem => type == MessageType.system;

  @override
  List<Object?> get props => [id, orderId, senderId, content, type, createdAt, isRead];
}
