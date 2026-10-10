import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/journey_models.dart';
import '../../../widgets/page_layout.dart';
import '../../onboarding_screen/widgets/object_artwork_widget.dart';

class PassItOnSheetWidget extends StatelessWidget {
  final JourneyObject journey;
  final List<JourneyStop> stops;
  const PassItOnSheetWidget({
    required this.journey,
    required this.stops,
    super.key,
  });
  String get _invitationText =>
      'Meet ${journey.name} ${journey.type.emoji}\n'
      'Its mission: ${journey.mission}\n'
      '${journey.isSampleData ? 'Explore this preview journey:' : 'Start your own little adventure with Pass It On:'}\n'
      'https://gkcse14.github.io/passiton/#/${journey.isSampleData ? 'journey-detail-screen?id=${Uri.encodeComponent(journey.id)}' : 'journeys-screen'}';
  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
    child: SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        MediaQuery.paddingOf(context).bottom + 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Pass a little kindness on',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              IconButton(
                tooltip: 'Close invitation',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              ObjectArtworkWidget(type: journey.type, size: 64),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  journey.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: SelectableText(
              _invitationText,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 16),
          InfoNotice(
            journey.isSampleData
                ? 'This invitation opens the preview journey for someone else to explore.'
                : 'This journey lives on your device. The invitation shares its mission and links to the app.',
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () async {
              try {
                await Clipboard.setData(ClipboardData(text: _invitationText));
                if (!context.mounted) return;
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Invitation copied. Ready to share.'),
                  ),
                );
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Couldn’t copy. Select the invitation text to copy it manually.',
                      ),
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.copy_rounded, size: 20),
            label: const Text('Copy invitation'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to the journey'),
          ),
        ],
      ),
    ),
  );
}
