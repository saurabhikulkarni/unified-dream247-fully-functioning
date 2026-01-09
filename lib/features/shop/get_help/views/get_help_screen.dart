import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:unified_dream247/features/shop/constants.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class GetHelpScreen extends StatefulWidget {
  const GetHelpScreen({super.key});

  @override
  State<GetHelpScreen> createState() => _GetHelpScreenState();
}

class _GetHelpScreenState extends State<GetHelpScreen> {
  late TextEditingController _messageController;
  late ScrollController _scrollController;
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  // Chatbot responses database
  final Map<String, String> _botResponses = {
    'wallet': 'Your Dream247 Shopping Wallet allows you to add money and receive equivalent Shopping Credits (Tokens). These credits never expire and can be used to purchase products on our platform. To add money, go to Profile > Wallet > Add Money.',
    'token': 'Shopping Credits (Tokens) are digital credits issued by Dream247. For every ₹1 you add to your wallet, you get 1 Token. Tokens can only be used for shopping on Dream247 and cannot be withdrawn or transferred.',
    'refund': 'Dream247 follows a No Refund Policy. Refunds may only be considered in rare and exceptional cases such as duplicate payment due to technical failure or proven transaction errors, subject to Dream247\'s discretion.',
    'return': 'Dream247 follows a No Return Policy. All purchases are considered final. Returns are not accepted unless explicitly mentioned otherwise.',
    'cancel': 'Order cancellation is not guaranteed once an order is placed. Cancellation may be denied if the order has not been processed or shipped, subject to Dream247\'s discretion.',
    'shipping': 'Your order will be shipped through our logistics partner. Once shipped, you\'ll receive a tracking number via email and SMS. You can track your order in Profile > Orders.',
    'payment': 'Dream247 uses a secure payment gateway. You add money to your wallet, receive equivalent tokens, and then use these tokens to shop. No external payment is required during purchase.',
    'account': 'You can manage your account from Profile > User Info. You can update your name, email, and phone number. For security, manage your account carefully.',
    'order': 'View your orders in Profile > Orders. You can see order status, tracking information, and estimated delivery date. Tap any order to view detailed information.',
    'wishlist': 'Add products to your Wishlist by tapping the heart icon on any product. View your wishlist in Profile > Wishlist. You can remove items by tapping the heart again.',
    'address': 'Manage your delivery addresses in Profile > Addresses. You can add, edit, or delete addresses. Select your address during checkout.',
    'password': 'You can reset your password from the Login screen. Tap "Forgot Password" and follow the verification steps to set a new password.',
    'account suspension': 'If your account is suspended or closed, it may be due to policy violations. Contact our support team for more information.',
    'expiry': 'Shopping Credits never expire as long as your account is active. You can use them anytime without worrying about expiration dates.',
    'transfer': 'Shopping Credits are non-transferable. They can only be used by the account holder and cannot be transferred to another user.',
  };

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    
    // Send initial greeting
    _addBotMessage(
      'Hi! 👋 Welcome to Dream247 Support. I\'m here to help! You can ask me about:\n'
      '• Wallet & Tokens\n'
      '• Orders & Shipping\n'
      '• Returns & Refunds\n'
      '• Payment & Addresses\n'
      '• Account Management\n\nHow can I help you today?',
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
    });
    _scrollToBottom();
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: false));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendEmail() async {
    const email = 'contact@brighthex.in';
    const subject = 'Support Request - Dream247';
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': subject,
      },
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open email client. Please try again.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error opening email client.'),
        ),
      );
    }
  }

  String _generateBotResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    // Check for exact keyword matches
    for (var entry in _botResponses.entries) {
      if (lowerMessage.contains(entry.key)) {
        return entry.value;
      }
    }

    // If no match found, provide general help
    return 'I\'m not sure about that topic. Here\'s what I can help with:\n'
        '• Wallet & Shopping Credits\n'
        '• Orders & Shipping\n'
        '• Returns & Refunds\n'
        '• Payment & Addresses\n'
        '• Account Management\n\n'
        'Please feel free to ask about any of these topics, or contact our support team via email for specific concerns.';
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    _addUserMessage(message);

    // Simulate typing
    setState(() => _isTyping = true);
    await Future.delayed(const Duration(milliseconds: 800));

    final botResponse = _generateBotResponse(message);
    setState(() => _isTyping = false);

    _addBotMessage(botResponse);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dream247 Support'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(defaultPadding),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return _buildTypingIndicator();
                }

                final message = _messages[index];
                return _buildChatBubble(message);
              },
            ),
          ),
          if (_isTyping) const SizedBox(height: 8),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).primaryColor
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.black87,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            const SizedBox(width: 4),
            _buildDot(1),
            const SizedBox(width: 4),
            _buildDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedOpacity(
      opacity: _isTyping ? 1 : 0.3,
      duration: Duration(milliseconds: 600 + (index * 200)),
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.only(
        left: defaultPadding,
        right: defaultPadding,
        bottom: MediaQuery.of(context).viewInsets.bottom + defaultPadding,
        top: defaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: !_isTyping,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Type your question...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: _isTyping ? null : _sendMessage,
            mini: true,
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(
              Icons.send,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 4),
          FloatingActionButton(
            onPressed: _sendEmail,
            mini: true,
            backgroundColor: Colors.blue,
            child: const Icon(
              Icons.email_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
