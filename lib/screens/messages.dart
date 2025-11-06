import 'package:bezoni/themes/theme_extensions.dart';
import 'package:flutter/material.dart';

// Message Models
class ChatMessage {
  final String id;
  final String text;
  final DateTime timestamp;
  final bool isFromUser;
  MessageStatus status;

  ChatMessage({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isFromUser,
    this.status = MessageStatus.sent,
  });
}

enum MessageStatus { sending, sent, delivered, read }

class ChatThread {
  final String id;
  final String name;
  final String avatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool hasUnreadMessages;
  final int unreadCount;
  final List<ChatMessage> messages;
  final bool isOnline;

  ChatThread({
    required this.id,
    required this.name,
    required this.avatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.hasUnreadMessages = false,
    this.unreadCount = 0,
    required this.messages,
    this.isOnline = false,
  });
}

// Chat Manager
class ChatManager extends ChangeNotifier {
  static final ChatManager _instance = ChatManager._internal();
  factory ChatManager() => _instance;
  ChatManager._internal() {
    _initializeChats();
  }

  List<ChatThread> _chatThreads = [];
  List<ChatThread> get chatThreads => _chatThreads;

  void _initializeChats() {
    _chatThreads = [
      ChatThread(
        id: '1',
        name: 'Musa Saliu',
        avatar: 'MS',
        lastMessage: 'Coming Out Now',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
        hasUnreadMessages: true,
        unreadCount: 1,
        isOnline: true,
        messages: [
          ChatMessage(
            id: '1',
            text: 'Good evening! This is Alex, your delivery rider. I\'m currently on route with your order and should arrive in about 10 minutes.',
            timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
            isFromUser: false,
          ),
          ChatMessage(
            id: '2',
            text: 'Great, thanks! Please note that the entrance is through the side gate.',
            timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
            isFromUser: true,
            status: MessageStatus.read,
          ),
          ChatMessage(
            id: '3',
            text: 'Understood, I will use the side gate upon arrival. Will call you also.',
            timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
            isFromUser: false,
          ),
          ChatMessage(
            id: '4',
            text: 'Hi, I\'ve arrived at your location and am at the side gate.',
            timestamp: DateTime.now().subtract(const Duration(minutes: 7)),
            isFromUser: false,
          ),
          ChatMessage(
            id: '5',
            text: 'Coming Out Now',
            timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
            isFromUser: false,
          ),
        ],
      ),
      ChatThread(
        id: '2',
        name: 'Lara Adebayo',
        avatar: 'LA',
        lastMessage: 'Hey, Yes 12 Minutes Away From Your Location',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 44)),
        hasUnreadMessages: false,
        unreadCount: 0,
        isOnline: false,
        messages: [
          ChatMessage(
            id: '1',
            text: 'Hey, Yes 12 Minutes Away From Your Location',
            timestamp: DateTime.now().subtract(const Duration(minutes: 44)),
            isFromUser: false,
          ),
        ],
      ),
      ChatThread(
        id: '3',
        name: 'Mohammed Sion',
        avatar: 'MS',
        lastMessage: 'Just To Drop by At 35 This Avenue, And The...',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 45)),
        hasUnreadMessages: false,
        unreadCount: 0,
        isOnline: true,
        messages: [
          ChatMessage(
            id: '1',
            text: 'Just To Drop by At 35 This Avenue, And The delivery should be completed in 5 minutes',
            timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
            isFromUser: false,
          ),
        ],
      ),
      ChatThread(
        id: '4',
        name: 'Adetola Charles',
        avatar: 'AC',
        lastMessage: 'So Could You Help Me Carry The Items...',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 50)),
        hasUnreadMessages: false,
        unreadCount: 0,
        isOnline: false,
        messages: [
          ChatMessage(
            id: '1',
            text: 'So Could You Help Me Carry The Items to the second floor please?',
            timestamp: DateTime.now().subtract(const Duration(minutes: 50)),
            isFromUser: false,
          ),
        ],
      ),
    ];
  }

  void sendMessage(String threadId, String message) {
    final threadIndex = _chatThreads.indexWhere((thread) => thread.id == threadId);
    if (threadIndex != -1) {
      final newMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: message,
        timestamp: DateTime.now(),
        isFromUser: true,
        status: MessageStatus.sending,
      );
      
      _chatThreads[threadIndex].messages.add(newMessage);
      
      // Update last message
      _chatThreads[threadIndex] = ChatThread(
        id: _chatThreads[threadIndex].id,
        name: _chatThreads[threadIndex].name,
        avatar: _chatThreads[threadIndex].avatar,
        lastMessage: message,
        lastMessageTime: DateTime.now(),
        hasUnreadMessages: _chatThreads[threadIndex].hasUnreadMessages,
        unreadCount: _chatThreads[threadIndex].unreadCount,
        messages: _chatThreads[threadIndex].messages,
        isOnline: _chatThreads[threadIndex].isOnline,
      );

      notifyListeners();

      // Simulate message status updates
      Future.delayed(const Duration(milliseconds: 500), () {
        newMessage.status = MessageStatus.sent;
        notifyListeners();
      });

      Future.delayed(const Duration(seconds: 1), () {
        newMessage.status = MessageStatus.delivered;
        notifyListeners();
      });
    }
  }

  void markAsRead(String threadId) {
    final threadIndex = _chatThreads.indexWhere((thread) => thread.id == threadId);
    if (threadIndex != -1 && _chatThreads[threadIndex].hasUnreadMessages) {
      _chatThreads[threadIndex] = ChatThread(
        id: _chatThreads[threadIndex].id,
        name: _chatThreads[threadIndex].name,
        avatar: _chatThreads[threadIndex].avatar,
        lastMessage: _chatThreads[threadIndex].lastMessage,
        lastMessageTime: _chatThreads[threadIndex].lastMessageTime,
        hasUnreadMessages: false,
        unreadCount: 0,
        messages: _chatThreads[threadIndex].messages,
        isOnline: _chatThreads[threadIndex].isOnline,
      );
      notifyListeners();
    }
  }
}

/// =====================
/// Messages Screen
/// =====================
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Messages",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: context.surfaceColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.search,
              color: context.subtitleColor,
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ListenableBuilder(
            listenable: ChatManager(),
            builder: (context, _) {
              final chatThreads = ChatManager().chatThreads;
              
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: chatThreads.length,
                itemBuilder: (context, index) {
                  final thread = chatThreads[index];
                  return _AnimatedChatTile(
                    thread: thread,
                    delay: Duration(milliseconds: index * 100),
                    onTap: () => _openChat(context, thread),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _openChat(BuildContext context, ChatThread thread) {
    ChatManager().markAsRead(thread.id);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ChatScreen(thread: thread),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

class _AnimatedChatTile extends StatefulWidget {
  const _AnimatedChatTile({
    required this.thread,
    required this.delay,
    required this.onTap,
  });

  final ChatThread thread;
  final Duration delay;
  final VoidCallback onTap;

  @override
  State<_AnimatedChatTile> createState() => _AnimatedChatTileState();
}

class _AnimatedChatTileState extends State<_AnimatedChatTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: context.shadowColor,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: const Color(0xFF10B981).withOpacity(0.15),
                            child: Text(
                              widget.thread.avatar,
                              style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (widget.thread.isOnline)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.thread.name,
                              style: TextStyle(
                                fontWeight: widget.thread.hasUnreadMessages
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                fontSize: 16,
                                color: context.textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.thread.lastMessage,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: widget.thread.hasUnreadMessages
                                    ? const Color(0xFF374151)
                                    : context.subtitleColor,
                                fontSize: 14,
                                fontWeight: widget.thread.hasUnreadMessages
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatTime(widget.thread.lastMessageTime),
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.thread.hasUnreadMessages
                                  ? const Color(0xFF10B981)
                                  : context.subtitleColor,
                              fontWeight: widget.thread.hasUnreadMessages
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                          if (widget.thread.hasUnreadMessages)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}:${(difference.inSeconds % 60).toString().padLeft(2, '0')}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}:${(difference.inMinutes % 60).toString().padLeft(2, '0')}';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

// Chat Screen
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.thread});

  final ChatThread thread;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _messageController;

  @override
  void initState() {
    super.initState();
    _messageController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF10B981).withOpacity(0.15),
                  child: Text(
                    widget.thread.avatar,
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (widget.thread.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.thread.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (widget.thread.isOnline)
                    const Text(
                      "Online",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: context.surfaceColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListenableBuilder(
              listenable: ChatManager(),
              builder: (context, _) {
                final messages = ChatManager()
                    .chatThreads
                    .firstWhere((thread) => thread.id == widget.thread.id)
                    .messages;

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _MessageBubble(
                      message: message,
                      delay: Duration(milliseconds: index * 100),
                      thread: widget.thread,
                    );
                  },
                );
              },
            ),
          ),
          _ChatInput(
            controller: _textController,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _sendMessage(String message) {
    if (message.trim().isNotEmpty) {
      ChatManager().sendMessage(widget.thread.id, message.trim());
      _textController.clear();
      
      // Scroll to bottom
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }
}

class _MessageBubble extends StatefulWidget {
  const _MessageBubble({
    required this.message,
    required this.delay,
    required this.thread,
  });

  final ChatMessage message;
  final Duration delay;
  final ChatThread thread;

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: widget.message.isFromUser
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  if (!widget.message.isFromUser) ...[
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: const Color(0xFF10B981).withOpacity(0.15),
                      child: Text(
                        widget.thread.avatar,
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: widget.message.isFromUser
                            ? const Color(0xFF10B981)
                            : context.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: context.shadowColor,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.message.text,
                            style: TextStyle(
                              color: widget.message.isFromUser
                                  ? Colors.white
                                  : context.textColor,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatTime(widget.message.timestamp),
                                style: TextStyle(
                                  color: widget.message.isFromUser
                                      ? Colors.white.withOpacity(0.7)
                                      : context.subtitleColor,
                                  fontSize: 10,
                                ),
                              ),
                              if (widget.message.isFromUser) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  _getStatusIcon(widget.message.status),
                                  size: 12,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (widget.message.isFromUser) ...[
                    const SizedBox(width: 8),
                    const CircleAvatar(
                      radius: 12,
                      backgroundColor: Color(0xFF3B82F6),
                      child: Text(
                        "Me",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  IconData _getStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return Icons.access_time;
      case MessageStatus.sent:
        return Icons.check;
      case MessageStatus.delivered:
        return Icons.done_all;
      case MessageStatus.read:
        return Icons.done_all;
    }
  }
}

class _ChatInput extends StatefulWidget {
  const _ChatInput({
    required this.controller,
    required this.onSend,
  });

  final TextEditingController controller;
  final Function(String) onSend;

  @override
  State<_ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<_ChatInput> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.surfaceColor,
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: context.backgroundColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: widget.controller,
                  decoration: const InputDecoration(
                    hintText: "Type Your Message",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: IconButton(
                onPressed: _hasText
                    ? () => widget.onSend(widget.controller.text)
                    : null,
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _hasText
                        ? const Color(0xFF10B981)
                        : const Color(0xFFE5E7EB),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.send,
                    color: _hasText ? Colors.white : const Color(0xFF9CA3AF),
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}