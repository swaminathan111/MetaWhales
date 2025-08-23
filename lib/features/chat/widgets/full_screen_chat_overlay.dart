import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../services/rag_chat_service.dart';
import '../services/chat_persistence_service.dart';
import '../services/openrouter_service.dart';
import '../../../shared/widgets/chat/chat_message_bubble.dart';

class FullScreenChatOverlay extends ConsumerStatefulWidget {
  const FullScreenChatOverlay({super.key});

  @override
  ConsumerState<FullScreenChatOverlay> createState() => _FullScreenChatOverlayState();
}

class _FullScreenChatOverlayState extends ConsumerState<FullScreenChatOverlay>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;
  
  static final Logger _logger = Logger();

  // Conversation starters
  final List<String> _conversationStarters = [
    "Which card for ₹5K electronics?",
    "Lounge access near me",
    "Compare Infinia vs Magnus",
    "Find hidden perks on my cards",
    "Best cashback for groceries",
  ];

  @override
  void initState() {
    super.initState();
    _logger.d('FullScreenChatOverlay: initState called');
    
    try {
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
      _logger.d('FullScreenChatOverlay: AnimationController created');
      
      _slideAnimation = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ));
      
      _fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ));
      _logger.d('FullScreenChatOverlay: Animations configured');
      
      _animationController.forward();
      _logger.d('FullScreenChatOverlay: Animation started');
    } catch (e) {
      _logger.e('FullScreenChatOverlay: Error in initState: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _closeChat() async {
    await _animationController.reverse();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _sendMessage([String? predefinedMessage]) async {
    final message = predefinedMessage ?? _messageController.text.trim();
    if (message.isEmpty) return;

    if (predefinedMessage == null) {
      _messageController.clear();
    }

    setState(() => _isLoading = true);

    try {
      final chatNotifier = ref.read(persistentChatMessagesProvider.notifier);
      await chatNotifier.sendMessage(message);
      
      // Scroll to bottom after sending
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearChatHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat History'),
        content: const Text('Are you sure you want to clear all chat history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(persistentChatMessagesProvider.notifier).clearMessages();
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _logger.d('FullScreenChatOverlay: build method called');
    
    try {
      final messages = ref.watch(persistentChatMessagesProvider);
      _logger.d('FullScreenChatOverlay: Messages loaded, count: ${messages.length}');
      
      final theme = Theme.of(context);
      _logger.d('FullScreenChatOverlay: Theme loaded');
      
      return WillPopScope(
        onWillPop: () async {
          _logger.d('FullScreenChatOverlay: Back button pressed');
          await _closeChat();
          return false; // We handle the pop ourselves
        },
        child: Scaffold(
          backgroundColor: Colors.black.withOpacity(0.5),
          body: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            _logger.d('FullScreenChatOverlay: AnimatedBuilder building, fadeValue: ${_fadeAnimation.value}');
            return SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: SafeArea(
                          bottom: false,
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.smart_toy,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'CardSense AI',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      'Your smart card assistant',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'clear') {
                                    _clearChatHistory();
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'clear',
                                    child: Row(
                                      children: [
                                        Icon(Icons.clear_all, size: 16),
                                        SizedBox(width: 8),
                                        Text('Clear History'),
                                      ],
                                    ),
                                  ),
                                ],
                                child: const Icon(Icons.more_vert, color: Colors.grey),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: _closeChat,
                                icon: const Icon(Icons.close, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Chat content
                      Expanded(
                        child: messages.isEmpty
                            ? _buildEmptyState()
                            : _buildChatMessages(messages),
                      ),
                      
                      // Input area
                      _buildInputArea(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        ),
      );
    } catch (e) {
      _logger.e('FullScreenChatOverlay: Error in build method: $e');
      return Scaffold(
        backgroundColor: Colors.red.withOpacity(0.5),
        body: Center(
          child: Text('Error: $e', style: const TextStyle(color: Colors.white)),
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary.withOpacity(0.1), theme.colorScheme.secondary.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 40,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'How can I help you today?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Ask me anything about your credit cards, benefits, or recommendations',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Conversation starters
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Try asking:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - 48,
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _conversationStarters.map((starter) {
                return GestureDetector(
                  onTap: () => _sendMessage(starter),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
                    ),
                    child: Text(
                      starter,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessages(List<ChatMessage> messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length) {
          // Loading indicator
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF58D5D3).withOpacity(0.1),
                  child: const Icon(
                    Icons.smart_toy,
                    size: 18,
                    color: Color(0xFF58D5D3),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFF58D5D3),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Thinking...',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ChatMessageBubble(message: messages[index]),
        );
      },
    );
  }

  Widget _buildInputArea() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Ask me anything about your cards...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                  enabled: !_isLoading,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _isLoading ? null : () => _sendMessage(),
                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
