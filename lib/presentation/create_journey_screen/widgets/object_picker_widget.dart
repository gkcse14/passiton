import 'package:flutter/material.dart';
import '../../../core/models/journey_models.dart';
import '../../../core/motion_notifier.dart';
import '../../onboarding_screen/widgets/object_artwork_widget.dart';

class ObjectPickerWidget extends StatelessWidget {
  final ObjectType? selectedType;
  final ValueChanged<ObjectType> onSelect;
  const ObjectPickerWidget({
    required this.selectedType,
    required this.onSelect,
    super.key,
  });
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
    children: [
      Text(
        'Choose your traveller',
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      const SizedBox(height: 8),
      const Text(
        'Every little object has a story to tell. Which one is yours?',
      ),
      const SizedBox(height: 24),
      LayoutBuilder(
        builder: (context, box) {
          final columns = box.maxWidth > 540 ? 3 : 2;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final type in ObjectType.values)
                SizedBox(
                  width: (box.maxWidth - (columns - 1) * 12) / columns,
                  child: Semantics(
                    selected: selectedType == type,
                    button: true,
                    child: Material(
                      color: selectedType == type
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: selectedType == type
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                          width: selectedType == type ? 2 : 1,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          selectionFeedback();
                          onSelect(type);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: Icon(
                                  selectedType == type
                                      ? Icons.check_circle_rounded
                                      : Icons.circle_outlined,
                                  size: 20,
                                  color: selectedType == type
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.outline,
                                ),
                              ),
                              ObjectArtworkWidget(type: type, size: 88),
                              const SizedBox(height: 12),
                              Text(
                                type.displayName,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                type.personality,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    ],
  );
}
