# multistep_progressbar

A Flutter package providing a customizable multistep progress bar widget with controller-driven navigation, animation, and accessibility support.

Works on Android, iOS, macOS, Linux, and Windows.

## Features

- Controller-based state management via `ChangeNotifier`
- Horizontal and vertical orientation
- Animated step transitions with configurable duration and curve
- Sensible default rendering (works out-of-the-box with no builders)
- Custom builders for active, completed, and per-step indicators
- `ValueListenable` for surgical rebuilds
- Accessibility semantics on every step indicator
- Zero external dependencies beyond the Flutter SDK

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  multistep_progressbar:
    git:
      url: https://github.com/user/multistep_progressbar.git
```

## Quick Start

```dart
import 'package:multistep_progressbar/multistep_progressbar.dart';

// 1. Define your steps
final controller = MultistepProgressController(
  totalSteps: [
    ProgressStep(stepName: 'Account'),
    ProgressStep(stepName: 'Payment'),
    ProgressStep(stepName: 'Confirm'),
  ],
);

// 2. Use the widget
MultistepProgressBar(
  controller: controller,
  onStepChange: (step) => print('Now on: ${step.stepName}'),
)
```

## Navigation

```dart
controller.nextStep();       // advance one step
controller.previousStep();   // go back one step
controller.resetProgress();  // jump to first step
controller.pushToLastStep(); // jump to last step
controller.jumpToStep(2);    // jump to specific index
```

## Custom Builders

Override the default indicators with your own widgets:

```dart
MultistepProgressBar(
  controller: controller,
  activeStepBuilder: (context, step) => CircleAvatar(
    backgroundColor: Colors.blue,
    child: Text('${step.stepIndex + 1}'),
  ),
  completedStepBuilder: (context, step) => const CircleAvatar(
    backgroundColor: Colors.green,
    child: Icon(Icons.done, color: Colors.white),
  ),
)
```

Or provide per-step builders for full control:

```dart
MultistepProgressBar(
  controller: controller,
  stepBuilders: [
    (context, step) => const Icon(Icons.person),
    (context, step) => const Icon(Icons.payment),
    (context, step) => const Icon(Icons.check_circle),
  ],
)
```

## Vertical Orientation

```dart
MultistepProgressBar(
  controller: controller,
  direction: Axis.vertical,
)
```

## ValueListenableBuilder

For surgical rebuilds without listening to the entire controller:

```dart
ValueListenableBuilder<ProgressStep>(
  valueListenable: controller.currentStepListenable,
  builder: (context, step, _) {
    return Text('Current: ${step.stepName}');
  },
)
```

## Animation

Transitions are animated by default (300ms, easeInOut). Customize or disable:

```dart
MultistepProgressBar(
  controller: controller,
  animationDuration: const Duration(milliseconds: 500),
  animationCurve: Curves.bounceOut,
)

// Disable animation
MultistepProgressBar(
  controller: controller,
  animationDuration: Duration.zero,
)
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `controller` | `MultistepProgressController` | required | Drives the progress bar state |
| `onStepChange` | `void Function(ProgressStep)?` | null | Callback after step changes |
| `activeStepBuilder` | `Widget Function(BuildContext, ProgressStep)?` | null | Custom active indicator |
| `completedStepBuilder` | `Widget Function(BuildContext, ProgressStep)?` | null | Custom completed indicator |
| `stepBuilders` | `List<Widget Function(BuildContext, ProgressStep)>?` | null | Per-step builders |
| `direction` | `Axis` | `Axis.horizontal` | Layout orientation |
| `animationDuration` | `Duration` | 300ms | Transition duration |
| `animationCurve` | `Curve` | `Curves.easeInOut` | Transition curve |
| `indicatorSize` | `double` | 32.0 | Default circle diameter |
| `connectorThickness` | `double` | 2.0 | Line thickness |
| `spacing` | `double` | 0.0 | Gap around connectors |

## Cleanup

Always dispose the controller when done:

```dart
@override
void dispose() {
  controller.dispose();
  super.dispose();
}
```

## Platform Support

| Platform | Supported |
|----------|-----------|
| Android | ✅ |
| iOS | ✅ |
| macOS | ✅ |
| Linux | ✅ |
| Windows | ✅ |

## License

See [LICENSE](LICENSE) for details.
