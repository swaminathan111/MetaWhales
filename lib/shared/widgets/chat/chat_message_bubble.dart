import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../../features/chat/services/openrouter_service.dart';

/// Reusable chat message bubble widget with micro-interactions
class ChatMessageBubble extends StatefulWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
  });

  final ChatMessage message;

  @override
  State<ChatMessageBubble> createState() => _ChatMessageBubbleState();
}

class _ChatMessageBubbleState extends State<ChatMessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: widget.message.isUser ? 200 : 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: widget.message.isUser 
          ? const Offset(0.3, 0) 
          : const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Start animation with delay for assistant messages
    if (widget.message.isUser) {
      _animationController.forward();
    } else {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _animationController.forward();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Align(
                alignment: widget.message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: theme.spacing.md,
                    vertical: theme.spacing.md - theme.spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: widget.message.isUser 
                        ? theme.colorScheme.primary 
                        : theme.colorScheme.surfaceContainerHigh,
                    borderRadius: theme.borderRadius.card,
                    boxShadow: [
                      BoxShadow(
                        color: (widget.message.isUser 
                            ? theme.colorScheme.primary 
                            : Colors.grey).withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.message.message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: widget.message.isUser 
                          ? theme.colorScheme.onPrimary 
                          : theme.colorScheme.onSurface,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
