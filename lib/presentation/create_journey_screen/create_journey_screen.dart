import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/page_layout.dart';

import '../../core/models/journey_models.dart';
import '../../core/repositories/journey_repository.dart';
import '../../core/services/nearby_journeys.dart';
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
  int _currentStep = 0;
  ObjectType? _selectedType;
  String _name = '';
  String _mission = '';
  String _openingNote = '';
  GoalType _goalType = GoalType.none;
  int? _goalTarget;
  LocationVisibility _originVisibility = LocationVisibility.hidden;
  String? _originCity;
  String? _originCountry;
  bool _isSubmitting = false;
  bool _allowPop = false;
  bool _confirmingDiscard = false;

  late AnimationController _stepAnimController;
  late Animation<double> _stepFadeAnim;

  @override
  void initState() {
    super.initState();
    _loadLocationPreference();
    _stepAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
    _stepFadeAnim = CurvedAnimation(
      parent: _stepAnimController,
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _loadLocationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted || _currentStep != 0) return;
    final value = prefs.getString('default_location');
    setState(
      () => _originVisibility = LocationVisibility.values.firstWhere(
        (v) => v.name == value,
        orElse: () => LocationVisibility.hidden,
      ),
    );
  }

  @override
  void dispose() {
    _stepAnimController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    if (MediaQuery.disableAnimationsOf(context)) {
      _stepAnimController.value = 1;
    } else {
      _stepAnimController.reset();
      _stepAnimController.forward();
    }
  }

  bool get _canProceedStep0 => _selectedType != null;
  bool get _canProceedStep1 =>
      _name.trim().length >= 3 &&
      _mission.trim().length >= 5 &&
      (_goalType == GoalType.none || (_goalTarget ?? 0) > 0) &&
      (_originVisibility == LocationVisibility.hidden ||
          (_originCountry?.trim().isNotEmpty ?? false)) &&
      (_originVisibility != LocationVisibility.city ||
          (_originCity?.trim().isNotEmpty ?? false));

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
    if (_selectedType == null || _isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final area = cityArea(_originCity, _originCountry);
      final journey = await JourneyRepository.instance.create(
        type: _selectedType!,
        name: _name,
        mission: _mission,
        openingNote: _openingNote,
        goalType: _goalType,
        goalTarget: _goalTarget,
        visibility: _originVisibility,
        city: _originCity,
        country: _originCountry,
        lat: area?.latitude,
        lng: area?.longitude,
      );
      if (!mounted) return;
      context.pushReplacement(
        '${AppRoutes.journeyDetailScreen}?id=${Uri.encodeComponent(journey.id)}',
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Couldn’t save your journey. Your draft is still here—please try again.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _handleBack() {
    if (_isSubmitting) return;
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    } else {
      _confirmDiscard();
    }
  }

  Future<void> _leave() async {
    setState(() => _allowPop = true);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.journeysScreen);
    }
  }

  Future<void> _confirmDiscard() async {
    if (_confirmingDiscard) return;
    final hasData =
        _name.isNotEmpty || _mission.isNotEmpty || _selectedType != null;
    if (!hasData) {
      await _leave();
      return;
    }
    _confirmingDiscard = true;
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
    _confirmingDiscard = false;
    if (confirm == true && mounted) await _leave();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final topPadding = MediaQuery.of(context).padding.top;

    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        backgroundColor: isDark
            ? AppTheme.backgroundDark
            : AppTheme.backgroundLight,
        body: PageFrame(
          maxWidth: 720,
          child: Column(
            children: [
              // Custom header
              Container(
                padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 12),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Back',
                      onPressed: _isSubmitting ? null : _handleBack,
                      icon: const Icon(Icons.arrow_back_rounded),
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
                      color: isDark
                          ? AppTheme.borderDark
                          : AppTheme.borderLight,
                    ),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _canProceed && !_isSubmitting
                        ? _handleContinue
                        : null,
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
                            _currentStep == 2
                                ? 'Start its journey'
                                : 'Continue',
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
        ),
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
