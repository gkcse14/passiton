import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/journey_models.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import './widgets/journey_preview_widget.dart';
import './widgets/journey_story_form_widget.dart';
import './widgets/object_picker_widget.dart';
import './widgets/step_indicator_widget.dart';

class CreateJourneyScreen extends StatefulWidget {
  const CreateJourneyScreen({super.key});

  @override
  State<CreateJourneyScreen> createState() => _CreateJourneyScreenState();
}

class _CreateJourneyScreenState extends State<CreateJourneyScreen>
    with SingleTickerProviderStateMixin {
  // TODO: Replace with Riverpod for production
  int _currentStep = 0;
  ObjectType? _selectedType;
  String _name = '';
  String _mission = '';
  String _openingNote = '';
  GoalType _goalType = GoalType.none;
  int? _goalTarget;
  LocationVisibility _originVisibility = LocationVisibility.city;
  String? _originCity;
  String? _originCountry;
  bool _isSubmitting = false;

  late AnimationController _stepAnimController;
  late Animation<double> _stepFadeAnim;

  @override
  void initState() {
    super.initState();
    _stepAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
    _stepFadeAnim = CurvedAnimation(
      parent: _stepAnimController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _stepAnimController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _stepAnimController.reset();
    _stepAnimController.forward();
  }

  bool get _canProceedStep0 => _selectedType != null;
  bool get _canProceedStep1 => _name.length >= 3 && _mission.length >= 5;

  void _handleContinue() {
    if (_currentStep == 0 && _canProceedStep0) {
      _goToStep(1);
    } else if (_currentStep == 1 && _canProceedStep1) {
      _goToStep(2);
    } else if (_currentStep == 2) {
      _submitJourney();
    }
  }

  Future<void> _submitJourney() async {
    if (_selectedType == null) return;
    setState(() => _isSubmitting = true);

    // Simulate local save
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    // Navigate to the journey detail of the new journey
    // In production: save to local storage and get real ID
    context.pop();
    context.push(AppRoutes.journeyDetailScreen, extra: 'journey-001');
  }

  void _handleBack() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    } else {
      _confirmDiscard();
    }
  }

  Future<void> _confirmDiscard() async {
    final hasData =
        _name.isNotEmpty || _mission.isNotEmpty || _selectedType != null;
    if (!hasData) {
      context.pop();
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard journey?'),
        content: const Text('Your draft will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Discard',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : AppTheme.backgroundLight,
      body: Column(
        children: [
          // Custom header
          Container(
            padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _handleBack,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.surfaceDark
                          : AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark
                            ? AppTheme.borderDark
                            : AppTheme.borderLight,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StepIndicatorWidget(
                    currentStep: _currentStep,
                    totalSteps: 3,
                  ),
                ),
                const SizedBox(width: 36),
              ],
            ),
          ),
          // Step content
          Expanded(
            child: FadeTransition(
              opacity: _stepFadeAnim,
              child: _buildStepContent(),
            ),
          ),
          // Bottom actions
          Container(
            padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPadding + 12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.backgroundDark
                  : AppTheme.backgroundLight,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _canProceed ? _handleContinue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme.borderLight,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _currentStep == 2 ? 'Start its journey' : 'Continue',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool get _canProceed {
    switch (_currentStep) {
      case 0:
        return _canProceedStep0;
      case 1:
        return _canProceedStep1;
      case 2:
        return true;
      default:
        return false;
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return ObjectPickerWidget(
          selectedType: _selectedType,
          onSelect: (type) => setState(() => _selectedType = type),
        );
      case 1:
        return JourneyStoryFormWidget(
          objectType: _selectedType!,
          name: _name,
          mission: _mission,
          openingNote: _openingNote,
          goalType: _goalType,
          goalTarget: _goalTarget,
          originVisibility: _originVisibility,
          originCity: _originCity,
          originCountry: _originCountry,
          onNameChanged: (v) => setState(() => _name = v),
          onMissionChanged: (v) => setState(() => _mission = v),
          onOpeningNoteChanged: (v) => setState(() => _openingNote = v),
          onGoalTypeChanged: (v) => setState(() => _goalType = v),
          onGoalTargetChanged: (v) => setState(() => _goalTarget = v),
          onOriginVisibilityChanged: (v) =>
              setState(() => _originVisibility = v),
          onOriginCityChanged: (v) => setState(() => _originCity = v),
          onOriginCountryChanged: (v) => setState(() => _originCountry = v),
        );
      case 2:
        return JourneyPreviewWidget(
          objectType: _selectedType!,
          name: _name,
          mission: _mission,
          openingNote: _openingNote,
          goalType: _goalType,
          goalTarget: _goalTarget,
          originVisibility: _originVisibility,
          originCity: _originCity,
          originCountry: _originCountry,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
