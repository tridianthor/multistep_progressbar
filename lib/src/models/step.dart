/// Represents a single step in a multistep progress bar.
///
/// A [ProgressStep] holds a human-readable [stepName] and a positional
/// [stepIndex] that is derived from its position in the controller's
/// `totalSteps` list (not user-supplied).
///
/// ```dart
/// final step = ProgressStep(stepName: 'Payment');
/// ```
class ProgressStep {
  /// Creates a [ProgressStep] with the given [stepName].
  ///
  /// The [stepIndex] is not set via the constructor — it is assigned
  /// internally by the controller based on list position.
  ProgressStep({required this.stepName});

  /// Human-readable label for this step.
  final String stepName;

  /// Positional index of this step within the controller's `totalSteps` list.
  ///
  /// This value is assigned by the controller and should not be set manually
  /// by consumers.
  int stepIndex = 0;

  /// Returns a copy of this step with optionally overridden fields.
  ///
  /// The copy retains the current [stepIndex].
  ///
  /// ```dart
  /// final updated = step.copyWith(stepName: 'Shipping');
  /// ```
  ProgressStep copyWith({String? stepName}) {
    final copy = ProgressStep(stepName: stepName ?? this.stepName);
    copy.stepIndex = stepIndex;
    return copy;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProgressStep &&
        other.stepName == stepName &&
        other.stepIndex == stepIndex;
  }

  @override
  int get hashCode => Object.hash(stepName, stepIndex);

  @override
  String toString() =>
      'ProgressStep(stepName: $stepName, stepIndex: $stepIndex)';
}
