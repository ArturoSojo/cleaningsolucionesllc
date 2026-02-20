import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../presentation/providers/app_providers.dart';
import '../../../presentation/providers/order_providers.dart';
import '../../../data/models/message_model.dart';
import '../../../domain/entities/message_entity.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String orderId;
  const ChatScreen({super.key, required this.orderId});
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;
    setState(() => _isSending = true);
    _controller.clear();
    try {
      final msg = MessageModel(
        id: '',
        orderId: widget.orderId,
        senderId: user.id,
        senderName: user.name,
        isAdmin: user.isAdmin,
        content: text,
        type: MessageType.text,
        createdAt: DateTime.now(),
      );
      await ref.read(firestoreDataSourceProvider).sendMessage(widget.orderId, msg);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    setState(() => _isSending = true);
    try {
      final file = File(picked.path);
      final url = await ref.read(firestoreDataSourceProvider).uploadPaymentProof(widget.orderId, file);
      final msg = MessageModel(
        id: '',
        orderId: widget.orderId,
        senderId: user.id,
        senderName: user.name,
        isAdmin: user.isAdmin,
        content: url,
        type: MessageType.image,
        createdAt: DateTime.now(),
      );
      await ref.read(firestoreDataSourceProvider).sendMessage(widget.orderId, msg);
      await ref.read(firestoreDataSourceProvider).updateOrderPaymentProof(widget.orderId, url, 'uploaded');
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e'), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    final messagesAsync = ref.watch(messagesProvider(widget.orderId));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Chat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text('Order #${widget.orderId.substring(0, 8)}', style: const TextStyle(fontSize: 11, color: AppColors.skyBlue)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.payment_rounded),
            tooltip: 'Payment Info',
            onPressed: () => _showPaymentInfo(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded, size: 64, color: AppColors.textSecondaryLight.withOpacity(0.3)),
                        const SizedBox(height: 12),
                        const Text('No messages yet', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: AppColors.textSecondaryLight)),
                        const SizedBox(height: 4),
                        const Text('Start the conversation!', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textSecondaryLight)),
                      ],
                    ),
                  );
                }
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, i) => _MessageBubble(
                    message: messages[i],
                    isMe: user?.id == messages[i].senderId,
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
          // Input Bar
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, -2))],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.image_outlined, color: AppColors.navyBlue),
                    onPressed: _isSending ? null : _pickAndUploadImage,
                    tooltip: 'Upload payment proof',
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: AppColors.offWhite,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _isSending ? null : _sendMessage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _isSending ? AppColors.textSecondaryLight : AppColors.navyBlue,
                        shape: BoxShape.circle,
                      ),
                      child: _isSending
                          ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Payment Instructions', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.navyBlue)),
            const SizedBox(height: 16),
            _InfoRow(icon: Icons.account_balance_wallet_rounded, label: 'Zelle', value: 'arturosojovivas@gmail.com'),
            const SizedBox(height: 10),
            _InfoRow(icon: Icons.payment_rounded, label: 'Venmo', value: '@CleaningSoluciones'),
            const SizedBox(height: 16),
            const Text('After payment, tap the image icon to upload your payment screenshot.', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondaryLight, height: 1.5)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.navyBlue, size: 20),
        const SizedBox(width: 10),
        Text('$label: ', style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navyBlue)),
        Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textSecondaryLight)),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;
  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    if (message.isSystem) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(color: AppColors.dividerLight, borderRadius: BorderRadius.circular(20)),
          child: Text(message.content, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondaryLight)),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.navyBlue,
              child: Text(message.senderName.isNotEmpty ? message.senderName[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
              padding: message.isImage ? const EdgeInsets.all(4) : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? AppColors.navyBlue : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)],
              ),
              child: message.isImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        message.content,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) => progress == null
                            ? child
                            : const SizedBox(width: 200, height: 200, child: Center(child: CircularProgressIndicator())),
                      ),
                    )
                  : Text(
                      message.content,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: isMe ? Colors.white : AppColors.navyBlue,
                        height: 1.4,
                      ),
                    ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.lightBlue,
              child: Text(message.senderName.isNotEmpty ? message.senderName[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      ),
    );
  }
}
