import 'package:flutter_test/flutter_test.dart';
import 'package:multistep_progressbar/multistep_progressbar.dart';

void main() {
  group('ProgressStep', () {
    group('instantiation', () {
      test('creates with stepName', () {
        final step = ProgressStep(stepName: 'Payment');
        expect(step.stepName, 'Payment');
      });

      test('stepIndex defaults to 0', () {
        final step = ProgressStep(stepName: 'Payment');
        expect(step.stepIndex, 0);
      });

      test('stepIndex can be assigned', () {
        final step = ProgressStep(stepName: 'Payment');
        step.stepIndex = 3;
        expect(step.stepIndex, 3);
      });
    });

    group('copyWith', () {
      test('returns new instance with overridden stepName', () {
        final step = ProgressStep(stepName: 'Account');
        step.stepIndex = 1;

        final copy = step.copyWith(stepName: 'Shipping');

        expect(copy.stepName, 'Shipping');
        expect(copy.stepIndex, 1); // index preserved
      });

      test('returns new instance with same stepName when not overridden', () {
        final step = ProgressStep(stepName: 'Account');
        step.stepIndex = 2;

        final copy = step.copyWith();

        expect(copy.stepName, 'Account');
        expect(copy.stepIndex, 2);
      });

      test('copy is a different object', () {
        final step = ProgressStep(stepName: 'Account');
        final copy = step.copyWith();
        expect(identical(step, copy), isFalse);
      });
    });

    group('equality', () {
      test('equal when stepName and stepIndex match', () {
        final a = ProgressStep(stepName: 'Payment');
        a.stepIndex = 2;
        final b = ProgressStep(stepName: 'Payment');
        b.stepIndex = 2;

        expect(a, equals(b));
      });

      test('not equal when stepName differs', () {
        final a = ProgressStep(stepName: 'Payment');
        a.stepIndex = 2;
        final b = ProgressStep(stepName: 'Shipping');
        b.stepIndex = 2;

        expect(a, isNot(equals(b)));
      });

      test('not equal when stepIndex differs', () {
        final a = ProgressStep(stepName: 'Payment');
        a.stepIndex = 1;
        final b = ProgressStep(stepName: 'Payment');
        b.stepIndex = 2;

        expect(a, isNot(equals(b)));
      });

      test('identical instance equals itself', () {
        final step = ProgressStep(stepName: 'Payment');
        expect(step, equals(step));
      });

      test('not equal to non-ProgressStep object', () {
        final step = ProgressStep(stepName: 'Payment');
        // ignore: unrelated_type_equality_checks
        expect(step == 'Payment', isFalse);
      });
    });

    group('hashCode', () {
      test('equal objects have equal hashCodes', () {
        final a = ProgressStep(stepName: 'Payment');
        a.stepIndex = 2;
        final b = ProgressStep(stepName: 'Payment');
        b.stepIndex = 2;

        expect(a.hashCode, equals(b.hashCode));
      });

      test('different objects typically have different hashCodes', () {
        final a = ProgressStep(stepName: 'Payment');
        a.stepIndex = 1;
        final b = ProgressStep(stepName: 'Shipping');
        b.stepIndex = 2;

        expect(a.hashCode, isNot(equals(b.hashCode)));
      });
    });

    group('toString', () {
      test('includes stepName and stepIndex', () {
        final step = ProgressStep(stepName: 'Payment');
        step.stepIndex = 3;

        expect(step.toString(), contains('Payment'));
        expect(step.toString(), contains('3'));
      });
    });
  });
}
