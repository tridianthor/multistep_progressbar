import 'package:flutter/foundation.dart';

import '../models/step.dart';

/// Controls the state and navigation of a multistep progress bar.
///
/// The controller manages a list of [ProgressStep]s and tracks the currently
/// active step. It extends [ChangeNotifier] so widgets can listen for changes
/// via `ListenableBuilder` or `AnimatedBuilder`.
///
/// ```dart
/// final controller = MultistepProgressController(
///   totalSteps: [
///     ProgressStep(stepName: 'Account'),
///     ProgressStep(stepName: 'Payment'),
///     ProgressStep(stepName: 'Confirm'),
///   ],
/// );
///
/// controller.nextStep();
/// print(controller.currentStep.stepName); // 'Payment'
/// ```
class MultistepProgressController extends ChangeNotifier {
  /// Creates a controller with the given [totalSteps] and an optional
  /// [initialIndex] (defaults to `0`).
  ///
  /// Each step's [ProgressStep.stepIndex] is automatically assigned based on
  /// its position in the list.
  ///
  /// Throws an [AssertionError] if [totalSteps] is empty or [initialIndex]
  /// is out of bounds.
  MultistepProgressController({
    required List<ProgressStep> totalSteps,
    int initialIndex = 0,
  })  : assert(totalSteps.isNotEmpty, 'totalSteps must not be empty'),
        assert(
          initialIndex >= 0 && initialIndex < totalSteps.length,
          'initialIndex must be within bounds of totalSteps',
        ),
        _totalSteps = List.unmodifiable(totalSteps),
        _currentStepIndex = initialIndex {
    // Assign derived stepIndex to each step.
    for (var i = 0; i < _totalSteps.length; i++) {
      _totalSteps[i].stepIndex = i;
    }
    _currentStepNotifier = ValueNotifier<ProgressStep>(_totalSteps[_currentStepIndex]);
  }

  final List<ProgressStep> _totalSteps;
  int _currentStepIndex;
  late final ValueNotifier<ProgressStep> _currentStepNotifier;

  /// The ordered list of all steps managed by this controller.
  List<ProgressStep> get totalSteps => _totalSteps;

  /// The currently active step.
  ProgressStep get currentStep => _totalSteps[_currentStepIndex];

  /// The zero-based index of the currently active step.
  int get currentStepIndex => _currentStepIndex;

  /// A [ValueListenable] for the current step, enabling surgical rebuilds
  /// via `ValueListenableBuilder`.
  ValueListenable<ProgressStep> get currentStepListenable => _currentStepNotifier;

  /// Advances to the next step.
  ///
  /// No-op if already on the last step.
  void nextStep() {
    if (_currentStepIndex < _totalSteps.length - 1) {
      _goToStep(_currentStepIndex + 1);
    }
  }

  /// Moves back to the previous step.
  ///
  /// No-op if already on the first step.
  void previousStep() {
    if (_currentStepIndex > 0) {
      _goToStep(_currentStepIndex - 1);
    }
  }

  /// Resets the progress bar to the first step.
  void resetProgress() {
    _goToStep(0);
  }

  /// Advances directly to the last step.
  void pushToLastStep() {
    _goToStep(_totalSteps.length - 1);
  }

  /// Navigates directly to the step at [index].
  ///
  /// No-op if [index] is out of bounds or equals the current index.
  void jumpToStep(int index) {
    if (index >= 0 && index < _totalSteps.length) {
      _goToStep(index);
    }
  }

  /// Internal navigation helper. Updates state and notifies listeners.
  void _goToStep(int newIndex) {
    if (newIndex == _currentStepIndex) return;
    _currentStepIndex = newIndex;
    _currentStepNotifier.value = currentStep;
    notifyListeners();
  }

  @override
  void dispose() {
    _currentStepNotifier.dispose();
    super.dispose();
  }
}
