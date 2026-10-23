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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 5,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: Text(title, style: theme.textTheme.headlineLarge)),
            if (action != null) action!,
          ],
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
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
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: scheme.secondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSecondaryContainer,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
