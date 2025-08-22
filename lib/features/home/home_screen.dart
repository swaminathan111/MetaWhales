import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';
import '../auth/widgets/user_avatar.dart';
import '../auth/services/profile_service.dart';
import '../cards/models/card_info.dart';
import '../cards/providers/card_provider.dart';
import '../cards/screens/add_card_screen.dart';
import '../chat/services/chat_persistence_service.dart';
import '../chat/services/rag_chat_service.dart';
import '../chat/services/openrouter_service.dart';
import '../../shared/widgets/navigation/bottom_navigation_bar.dart';
import '../../shared/widgets/layout/gradient_header.dart';
import '../../shared/widgets/buttons/quick_action_chips.dart';
import '../../shared/widgets/buttons/cta_button_row.dart';
import '../../shared/widgets/cards/card_preview_tile.dart';
import '../../shared/widgets/cards/alert_promo_card.dart';
import '../../shared/widgets/chat/chat_message_bubble.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section with Gradient
            GradientHeader(
              userName: userName,
              insightText: 'Let\'s make every swipe the smartest move',
              onProfileTap: () => context.push('/profile'),
              onActionTap: () async {
                // Handle logout or manage cards action
                await ref.read(authProvider.notifier).signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
            
            // Main content area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chat input field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: const InputDecoration(
                                hintText: 'Ask me anything about your cards...',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 4),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.mic, color: Colors.grey),
                                  onPressed: () {
                                    // TODO: Implement voice input
                                  },
                                ),
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  child: IconButton(
                                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                                    onPressed: _sendMessage,
                                    style: IconButton.styleFrom(
                                      backgroundColor: Color(0xFF58d5d3),
                                      padding: const EdgeInsets.all(8),
                                      minimumSize: const Size(36, 36),
                                      maximumSize: const Size(36, 36),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Chat messages section
                    Consumer(
                      builder: (context, ref, child) {
                        final messages = ref.watch(persistentChatMessagesProvider);
                        
                        if (messages.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        
                        return Container(
                          height: 300,
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: ChatMessageBubble(message: message),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // CTA Button Row for AI response actions
                    Consumer(
                      builder: (context, ref, child) {
                        final messages = ref.watch(persistentChatMessagesProvider);
                        
                        // Only show CTA buttons if there are messages
                        if (messages.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        
                        return CTAButtonRow(
                          actions: [
                            CTAAction(id: 'ask_follow_up', title: 'Ask Follow-up', icon: Icons.chat),
                            CTAAction(id: 'get_recommendation', title: 'Get Recommendation', icon: Icons.recommend, isPrimary: true),
                            CTAAction(id: 'compare_options', title: 'Compare Options', icon: Icons.compare_arrows),
                            CTAAction(id: 'view_details', title: 'View Details', icon: Icons.visibility),
                          ],
                          onActionTap: (action) {
                            switch (action.id) {
                              case 'ask_follow_up':
                                // Focus on chat input for follow-up question
                                FocusScope.of(context).requestFocus(FocusNode());
                                break;
                              case 'get_recommendation':
                                _messageController.text = 'What card do you recommend for me?';
                                _sendMessage();
                                break;
                              case 'compare_options':
                                _messageController.text = 'Compare my card options';
                                _sendMessage();
                                break;
                              case 'view_details':
                                context.push('/cards');
                                break;
                            }
                          },
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Quick Action Chips
                    QuickActionChips(
                      actions: [
                        QuickAction(id: 'compare', title: 'Compare Cards', icon: Icons.compare_arrows),
                        QuickAction(id: 'plan', title: 'Plan Purchase', icon: Icons.shopping_cart),
                        QuickAction(id: 'travel', title: 'Travel Benefits', icon: Icons.flight),
                      ],
                      onActionTap: (action) {
                        switch (action) {
                          case 'compare':
                            // TODO: Navigate to compare cards
                            break;
                          case 'plan':
                            // TODO: Navigate to purchase planning
                            break;
                          case 'travel':
                            // TODO: Navigate to travel section
                            break;
                          case 'add_card':
                            context.push('/add-card');
                            break;
                        }
                      },
                    ),
                    
          
                    
                    const SizedBox(height: 24),
                    
                    // Alert and Promo Cards
                    AlertPromoCard(
                      type: AlertType.notification,
                      title: 'New lounge access update for Regalia',
                      message: 'Your card benefits have been updated with new airport lounge access.',
                      onTap: () {
                        // Navigate to card details or benefits screen
                        context.push('/cards');
                      },
                      onDismiss: () {
                        // Handle notification dismissal
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    AlertPromoCard(
                      type: AlertType.promoted,
                      title: 'Get 5% back on Amazon',
                      message: 'Use your ICICI Amazon Pay card for your next purchase to unlock this offer.',
                      onTap: () {
                        // Navigate to offer details or activate offer
                        context.push('/offers');
                      },
                      onDismiss: () {
                        // Handle promo dismissal
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Your Cards section
                    const Text(
                      'Your Cards',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Cards horizontal scroll
                    Consumer(
                      builder: (context, ref, child) {
                        final cards = ref.watch(cardsProvider);
                        return CardPreviewTile(
                          cards: cards,
                          onCardTap: (card) {
                            // Navigate to card details or manage cards
                            context.push('/manage-cards');
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: 0, // Home is always index 0
        onTap: _handleNavigationTap,
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

  void _handleNavigationTap(int index, String route) {
    // Navigate to the selected route
    if (route != '/') { // Don't navigate if already on home
      context.go(route);
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}





