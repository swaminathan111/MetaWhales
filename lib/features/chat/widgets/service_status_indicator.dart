import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/rag_chat_service.dart';

class ServiceStatusIndicator extends ConsumerWidget {
  const ServiceStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceAvailability = ref.watch(chatServiceAvailabilityProvider);

    return serviceAvailability.when(
      data: (availability) {
        final ragAvailable = availability['rag'] ?? false;
        final fallbackAvailable = availability['openrouter'] ?? false;

        // Primary service indicator
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: ragAvailable ? Colors.green[50] : Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ragAvailable ? Colors.green[200]! : Colors.orange[200]!,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                ragAvailable ? Icons.psychology : Icons.backup,
                size: 14,
                color: ragAvailable ? Colors.green[600] : Colors.orange[600],
              ),
              const SizedBox(width: 4),
              Text(
                ragAvailable ? 'Personalized AI' : 'Basic AI',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: ragAvailable ? Colors.green[700] : Colors.orange[700],
                ),
              ),
              if (!ragAvailable && fallbackAvailable) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.info_outline,
                  size: 12,
                  color: Colors.orange[600],
                ),
              ],
            ],
          ),
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Checking...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
      error: (error, stackTrace) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red[200]!, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 14,
              color: Colors.red[600],
            ),
            const SizedBox(width: 4),
            Text(
              'AI Offline',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.red[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceStatusDialog extends StatelessWidget {
  final Map<String, bool> availability;

  const ServiceStatusDialog({
    super.key,
    required this.availability,
  });

  @override
  Widget build(BuildContext context) {
    final ragAvailable = availability['rag'] ?? false;
    final fallbackAvailable = availability['openrouter'] ?? false;

    return AlertDialog(
      title: const Text('AI Service Status'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ServiceStatusItem(
            name: 'Personalized AI (RAG)',
            description: 'Tailored responses based on your cards & preferences',
            isAvailable: ragAvailable,
            isPrimary: true,
          ),
          const SizedBox(height: 12),
          _ServiceStatusItem(
            name: 'Backup AI (OpenRouter)',
            description: 'General AI assistant',
            isAvailable: fallbackAvailable,
            isPrimary: false,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Mode:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ragAvailable
                      ? 'Personalized AI using your card portfolio and spending patterns'
                      : fallbackAvailable
                          ? 'Backup AI with general responses'
                          : 'No AI services available',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _ServiceStatusItem extends StatelessWidget {
  final String name;
  final String description;
  final bool isAvailable;
  final bool isPrimary;

  const _ServiceStatusItem({
    required this.name,
    required this.description,
    required this.isAvailable,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isAvailable ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  if (isPrimary) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'PRIMARY',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Icon(
          isAvailable ? Icons.check_circle : Icons.error,
          size: 20,
          color: isAvailable ? Colors.green : Colors.red,
        ),
      ],
    );
  }
}
