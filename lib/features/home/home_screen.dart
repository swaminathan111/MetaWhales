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
import '../../shared/widgets/navigation/bottom_navigation_bar.dart';
import '../../shared/widgets/layout/gradient_header.dart';
import '../../shared/widgets/buttons/quick_action_chips.dart';
import '../../shared/widgets/buttons/cta_button_row.dart';
import '../../shared/widgets/cards/card_preview_tile.dart';
import '../../shared/widgets/cards/alert_promo_card.dart';
import '../chat/widgets/chat_overlay_helper.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {

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
                    
                    const SizedBox(height: 24),
                    
                    // CTA Button Row for AI assistance
                    CTAButtonRow(
                      actions: [
                        CTAAction(id: 'get_recommendation', title: 'Get Recommendation', icon: Icons.recommend, isPrimary: true),
                        CTAAction(id: 'ask_follow_up', title: 'Ask Follow-up', icon: Icons.chat),
                        CTAAction(id: 'compare_options', title: 'Compare Options', icon: Icons.compare_arrows),
                        CTAAction(id: 'view_details', title: 'View Details', icon: Icons.visibility),
                        CTAAction(id: 'plan_purchase', title: 'Plan a Purchase', icon: Icons.shopping_cart),
                        CTAAction(id: 'see_travel', title: 'See Travel', icon: Icons.flight),
                        CTAAction(id: 'add_card', title: 'Add Card', icon: Icons.add_card),
                      ],
                      onActionTap: (action) async {
                        String? predefinedMessage;
                        switch (action.id) {
                          case 'ask_follow_up':
                            // Open chat overlay without predefined message
                            break;
                          case 'get_recommendation':
                            predefinedMessage = 'What card do you recommend for me?';
                            break;
                          case 'compare_options':
                            predefinedMessage = 'Compare my card options';
                            break;
                          case 'plan_purchase':
                            predefinedMessage = 'Plan a purchase';
                            break;
                          case 'see_travel':
                            predefinedMessage = 'See travel';
                            break;
                          case 'add_card':
                            predefinedMessage = 'Add card';
                            break;
                          case 'view_details':
                            context.push('/cards');
                            return;
                        }
                        
                        // Open chat overlay with predefined message
                        await ChatOverlayHelper.showFullScreenChat(context, initialMessage: predefinedMessage);
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
        // Remove onCTATap override to use default chat overlay
      ),
    );
  }


  void _handleNavigationTap(int index, String route) {
    // Navigate to the selected route
    if (route != '/') { // Don't navigate if already on home
      context.go(route);
    }
  }

}
