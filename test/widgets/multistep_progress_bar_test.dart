import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multistep_progressbar/multistep_progressbar.dart';

/// Wraps the widget under test in a minimal Material app.
Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}

MultistepProgressController _makeController(int count, {int initialIndex = 0}) {
  return MultistepProgressController(
    totalSteps: List.generate(count, (i) => ProgressStep(stepName: 'Step $i')),
    initialIndex: initialIndex,
  );
}

void main() {
  group('MultistepProgressBar', () {
    group('rendering', () {
      testWidgets('renders one Semantics node per step', (tester) async {
        final controller = _makeController(4);
        addTearDown(controller.dispose);

        await tester.pumpWidget(_wrap(
          MultistepProgressBar(controller: controller),
        ));

        // Each step is wrapped in a Semantics with a label.
        for (var i = 0; i < 4; i++) {
          expect(
            find.bySemanticsLabel(
              RegExp('Step ${i + 1} of 4: Step $i'),
            ),
            findsOneWidget,
          );
        }
      });

      testWidgets('renders in a Row for horizontal direction', (tester) async {
        final controller = _makeController(3);
        addTearDown(controller.dispose);

        await tester.pumpWidget(_wrap(
          MultistepProgressBar(controller: controller),
        ));

        expect(find.byType(Row), findsWidgets);
      });

      testWidgets('renders in a Column for vertical direction', (tester) async {
        final controller = _makeController(3);
        addTearDown(controller.dispose);

        await tester.pumpWidget(_wrap(
          MultistepProgressBar(
            controller: controller,
            direction: Axis.vertical,
          ),
        ));

        expect(find.byType(Column), findsWidgets);
      });

      testWidgets('renders default StepIndicator widgets', (tester) async {
        final controller = _makeController(3);
        addTearDown(controller.dispose);

        await tester.pumpWidget(_wrap(
          MultistepProgressBar(controller: controller),
        ));

        // 3 steps → 3 StepIndicator widgets
        expect(find.byType(StepIndicator), findsNWidgets(3));
      });

      testWidgets('renders connectors between steps', (tester) async {
        final controller = _makeController(3);
        addTearDown(controller.dispose);

        await tester.pumpWidget(_wrap(
          MultistepProgressBar(controller: controller),
        ));

        // 3 steps → 2 connectors
        expect(find.byType(StepConnector), findsNWidgets(2));
      });
    });

    group('custom builders', () {
      testWidgets('activeStepBuilder is used for active step', (tester) async {
        final controller = _makeController(3);
        addTearDown(controller.dispose);

        await tester.pumpWidget(_wrap(
          MultistepProgressBar(
            controller: controller,
            activeStepBuilder: (_, step) =>
                Text('ACTIVE:${step.stepName}', key: const Key('active')),
          ),
        ));

        expect(find.text('ACTIVE:Step 0'), findsOneWidget);
        // Non-active steps should use default
        expect(find.byType(StepIndicator), findsNWidgets(2));
      });

      testWidgets('completedStepBuilder is used for completed steps',
          (tester) async {
        final controller = _makeController(3, initialIndex: 2);
        addTearDown(controller.dispose);

        await tester.pumpWidget(_wrap(
          MultistepProgressBar(
            controller: controller,
            completedStepBuilder: (_, step) =>
                Text('DONE:${step.stepName}'),
          ),
        ));

        // Steps 0 and 1 are completed
        expect(find.text('DONE:Step 0'), findsOneWidget);
        expect(find.text('DONE:Step 1'), findsOneWidget);
      });

      testWidgets('stepBuilders override all other builders', (tester) async {
        final controller = _makeController(3);
        addTearDown(controller.dispose);

        await tester.pumpWidget(_wrap(
          MultistepProgressBar(
            controller: controller,
            stepBuilders: [
              (_, step) => Text('A:${step.stepName}'),
              (_, step) => Text('B:${step.stepName}'),
              (_, step) => Text('C:${step.stepName}'),
            ],
          ),
        ));

        expect(find.text('A:Step 0'), findsOneWidget);
        expect(find.text('B:Step 1'), findsOneWidget);
        expect(find.text('C:Step 2'), findsOneWidget);
        // No default StepIndicators
        expect(find.byType(StepIndicator), findsNothing);
      });
    });

    group('validation', () {
      testWidgets('asserts when stepBuilders length mismatches totalSteps',
          (tester) async {
        final controller = _makeController(3);
        addTearDown(controller.dispose);

        // The assertion fires during build; capture it via FlutterError.
        final errors = <FlutterErrorDetails>[];
        final originalHandler = FlutterError.onError;
        FlutterError.onError = errors.add;

        await tester.pumpWidget(_wrap(
          MultistepProgressBar(
            controller: controller,
            stepBuilders: [
              (_, step) => Text(step.stepName),
              // only 2 builders for 3 steps — intentional mismatch
              (_, step) => Text(step.stepName),
            ],
          ),
        ));

        FlutterError.onError = originalHandler;

        expect(
          errors.any((e) => e.exception is AssertionError),
          isTrue,
          reason: 'Expected an AssertionError for mismatched stepBuilders length',
        );
      });
    });

    group('onStepChange callback', () {
      testWidgets('fires with new step after nextStep', (tester) async {
        final controller = _makeController(3);
        addTearDown(controller.dispose);

        ProgressStep? received;
        await tester.pumpWidget(_wrap(
          MultistepProgressBar(
            controller: controller,
            onStepChange: (step) => received = step,
          ),
        ));

        controller.nextStep();
        await tester.pump();

        expect(received?.stepName, 'Step 1');
      });

      testWidgets('fires with new step after previousStep', (tester) async {
        final controller = _makeController(3, initialIndex: 2);
        addTearDown(controller.dispose);

        ProgressStep? received;
        await tester.pumpWidget(_wrap(
          MultistepProgressBar(
            controller: controller,
            onStepChange: (step) => received = step,
          ),
        ));

        controller.previousStep();
        await tester.pump();

        expect(received?.stepName, 'Step 1');
      });

      testWidgets('fires after resetProgress', (tester) async {
        final controller = _makeController(3, initialIndex: 2);
        addTearDown(controller.dispose);

        ProgressStep? received;
        await tester.pumpWidget(_wrap(
          MultistepProgressBar(
            controller: controller,
            onStepChange: (step) => received = step,
          ),
        ));

        controller.resetProgress();
        await tester.pump();

        expect(received?.stepName, 'Step 0');
      });

      testWidgets('fires after pushToLastStep', (tester) async {
        final controller = _makeController(3);
        addTearDown(controller.dispose);

        ProgressStep? received;
        await tester.pumpWidget(_wrap(
          MultistepProgressBar(
            controller: controller,
            onStepChange: (step) => received = step,
          ),
        ));

        controller.pushToLastStep();
        await tester.pump();

        expect(received?.stepName, 'Step 2');
      });

      testWidgets('fires after jumpToStep', (tester) async {
        final controller = _makeController(5);
        addTearDown(controller.dispose);

        ProgressStep? received;
        await tester.pumpWidget(_wrap(
          MultistepProgressBar(
            controller: controller,
            onStepChange: (step) => received = step,
          ),
        ));

        controller.jumpToStep(4);
        await tester.pump();

        expect(received?.stepName, 'Step 4');
      });
    });

    group('accessibility', () {
      testWidgets('each step has a Semantics widget with correct label',
          (tester) async {
        final controller = _makeController(3);
        addTearDown(controller.dispose);

        await tester.pumpWidget(_wrap(
          MultistepProgressBar(controller: controller),
        ));

        // Verify Semantics widgets exist in the tree for each step.
        // The widget wraps each indicator with a Semantics(label: ...) node.
        final semanticsWidgets = tester
            .widgetList<Semantics>(find.byType(Semantics))
            .toList();

        final labels = semanticsWidgets
            .map((s) => s.properties.label)
            .whereType<String>()
            .toList();

        expect(labels, contains('Step 1 of 3: Step 0'));
        expect(labels, contains('Step 2 of 3: Step 1'));
        expect(labels, contains('Step 3 of 3: Step 2'));
      });
    });

    group('animation', () {
      testWidgets('renders AnimatedSwitcher when duration is non-zero',
          (tester) async {
        final controller = _makeController(3);
        addTearDown(controller.dispose);

        await tester.pumpWidget(_wrap(
          MultistepProgressBar(
            controller: controller,
            animationDuration: const Duration(milliseconds: 300),
          ),
        ));

        expect(find.byType(AnimatedSwitcher), findsWidgets);
      });

      testWidgets('does not render AnimatedSwitcher when duration is zero',
          (tester) async {
        final controller = _makeController(3);
        addTearDown(controller.dispose);

        await tester.pumpWidget(_wrap(
          MultistepProgressBar(
            controller: controller,
            animationDuration: Duration.zero,
          ),
        ));

        expect(find.byType(AnimatedSwitcher), findsNothing);
      });
    });
  });
}
