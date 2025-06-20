import 'package:flutter/material.dart';
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
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: UserAvatar(
            size: 40,
            showBorder: true,
            borderColor: Colors.blue,
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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Credit Cards Section
                  const SizedBox(height: 10),
                  Stack(
                    children: [
                      SizedBox(
                        height: 200,
                        child: Consumer(
                          builder: (context, ref, child) {
                            final cards = ref.watch(cardsProvider);
                            if (cards.isEmpty) {
                              return Center(
                                child: Text(
                                  'No cards added yet',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            }
                            return PageView.builder(
                              clipBehavior: Clip.none,
                              itemCount: cards.length + 1,
                              pageSnapping: true,
                              controller:
                                  PageController(viewportFraction: 0.85),
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
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.grey[300]!,
                                          width: 2,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 20),
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
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                            top:
                                                                Radius.circular(
                                                                    20)),
                                                  ),
                                                  builder: (context) =>
                                                      SizedBox(
                                                    height:
                                                        MediaQuery.of(context)
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
                                                  style: TextStyle(
                                                      color: Colors.red)),
                                              onTap: () {
                                                Navigator.pop(context);
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: const Text(
                                                        'Delete Card'),
                                                    content: Text(
                                                        'Are you sure you want to delete ${card.bank} ${card.cardType}?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        child: const Text(
                                                            'Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          ref
                                                              .read(
                                                                  cardsProvider
                                                                      .notifier)
                                                              .removeCard(
                                                                  card.id);
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: const Text(
                                                            'Delete',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .red)),
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
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    card.cardType,
                                                    style: TextStyle(
                                                      color: Colors.white
                                                          .withOpacity(0.8),
                                                      fontSize: 14,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.2),
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

                  const SizedBox(height: 30),

                  // Quick Actions
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: _QuickActionButton(
                  //         title: 'Check offer on your cards',
                  //         onTap: () {
                  //           ScaffoldMessenger.of(context).showSnackBar(
                  //             const SnackBar(
                  //                 content: Text('Checking offers...')),
                  //           );
                  //         },
                  //       ),
                  //     ),
                  //     const SizedBox(width: 12),
                  //     Expanded(
                  //       child: _QuickActionButton(
                  //         title: 'Check your card balance',
                  //         onTap: () {
                  //           ScaffoldMessenger.of(context).showSnackBar(
                  //             const SnackBar(
                  //                 content: Text('Checking balance...')),
                  //           );
                  //         },
                  //       ),
                  //     ),
                  //   ],
                  // ),

                  // Chat Messages
                  Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(13),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Chat header with history button
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Chat with CardSense AI',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () {
                                        // Show service status dialog
                                        final availability = ref.read(
                                            chatServiceAvailabilityProvider);
                                        availability.whenData((data) {
                                          showDialog(
                                            context: context,
                                            builder: (context) =>
                                                ServiceStatusDialog(
                                              availability: data,
                                            ),
                                          );
                                        });
                                      },
                                      child: const ServiceStatusIndicator(),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.history),
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
                                    iconSize: 20,
                                  ),
                                  IconButton(
                                    icon:
                                        const Icon(Icons.add_comment_outlined),
                                    onPressed: () async {
                                      final chatNotifier = ref.read(
                                          persistentChatMessagesProvider
                                              .notifier);
                                      await chatNotifier.startNewConversation();
                                    },
                                    tooltip: 'New Chat',
                                    iconSize: 20,
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
                  color: Colors.black.withAlpha(13),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
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

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Ripple effect when listening
                        if (isListening)
                          AnimatedBuilder(
                            animation: _rippleController,
                            builder: (context, child) {
                              return Container(
                                width: 48 + (_rippleController.value * 20),
                                height: 48 + (_rippleController.value * 20),
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
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.red.withOpacity(0.5),
                                width: 2 + (speechState.soundLevel / 10),
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          icon: Icon(
                            isListening ? Icons.mic : Icons.mic_none,
                            size: 28,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor:
                                isListening ? Colors.red : Colors.grey[100],
                            foregroundColor:
                                isListening ? Colors.white : Colors.grey[700],
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
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
