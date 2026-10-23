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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
      children: [
        Text('Choose your traveller', style: theme.textTheme.headlineLarge),
        const SizedBox(height: 8),
        Text(
          'Tap the little object that feels like your story. You can name it next.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, box) {
            final columns = box.maxWidth > 540 ? 3 : 2;
            final gap = 12.0;
            final width = (box.maxWidth - (columns - 1) * gap) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final type in ObjectType.values)
                  SizedBox(
                    width: width,
                    child: Semantics(
                      selected: selectedType == type,
                      button: true,
                      child: Material(
                        color: selectedType == type
                            ? scheme.primaryContainer
                            : scheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: BorderSide(
                            color: selectedType == type
                                ? scheme.primary
                                : scheme.outline,
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
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
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
                                        ? scheme.primary
                                        : scheme.outline,
                                  ),
                                ),
                                ObjectArtworkWidget(
                                  type: type,
                                  size: width < 150 ? 72 : 88,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  type.displayName,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  type.personality,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall,
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
}
