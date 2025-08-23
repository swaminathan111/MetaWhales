import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'full_screen_chat_overlay.dart';

class ChatOverlayHelper {
  static final Logger _logger = Logger();
  
  static Future<void> showFullScreenChat(BuildContext context) async {
    try {
      _logger.d('ChatOverlayHelper: Attempting to show full screen chat');
      await Navigator.of(context).push(
        PageRouteBuilder(
          opaque: false,
          barrierDismissible: true,
          barrierColor: Colors.black.withOpacity(0.5),
          pageBuilder: (context, animation, secondaryAnimation) {
            _logger.d('ChatOverlayHelper: Creating FullScreenChatOverlay widget');
            return const FullScreenChatOverlay();
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
      _logger.d('ChatOverlayHelper: Dialog completed');
    } catch (e) {
      _logger.e('ChatOverlayHelper: Error showing chat overlay: $e');
      // Fallback to simple dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Chat'),
          content: Text('Error opening chat: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
