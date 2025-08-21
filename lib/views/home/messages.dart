import 'package:flutter/material.dart';

/// =====================
/// Messages Screen
/// =====================
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final messages = [
      _Message(
        name: "Bezoni Support",
        message: "Welcome to Bezoni! How can we help you today?",
        time: "2m ago",
        unread: true,
      ),
      _Message(
        name: "Delivery Update",
        message: "Your order from Chicken Republic is on the way!",
        time: "1h ago",
        unread: false,
      ),
      _Message(
        name: "Promo Alert",
        message: "🎉 Get 30% off your next order with code SAVE30",
        time: "3h ago",
        unread: false,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Messages"),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF10B981).withOpacity(0.15),
                child: const Icon(
                  Icons.message,
                  color: Color(0xFF10B981),
                ),
              ),
              title: Text(
                message.name,
                style: TextStyle(
                  fontWeight: message.unread ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              subtitle: Text(
                message.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    message.time,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  if (message.unread)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Opening chat with ${message.name}")),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _Message {
  final String name;
  final String message;
  final String time;
  final bool unread;

  _Message({
    required this.name,
    required this.message,
    required this.time,
    required this.unread,
  });
}
