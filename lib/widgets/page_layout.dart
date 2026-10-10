import 'package:flutter/material.dart';

/// Keeps reading and interaction widths comfortable on tablets and the web.
class PageFrame extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const PageFrame({required this.child, this.maxWidth = 1120, super.key});
  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}

class PageHeading extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? action;
  const PageHeading({
    required this.title,
    required this.subtitle,
    this.action,
    super.key,
  });
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
          if (action != null) action!,
        ],
      ),
      const SizedBox(height: 8),
      Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    ],
  );
}

class InfoNotice extends StatelessWidget {
  final String message;
  final IconData icon;
  const InfoNotice(
    this.message, {
    this.icon = Icons.info_outline_rounded,
    super.key,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ],
    ),
  );
}
