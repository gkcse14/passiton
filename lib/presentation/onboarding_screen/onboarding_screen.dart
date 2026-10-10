import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/journey_models.dart';
import '../../routes/app_routes.dart';
import '../../widgets/page_layout.dart';
import 'widgets/object_artwork_widget.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _busy = false;
  Future<void> _start() async {
    setState(() => _busy = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_seen', true);
      if (mounted) context.go(AppRoutes.journeysScreen);
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Couldn’t save your preference. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: PageFrame(
          maxWidth: 960,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.all_inclusive_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Text('pass it on', style: theme.textTheme.titleLarge),
                  ],
                ),
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    children: [
                      const ObjectShowcase(type: ObjectType.potato, size: 180),
                      const SizedBox(height: 16),
                      Text(
                        'Small things.\nBig stories.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displayLarge,
                      ),
                      const SizedBox(height: 16),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: Text(
                          'Give a little object a mission. Add a kind moment. See where its story goes.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                for (final step in [
                  (
                    Icons.explore_outlined,
                    'Find your traveller',
                    'Explore a journey or create your own.',
                  ),
                  (
                    Icons.edit_note_rounded,
                    'Add your chapter',
                    'Leave a note and become part of the story.',
                  ),
                  (
                    Icons.favorite_outline_rounded,
                    'Keep the kindness going',
                    'Save a favourite, leave a gift, or pass it on.',
                  ),
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Icon(
                            step.$1,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(step.$2, style: theme.textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text(step.$3, style: theme.textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _busy ? null : _start,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(_busy ? 'Opening…' : 'Let’s explore'),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'A local preview, made for a little curiosity.\nYour activity is saved on this device.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
