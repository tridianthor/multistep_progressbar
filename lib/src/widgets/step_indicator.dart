import 'package:flutter/material.dart';

import '../models/step.dart';

/// The visual state of a step indicator.
enum ProgressStepState {
  /// The step has been completed (before the active step).
  completed,

  /// The step is currently active.
  active,

  /// The step has not yet been reached.
  upcoming,
}

/// Default visual indicator for a single step in the progress bar.
///
/// Renders differently based on [state]:
/// - [ProgressStepState.active]: Filled circle with the step index number.
/// - [ProgressStepState.completed]: Filled circle with a checkmark icon.
/// - [ProgressStepState.upcoming]: Outlined circle with the step index number.
///
/// This widget is used internally by [MultistepProgressBar] when no custom
/// builders are provided.
class StepIndicator extends StatelessWidget {
  /// Creates a [StepIndicator] for the given [step] and visual [state].
  const StepIndicator({
    super.key,
    required this.step,
    required this.state,
    this.size = 32.0,
  });

  /// The step this indicator represents.
  final ProgressStep step;

  /// The current visual state of this indicator.
  final ProgressStepState state;

  /// The diameter of the indicator circle.
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (state) {
      case ProgressStepState.active:
        return _buildCircle(
          fillColor: colorScheme.primary,
          borderColor: colorScheme.primary,
          child: Text(
            '${step.stepIndex + 1}',
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontSize: size * 0.4,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case ProgressStepState.completed:
        return _buildCircle(
          fillColor: colorScheme.primary,
          borderColor: colorScheme.primary,
          child: Icon(
            Icons.check,
            color: colorScheme.onPrimary,
            size: size * 0.5,
          ),
        );
      case ProgressStepState.upcoming:
        return _buildCircle(
          fillColor: Colors.transparent,
          borderColor: colorScheme.outline,
          child: Text(
            '${step.stepIndex + 1}',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: size * 0.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
    }
  }

  Widget _buildCircle({
    required Color fillColor,
    required Color borderColor,
    required Widget child,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: fillColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2.0),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

/// A connector line drawn between two step indicators.
///
/// Adapts its orientation based on [direction].
class StepConnector extends StatelessWidget {
  /// Creates a [StepConnector] with the given [direction] and optional
  /// [isCompleted] flag to indicate whether the segment is filled.
  const StepConnector({
    super.key,
    this.direction = Axis.horizontal,
    this.isCompleted = false,
    this.thickness = 2.0,
  });

  /// The axis along which the connector is drawn.
  final Axis direction;

  /// Whether this connector segment represents a completed transition.
  final bool isCompleted;

  /// The thickness of the connector line.
  final double thickness;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isCompleted ? colorScheme.primary : colorScheme.outlineVariant;

    if (direction == Axis.horizontal) {
      return Expanded(
        child: Container(
          height: thickness,
          color: color,
        ),
      );
    } else {
      return Expanded(
        child: Container(
          width: thickness,
          color: color,
        ),
      );
    }
  }
}
