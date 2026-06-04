import 'package:flutter_test/flutter_test.dart';
import 'package:multistep_progressbar/multistep_progressbar.dart';

List<ProgressStep> _makeSteps(int count) => List.generate(
      count,
      (i) => ProgressStep(stepName: 'Step $i'),
    );

void main() {
  group('MultistepProgressController', () {
    group('construction', () {
      test('initial step defaults to index 0', () {
        final controller = MultistepProgressController(
          totalSteps: _makeSteps(3),
        );
        expect(controller.currentStepIndex, 0);
        expect(controller.currentStep.stepName, 'Step 0');
        controller.dispose();
      });

      test('respects custom initialIndex', () {
        final controller = MultistepProgressController(
          totalSteps: _makeSteps(3),
          initialIndex: 2,
        );
        expect(controller.currentStepIndex, 2);
        expect(controller.currentStep.stepName, 'Step 2');
        controller.dispose();
      });

      test('assigns stepIndex to each step by position', () {
        final controller = MultistepProgressController(
          totalSteps: _makeSteps(4),
        );
        for (var i = 0; i < 4; i++) {
          expect(controller.totalSteps[i].stepIndex, i);
        }
        controller.dispose();
      });

      test('totalSteps is unmodifiable', () {
        final controller = MultistepProgressController(
          totalSteps: _makeSteps(3),
        );
        expect(
          () => (controller.totalSteps as dynamic).add(ProgressStep(stepName: 'X')),
          throwsUnsupportedError,
        );
        controller.dispose();
      });

      test('asserts on empty totalSteps', () {
        expect(
          () => MultistepProgressController(totalSteps: []),
          throwsAssertionError,
        );
      });

      test('asserts on out-of-bounds initialIndex', () {
        expect(
          () => MultistepProgressController(
            totalSteps: _makeSteps(3),
            initialIndex: 5,
          ),
          throwsAssertionError,
        );
      });

      test('asserts on negative initialIndex', () {
        expect(
          () => MultistepProgressController(
            totalSteps: _makeSteps(3),
            initialIndex: -1,
          ),
          throwsAssertionError,
        );
      });
    });

    group('nextStep', () {
      test('advances to next step', () {
        final controller = MultistepProgressController(
          totalSteps: _makeSteps(3),
        );
        controller.nextStep();
        expect(controller.currentStepIndex, 1);
        controller.dispose();
      });

      test('is no-op on last step', () {
        final controller = MultistepProgressController(
          totalSteps: _makeSteps(3),
          initialIndex: 2,
        );
        controller.nextStep();
        expect(controller.currentStepIndex, 2);
        controller.dispose();
      });

      test('notifies listeners', () {
        final controller = MultistepProgressController(
          totalSteps: _makeSteps(3),
        );
        var notified = false;
        controller.addListener(() => notified = true);
        controller.nextStep();
        expect(notified, isTrue);
        controller.dispose();
      });

      test('does not notify when already on last step', () {
        final controller = MultistepProgressController(
          totalSteps: _makeSteps(3),
          initialIndex: 2,
        );
        var notified = false;
        controller.addListener(() => notified = true);
        controller.nextStep();
        expect(notified, isFalse);
        controller.dispose();
      });
    });

    group('previousStep', () {
      test('moves back to previous step', () {
        final controller = MultistepProgressController(
          totalSteps: _makeSteps(3),
          initialIndex: 2,
        );
        controller.previousStep();
        expect(controller.currentStepIndex, 1);
        controller.dispose();
      });

      test('is no-op on first step', () {
        final controller = MultistepProgressController(
          totalSteps: _makeSteps(3),
        );
        controller.previousStep();
        expect(controller.currentStepIndex, 0);
        controller.dispose();
      });

      test('notifies listeners', () {
        final controller = MultistepProgressController(
          totalSteps: _makeSteps(3),
          initialIndex: 1,
        );
        var notified = false;
        controller.addListener(() => notified = true);
        controller.previousStep();
        expect(notified, isTrue);
        controller.dispose();
      });

      test('does not notify when already on first step', () {
        final controller = MultistepProgressController(
          totalSteps: _makeSteps(3),
        );
        var notified = false;
        controller.addListener(() => notified = true);
        controller.previousStep();
        expect(notified, isFalse);
        controller.dispose();
      });
    });

    group('resetProgress', () {
      test('resets to first step', () {
        final controller = MultistepProgressController(
          totalSteps: _makeSteps(3),
          initialIndex: 2,
        );
        controller.resetProgress();
        expect(controller.currentStepIndex, 0);
        controller.dispose();
      });

      test('notifies listeners', () {
        final controller = MultistepProgressController(
          totalSteps: _makeSteps(3),
          initialIndex: 2,
        );
        var notified = false;
        controller.addListener(() => notified = true);
        controller.resetProgress();
        expect(notified, isTrue);
        controller.dispose();
      });

      test('is no-op when already on first step', () {
        final controller = MultistepProgressController(
          totalSteps: _makeSteps(3),
        );
        var notified = false;
        controller.addListener(() => notified = true);
        controller.resetProgress();
        expect(notified, isFalse);
        controller.dispose();
      });
    });

    group('pushToLastStep', () {
      test('jumps to last step', () {
        final controller = MultistepProgressController(
          totalSteps: _makeSteps(4),
        );
        controller.pushToLastStep();
        expect(controller.currentStepIndex, 3);
        controller.dispose();
      });

      test('notifies listeners', () {
        final controller = MultistepProgressController(
          totalSteps: _makeSteps(3),
        );
        var notified = false;
        controller.addListener(() => notified = true);
        controller.pushToLastStep();
        expect(notified, isTrue);
        controller.dispose();
      });

      test('is no-op when already on last step', () {
        final controller = MultistepProgressController(
          totalSteps: _makeSteps(3),
          initialIndex: 2,
        );
        var notified = false;
        controller.addListener(() => notified = true);
        controller.pushToLastStep();
        expect(notified, isFalse);
        controller.dispose();
      });
    });

    group('jumpToStep', () {
      test('navigates to valid index', () {
        final controller = MultistepProgressController(
          totalSteps: _makeSteps(5),
        );
        controller.jumpToStep(3);
        expect(controller.currentStepIndex, 3);
        controller.dispose();
      });

      test('notifies listeners on valid jump', () {
        final controller = MultistepProgressController(
          totalSteps: _makeSteps(5),
        );
        var notified = false;
        controller.addListener(() => notified = true);
        controller.jumpToStep(3);
        expect(notified, isTrue);
        controller.dispose();
      });

      test('is no-op for negative index', () {
        final controller = MultistepProgressController(
          totalSteps: _makeSteps(3),
        );
        controller.jumpToStep(-1);
        expect(controller.currentStepIndex, 0);
        controller.dispose();
      });

      test('is no-op for out-of-bounds index', () {
        final controller = MultistepProgressController(
          totalSteps: _makeSteps(3),
        );
        controller.jumpToStep(10);
        expect(controller.currentStepIndex, 0);
        controller.dispose();
      });

      test('is no-op when jumping to current index', () {
        final controller = MultistepProgressController(
          totalSteps: _makeSteps(3),
          initialIndex: 1,
        );
        var notified = false;
        controller.addListener(() => notified = true);
        controller.jumpToStep(1);
        expect(notified, isFalse);
        controller.dispose();
      });
    });

    group('currentStepListenable', () {
      test('initial value matches currentStep', () {
        final controller = MultistepProgressController(
          totalSteps: _makeSteps(3),
        );
        expect(
          controller.currentStepListenable.value,
          equals(controller.currentStep),
        );
        controller.dispose();
      });

      test('updates when step changes', () {
        final controller = MultistepProgressController(
          totalSteps: _makeSteps(3),
        );
        controller.nextStep();
        expect(
          controller.currentStepListenable.value,
          equals(controller.currentStep),
        );
        controller.dispose();
      });

      test('notifies ValueListenable listeners on change', () {
        final controller = MultistepProgressController(
          totalSteps: _makeSteps(3),
        );
        ProgressStep? received;
        controller.currentStepListenable.addListener(() {
          received = controller.currentStepListenable.value;
        });
        controller.nextStep();
        expect(received?.stepName, 'Step 1');
        controller.dispose();
      });
    });

    group('dispose', () {
      test('can be disposed without error', () {
        final controller = MultistepProgressController(
          totalSteps: _makeSteps(3),
        );
        expect(() => controller.dispose(), returnsNormally);
      });
    });
  });
}
