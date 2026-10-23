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
    final scheme = theme.colorScheme;
    return Scaffold(
      body: SafeArea(
        child: PageFrame(
          maxWidth: 880,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.all_inclusive_rounded,
                        color: scheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('pass it on', style: theme.textTheme.titleLarge),
                  ],
                ),
                const SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 26),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        scheme.primaryContainer,
                        Color.alphaBlend(
                          const Color(0x66F6C56B),
                          scheme.primaryContainer,
                        ),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(36),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 190,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            ObjectShowcase(type: ObjectType.potato, size: 168),
                            Positioned(
                              top: 8,
                              right: 24,
                              child: ObjectArtworkWidget(
                                type: ObjectType.star,
                                size: 52,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 16,
                              child: ObjectArtworkWidget(
                                type: ObjectType.heart,
                                size: 58,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Small things.\nBig stories.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displayLarge,
                      ),
                      const SizedBox(height: 14),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Text(
                          'Give a little object a mission. Add a kind moment. See where its story goes.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                for (final step in [
                  (
                    '1',
                    Icons.explore_outlined,
                    'Find your traveller',
                    'Explore a journey or create your own.',
                  ),
                  (
                    '2',
                    Icons.edit_note_rounded,
                    'Add your chapter',
                    'Leave a note and become part of the story.',
                  ),
                  (
                    '3',
                    Icons.favorite_outline_rounded,
                    'Keep the kindness going',
                    'Save a favourite, leave a gift, or pass it on.',
                  ),
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: scheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                        side: BorderSide(color: scheme.outline),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: scheme.primaryContainer,
                              child: Text(
                                step.$1,
                                style: TextStyle(
                                  color: scheme.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    step.$3,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    step.$4,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(step.$2, color: scheme.primary),
                          ],
                        ),
                      ),
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
