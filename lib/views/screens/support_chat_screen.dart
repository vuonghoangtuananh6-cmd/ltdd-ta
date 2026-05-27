// lib/views/screens/support_chat_screen.dart

import 'package:flutter/material.dart';
import '../../controllers/home_controller.dart';
import '../../models/user.dart';
import '../../models/message.dart';
import '../../utils/constants.dart';

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final _homeController = HomeController();
  final _msgCtrl = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _msgCtrl.text.trim();
    if (text.isNotEmpty) {
      _homeController.sendSupportChat(text);
      _msgCtrl.clear();
      _scrollToBottom();
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
    final user = _homeController.currentUser;
    final isDark = user.isDarkMode;
    final isEn = user.language == "EN";

    final bgColor = isDark ? const Color(0xFF0F172A) : AppColors.primaryBackground;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final primaryTextColor = isDark ? Colors.white : AppColors.slate900;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFF1E293B),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.support_agent, color: Color(0xFF60A5FA), size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEn ? "AI Support Assistant" : "Trợ Lý Chăm Sóc AI",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const Row(
                  children: [
                    CircleAvatar(radius: 3, backgroundColor: Color(0xFF22C55E)),
                    SizedBox(width: 4),
                    Text(
                      "Support Online",
                      style: TextStyle(color: Color(0xFF22C55E), fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Message List Stream
          Expanded(
            child: ValueListenableBuilder<List<Message>>(
              valueListenable: _homeController.chatMessagesNotifier,
              builder: (context, messages, _) {
                // Trigger auto-scroll to bottom whenever a new message is received
                _scrollToBottom();

                return ListView.builder(
                  key: const ValueKey("chat_list_view"),
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = !message.isFromAdmin;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isMe) ...[
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: const Color(0xFF1E293B),
                              child: const Icon(Icons.support_agent, color: Color(0xFFF97316), size: 16),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Container(
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isMe ? const Color(0xFFF97316) : cardColor,
                                border: isMe ? null : Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey[200]!),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(2),
                                  bottomRight: isMe ? const Radius.circular(2) : const Radius.circular(16),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!isMe) ...[
                                    Text(
                                      message.senderName,
                                      style: const TextStyle(
                                        color: Color(0xFFFF7E40),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                  ],
                                  Text(
                                    message.content,
                                    style: TextStyle(
                                      color: isMe ? Colors.white : primaryTextColor,
                                      fontSize: 13,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: const Color(0xFF334155),
                              child: Text(
                                message.senderName.isNotEmpty ? message.senderName[0].toUpperCase() : "U",
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Message Input Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 10,
                )
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const ValueKey("chat_input_text_field"),
                      controller: _msgCtrl,
                      style: TextStyle(color: primaryTextColor, fontSize: 14),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: isEn ? "Ask a question..." : "Nhập câu hỏi... (ví dụ: khuyến mãi)",
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        fillColor: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: isDark ? const Color(0xFF475569) : Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFF97316)),
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    key: const ValueKey("chat_send_button"),
                    onTap: _sendMessage,
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF97316),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
