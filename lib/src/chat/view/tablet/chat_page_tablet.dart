import 'package:crmapp/src/chat/bloc/chat_bloc.dart';
import 'package:crmapp/src/common/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatPageTablet extends StatefulWidget {
  const ChatPageTablet({super.key});

  @override
  State<ChatPageTablet> createState() => _ChatPageTabletState();
}

class _ChatPageTabletState extends State<ChatPageTablet> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();

    _channel = WebSocketChannel.connect(Uri.parse('wss://echo.websocket.org'));

    _channel.stream.listen((message) {
      final state = context.read<ChatMessageBloc>().state;

      final incomingMessage = ChatMessage(
        id: UniqueKey().toString(),
        text: message.toString(),
        isUser: false,
        timestamp: DateTime.now(),
        senderId: 'bot',
        receiverId: state.customer?.id ?? '',
      );

      context.read<ChatMessageBloc>().add(
        ReceiveChatMessage(message: incomingMessage),
      );
      _scrollToBottom();
    });
  }

  void _sendMessage() {
    final messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      final state = context.read<ChatMessageBloc>().state;

      final message = ChatMessage(
        id: UniqueKey().toString(),
        text: messageText,
        isUser: true,
        timestamp: DateTime.now(),
        senderId: "3",
        receiverId: state.customer?.id ?? '',
      );

      _channel.sink.add(messageText);

      context.read<ChatMessageBloc>().add(SendChatMessage(message: message));

      _messageController.clear();
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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _startVoiceCall() {
    final state = context.read<ChatMessageBloc>().state;
    final customer = state.customer;

    if (customer == null || customer.id.isEmpty) return;

    context.push(
      '/voicecall',
      extra: {'callerId': '3', 'calleeId': customer.id, 'isCaller': true},
    );
  }

  void _startVideoCall() {
    final state = context.read<ChatMessageBloc>().state;
    final customer = state.customer;

    if (customer == null || customer.id.isEmpty) return;

    context.push(
      '/call',
      extra: {'callerId': '3', 'calleeId': customer.id, 'isCaller': true},
    );
  }

  @override
  void dispose() {
    _channel.sink.close();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF64748B)),
          onPressed: () {
            context.go('/customer');
          },
        ),
        title: BlocBuilder<ChatMessageBloc, ChatPageState>(
          builder: (context, state) {
            final customer = state.customer;
            final isOnline = customer?.status ?? false;

            return Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFF6366F1),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer?.name ?? "Customer",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: isOnline ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isOnline ? 'Online' : 'Offline',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_outlined, color: Color(0xFF64748B)),
            onPressed: _startVoiceCall,
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: Color(0xFF64748B)),
            onPressed: _startVideoCall,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF64748B)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatMessageBloc, ChatPageState>(
              builder: (context, state) {
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(24),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final msg = state.messages[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisAlignment: msg.isUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!msg.isUser)
                            const CircleAvatar(
                              radius: 18,
                              backgroundColor: Color(0xFF6366F1),
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          if (!msg.isUser) const SizedBox(width: 12),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: msg.isUser
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: msg.isUser
                                        ? const Color(0xFF6366F1)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20)
                                        .copyWith(
                                          bottomLeft: msg.isUser
                                              ? const Radius.circular(20)
                                              : const Radius.circular(4),
                                          bottomRight: msg.isUser
                                              ? const Radius.circular(4)
                                              : const Radius.circular(20),
                                        ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    msg.text,
                                    style: TextStyle(
                                      color: msg.isUser
                                          ? Colors.white
                                          : const Color(0xFF1E293B),
                                      fontSize: 16,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatTime(msg.timestamp),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (msg.isUser) const SizedBox(width: 12),
                          if (msg.isUser)
                            const CircleAvatar(
                              radius: 18,
                              backgroundColor: Color(0xFF10B981),
                              child: Text(
                                'U',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.attach_file_outlined,
                    color: Color(0xFF64748B),
                  ),
                  onPressed: () {},
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                      maxLines: null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send),
                    color: Colors.white,
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
