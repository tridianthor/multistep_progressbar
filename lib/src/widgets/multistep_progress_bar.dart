import 'package:flutter/material.dart';

import '../controller/multistep_progress_controller.dart';
import '../models/step.dart';
import 'step_indicator.dart';

/// A customizable multistep progress bar widget driven by a
/// [MultistepProgressController].
///
/// Renders one indicator per step with connectors between them. Supports
/// horizontal and vertical orientation, animated transitions, custom builders,
/// and accessibility semantics.
///
/// ```dart
/// MultistepProgressBar(
///   controller: myController,
///   onStepChange: (step) => print('Now on: ${step.stepName}'),
/// )
/// ```
class MultistepProgressBar extends StatefulWidget {
  /// Creates a [MultistepProgressBar] driven by [controller].
  ///
  /// If [stepBuilders] is provided, its length **must** equal
  /// `controller.totalSteps.length`.
  const MultistepProgressBar({
    super.key,
    required this.controller,
    this.onStepChange,
    this.activeStepBuilder,
    this.completedStepBuilder,
    this.stepBuilders,
    this.direction = Axis.horizontal,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.indicatorSize = 32.0,
    this.connectorThickness = 2.0,
    this.spacing = 0.0,
  });

  /// The controller driving the progress bar state.
  final MultistepProgressController controller;

  /// Fires after the current step changes. Receives the new active step.
  final void Function(ProgressStep step)? onStepChange;

  /// Builder for the currently active step indicator.
  ///
  /// When `null`, a default filled circle with the step number is rendered.
  final Widget Function(BuildContext context, ProgressStep step)?
      activeStepBuilder;

  /// Builder for completed (past) step indicators.
  ///
  /// When `null`, a default filled circle with a checkmark is rendered.
  final Widget Function(BuildContext context, ProgressStep step)?
      completedStepBuilder;

  /// Per-step builders for individual step indicators.
  ///
  /// When provided, its length **must** equal `controller.totalSteps.length`.
  /// This overrides both [activeStepBuilder] and [completedStepBuilder].
  final List<Widget Function(BuildContext context, ProgressStep step)>?
      stepBuilders;

  /// Orientation of the progress bar.
  ///
  /// Defaults to [Axis.horizontal].
  final Axis direction;

  /// Duration of the transition animation between steps.
  ///
  /// Set to [Duration.zero] to disable animation.
  final Duration animationDuration;

  /// Curve applied to the step transition animation.
  final Curve animationCurve;

  /// The diameter of the default step indicator circles.
  final double indicatorSize;

  /// The thickness of connector lines between indicators.
  final double connectorThickness;

  /// Additional spacing between indicators and connectors.
  final double spacing;

  @override
  State<MultistepProgressBar> createState() => _MultistepProgressBarState();
}

class _MultistepProgressBarState extends State<MultistepProgressBar> {
  @override
  void initState() {
    super.initState();
    assert(
      widget.stepBuilders == null ||
          widget.stepBuilders!.length == widget.controller.totalSteps.length,
      'stepBuilders.length must equal controller.totalSteps.length',
    );
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant MultistepProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
    assert(
      widget.stepBuilders == null ||
          widget.stepBuilders!.length == widget.controller.totalSteps.length,
      'stepBuilders.length must equal controller.totalSteps.length',
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});
    widget.onStepChange?.call(widget.controller.currentStep);
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.controller.totalSteps;
    final currentIndex = widget.controller.currentStepIndex;
    final children = <Widget>[];

    for (var i = 0; i < steps.length; i++) {
      // Determine step state.
      final ProgressStepState state;
      if (i < currentIndex) {
        state = ProgressStepState.completed;
      } else if (i == currentIndex) {
        state = ProgressStepState.active;
      } else {
        state = ProgressStepState.upcoming;
      }

      // Build the indicator widget.
      Widget indicator = _buildIndicator(context, steps[i], state, i);

      // Wrap with animation.
      if (widget.animationDuration != Duration.zero) {
        indicator = AnimatedSwitcher(
          duration: widget.animationDuration,
          switchInCurve: widget.animationCurve,
          switchOutCurve: widget.animationCurve,
          child: KeyedSubtree(
            key: ValueKey<ProgressStepState>(state),
            child: indicator,
          ),
        );
      }

      // Wrap with semantics.
      indicator = Semantics(
        label: 'Step ${i + 1} of ${steps.length}: ${steps[i].stepName}',
        child: indicator,
      );

      children.add(indicator);

      // Add connector between steps (not after the last one).
      if (i < steps.length - 1) {
        if (widget.spacing > 0) {
          children.add(_buildSpacer());
        }
        children.add(
          StepConnector(
            direction: widget.direction,
            isCompleted: i < currentIndex,
            thickness: widget.connectorThickness,
          ),
        );
        if (widget.spacing > 0) {
          children.add(_buildSpacer());
        }
      }
    }

    if (widget.direction == Axis.horizontal) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      );
    }
  }

  /// Builds the indicator widget for a step, using custom builders if
  /// provided, otherwise falling back to the default [StepIndicator].
  Widget _buildIndicator(
    BuildContext context,
    ProgressStep step,
    ProgressStepState state,
    int index,
  ) {
    // Per-step builder takes highest priority.
    if (widget.stepBuilders != null) {
      return widget.stepBuilders![index](context, step);
    }

    // State-specific builders.
    if (state == ProgressStepState.active && widget.activeStepBuilder != null) {
      return widget.activeStepBuilder!(context, step);
    }
    if (state == ProgressStepState.completed && widget.completedStepBuilder != null) {
      return widget.completedStepBuilder!(context, step);
    }

    // Default rendering.
    return StepIndicator(
      step: step,
      state: state,
      size: widget.indicatorSize,
    );
  }

  Widget _buildSpacer() {
    if (widget.direction == Axis.horizontal) {
      return SizedBox(width: widget.spacing);
    } else {
      return SizedBox(height: widget.spacing);
    }
  }
}
