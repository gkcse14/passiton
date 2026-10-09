import 'package:flutter/material.dart';
import '../../../core/models/journey_models.dart';
import '../../../core/repositories/journey_repository.dart';
import '../../onboarding_screen/widgets/object_artwork_widget.dart';
import '../../journeys_screen/widgets/journey_discovery_widgets.dart';

class JoinJourneySheet extends StatefulWidget {
  final JourneyObject journey;
  const JoinJourneySheet({required this.journey, super.key});
  @override
  State<JoinJourneySheet> createState() => _JoinJourneySheetState();
}

class _JoinJourneySheetState extends State<JoinJourneySheet> {
  final _note = TextEditingController();
  bool _saving = false;
  bool _joined = false;
  String? _error;
  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await JourneyRepository.instance.join(
        widget.journey.id,
        message: _note.text,
      );
      if (mounted) setState(() => _joined = true);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Couldn’t add your chapter. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = JourneyColors(context);
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            12,
            24,
            MediaQuery.viewInsetsOf(context).bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: c.line,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 18),
              ObjectShowcase(type: widget.journey.type, size: 128),
              const SizedBox(height: 10),
              Text(
                _joined ? 'You’re part of the story.' : 'A new chapter. Yours.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: c.ink,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.6,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _joined
                    ? 'Your note is on ${widget.journey.name}’s timeline.'
                    : 'Leave a little kindness for ${widget.journey.name}.',
                textAlign: TextAlign.center,
                style: TextStyle(color: c.muted, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 20),
              if (!_joined) ...[
                TextField(
                  controller: _note,
                  enabled: !_saving,
                  maxLength: 160,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Your note (optional)',
                    hintText: 'Hope your next stop is somewhere wonderful…',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.journey.isSampleData
                      ? 'This is a preview journey. Your chapter is saved on this device.'
                      : 'Your chapter is saved on this device. Your location stays hidden.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: c.muted, fontSize: 11),
                ),
              ],
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: JourneyColors.green,
                    padding: const EdgeInsets.all(17),
                  ),
                  onPressed: _saving
                      ? null
                      : _joined
                      ? () => Navigator.pop(context)
                      : _join,
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_joined ? 'See my chapter' : 'Join the journey'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
