import 'package:flutter/material.dart';

class EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const EmptyStateCard({
    super.key,
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(message, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            TextButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
