import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../../features/chat/services/openrouter_service.dart';

/// Reusable chat message bubble widget
class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.md,
          vertical: theme.spacing.md - theme.spacing.xs,
        ),
        decoration: BoxDecoration(
          color: message.isUser 
              ? theme.colorScheme.primary 
              : theme.colorScheme.surfaceContainerHigh,
          borderRadius: theme.borderRadius.card,
        ),
        child: Text(
          message.message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: message.isUser 
                ? theme.colorScheme.onPrimary 
                : theme.colorScheme.onSurface,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
