import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Add this import for kDebugMode
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';
import '../auth/widgets/user_avatar.dart';
import '../auth/services/profile_service.dart';
import '../chat/services/speech_service.dart';
import '../chat/services/openrouter_service.dart';
import '../chat/services/chat_persistence_service.dart';
import '../chat/services/rag_chat_service.dart';
import '../chat/screens/chat_history_screen.dart';
import '../chat/screens/rag_test_screen.dart';
import '../chat/widgets/service_status_indicator.dart';
import '../cards/models/card_info.dart';
import '../cards/providers/card_provider.dart';
import '../cards/screens/add_card_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final bool _isTyping = false;
  late AnimationController _rippleController;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(currentUserProfileProvider);

    // Get display name from profile with fallbacks
    final userName = profileAsync.when(
      data: (profile) =>
          profile?['full_name'] as String? ??
          currentUser?.email?.split('@')[0] ??
          'User',
      loading: () => currentUser?.email?.split('@')[0] ?? 'User',
      error: (_, __) => currentUser?.email?.split('@')[0] ?? 'User',
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => context.push('/profile'),
            child: const UserAvatar(
              size: 40,
              showBorder: true,
              borderColor: Colors.blue,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${userName.split(' ')[0].split('.')[0]}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.credit_card, color: Colors.black54),
            tooltip: 'Manage Cards',
            onPressed: () {
              context.go('/manage-cards');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black54),
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Credit Cards Section - Fixed height
          Container(
            height: 220, // Fixed reasonable height for cards
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final cards = ref.watch(cardsProvider);
                      if (cards.isEmpty) {
                        return Center(
                          child: GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20)),
                                ),
                                builder: (context) => SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.9,
                                  child: AddCardScreen(
                                    onCardAdded: () {
                                      Navigator.pop(context);
                                      setState(() {});
                                    },
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 40),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 2,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.credit_card_outlined,
                                    size: 64,
                                    color: Colors.blue[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Add Your First Card',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.blue[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Get started by adding your credit card\nto unlock personalized recommendations',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      return PageView.builder(
                        clipBehavior: Clip.none,
                        itemCount: cards.length + 1,
                        pageSnapping: true,
                        controller: PageController(viewportFraction: 0.85),
                        itemBuilder: (context, index) {
                          if (index == cards.length) {
                            return GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.white,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20)),
                                  ),
                                  builder: (context) => SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.9,
                                    child: AddCardScreen(
                                      onCardAdded: () {
                                        Navigator.pop(context);
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_circle_outline,
                                      size: 48,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Add New Card',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          final card = cards[index];
                          return GestureDetector(
                            onLongPress: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: const Icon(Icons.edit),
                                        title: const Text('Edit Card'),
                                        onTap: () {
                                          Navigator.pop(context);
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.white,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      top: Radius.circular(20)),
                                            ),
                                            builder: (context) => SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.9,
                                              child: AddCardScreen(
                                                onCardAdded: () {
                                                  Navigator.pop(context);
                                                  setState(() {});
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.delete,
                                            color: Colors.red),
                                        title: const Text('Delete Card',
                                            style:
                                                TextStyle(color: Colors.red)),
                                        onTap: () {
                                          Navigator.pop(context);
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Delete Card'),
                                              content: Text(
                                                  'Are you sure you want to delete ${card.bank} ${card.cardType}?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    ref
                                                        .read(cardsProvider
                                                            .notifier)
                                                        .removeCard(card.id);
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Delete',
                                                      style: TextStyle(
                                                          color: Colors.red)),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: card.gradientColors,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              card.bank,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              card.cardType,
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.8),
                                                fontSize: 14,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          card.icon,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 40),
                                  const Text(
                                    '•••• •••• •••• 1234',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Chat Messages Section - Flexible height
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Chat header with history button
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.support_agent,
                                    size: 20,
                                    color: Colors.blue[600],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'CardSense AI',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: Colors.green[400],
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Personalized AI',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.green[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const ServiceStatusIndicator(),
                                if (kDebugMode) ...[
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.bug_report,
                                        color: Colors.orange, size: 18),
                                    onPressed: () async {
                                      await _showContextDebugDialog(
                                          context, ref);
                                    },
                                    tooltip: 'Debug Context Issues',
                                    padding: const EdgeInsets.all(4),
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                  ),
                                ],
                                IconButton(
                                  icon: const Icon(Icons.history, size: 18),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ChatHistoryScreen(),
                                      ),
                                    );
                                  },
                                  tooltip: 'Chat History',
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_comment_outlined,
                                      size: 18),
                                  onPressed: () async {
                                    final chatNotifier = ref.read(
                                        persistentChatMessagesProvider
                                            .notifier);
                                    await chatNotifier.startNewConversation();
                                  },
                                  tooltip: 'New Chat',
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Consumer(
                      builder: (context, ref, child) {
                        final messages =
                            ref.watch(persistentChatMessagesProvider);

                        if (messages.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            return _ChatBubble(message: message);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Chat Input
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Ask about your credit cards...',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Consumer(
                    builder: (context, ref, child) {
                      final isListening = ref.watch(isListeningProvider);
                      final speechText = ref.watch(speechTextProvider);
                      final speechState = ref.watch(speechStateProvider);

                      // Update text field with speech text
                      if (speechText.isNotEmpty &&
                          _messageController.text != speechText) {
                        _messageController.text = speechText;
                      }

                      return SizedBox(
                        width: 44,
                        height: 44,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Ripple effect when listening
                            if (isListening)
                              AnimatedBuilder(
                                animation: _rippleController,
                                builder: (context, child) {
                                  return Container(
                                    width: 40 + (_rippleController.value * 16),
                                    height: 40 + (_rippleController.value * 16),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red.withOpacity(
                                          0.3 * (1 - _rippleController.value)),
                                    ),
                                  );
                                },
                              ),

                            // Sound level indicator
                            if (isListening)
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.red.withOpacity(0.5),
                                    width: 1 + (speechState.soundLevel / 20),
                                  ),
                                ),
                              ),

                            // Mic button
                            IconButton(
                              onPressed: () async {
                                final speechNotifier =
                                    ref.read(speechStateProvider.notifier);
                                if (isListening) {
                                  await speechNotifier.stopListening();
                                  // Send the message if we have text
                                  if (speechText.isNotEmpty) {
                                    _sendMessage();
                                    speechNotifier.clearText();
                                  }
                                } else {
                                  try {
                                    await speechNotifier.startListening();
                                  } catch (e) {
                                    // Show error message
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text('Error: ${e.toString()}'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                              icon: Icon(
                                isListening ? Icons.mic : Icons.mic_none,
                                size: 20,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor:
                                    isListening ? Colors.red : Colors.grey[100],
                                foregroundColor: isListening
                                    ? Colors.white
                                    : Colors.grey[700],
                                padding: const EdgeInsets.all(8),
                                minimumSize: const Size(44, 44),
                                maximumSize: const Size(44, 44),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(Icons.send_rounded, size: 20),
                      style: IconButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                      ),
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

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    // Use the persistent chat notifier
    final chatNotifier = ref.read(persistentChatMessagesProvider.notifier);

    // Send message with persistence
    await chatNotifier.sendMessage(message);

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    // Scroll to bottom again after AI response
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  /// 🔍 DEBUG: Show conversation context debug dialog
  Future<void> _showContextDebugDialog(
      BuildContext context, WidgetRef ref) async {
    final ragService = ref.read(ragChatServiceProvider);
    final messages = ref.read(persistentChatMessagesProvider);

    // Test RAG API configuration
    Map<String, dynamic> ragTest = {};
    try {
      ragTest = await ragService.testConnectionDetailed();
    } catch (e) {
      ragTest = {'error': e.toString()};
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔍 Context Debug Info'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('📊 Current Conversation:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue[800])),
              Text('• Messages in conversation: ${messages.length}'),
              Text(
                  '• Last message: ${messages.isNotEmpty ? (messages.last.isUser ? 'USER' : 'AI') : 'None'}'),
              const SizedBox(height: 16),
              Text('🔧 RAG API Configuration:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.green[800])),
              Text('• API Version: ${ragTest['api_version'] ?? 'Unknown'}'),
              Text('• Endpoint: ${ragTest['endpoint'] ?? 'Unknown'}'),
              Text(
                  '• Network Test: ${ragTest['network_test'] == true ? '✅ Pass' : '❌ Fail'}'),
              Text(
                  '• CORS Test: ${ragTest['cors_test'] == true ? '✅ Pass' : '❌ Fail'}'),
              if (ragTest['response_time_ms'] != null)
                Text('• Response Time: ${ragTest['response_time_ms']}ms'),
              const SizedBox(height: 16),
              Text('⚠️ Context Issue Diagnosis:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.orange[800])),
              Text(ragTest['api_version'] == 'new'
                  ? '🚨 NEW API: Context should now be included with latest fix!'
                  : '✅ OLD API: Conversation history is always included'),
              if (ragTest['error'] != null) ...[
                const SizedBox(height: 8),
                Text('Error: ${ragTest['error']}',
                    style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to RAG test screen for detailed testing
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RagTestScreen()),
              );
            },
            child: const Text('Open RAG Test'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _rippleController.dispose();
    super.dispose();
  }
}

class _CreditCard extends StatelessWidget {
  final String cardName;
  final String cardDescription;
  final LinearGradient gradient;
  final IconData icon;

  const _CreditCard({
    required this.cardName,
    required this.cardDescription,
    required this.gradient,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cardName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cardDescription,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Text(
            '•••• •••• •••• 1234',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue[100],
              child: Icon(
                Icons.support_agent,
                size: 18,
                color: Colors.blue[600],
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.blue[500] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message.message,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (message.isUser) const SizedBox(width: 40),
        ],
      ),
    );
  }
}
