# Changelog

## 0.1.0

- Initial release
- `ProgressStep` model with derived `stepIndex`, `copyWith`, and value equality
- `MultistepProgressController` extending `ChangeNotifier` with navigation functions (`nextStep`, `previousStep`, `resetProgress`, `pushToLastStep`, `jumpToStep`)
- `ValueListenable<ProgressStep>` for surgical rebuilds
- `MultistepProgressBar` widget with default rendering (filled/outlined circles, checkmarks, connectors)
- Horizontal and vertical orientation via `direction` parameter
- Animated step transitions with configurable `animationDuration` and `animationCurve`
- Custom builders: `activeStepBuilder`, `completedStepBuilder`, `stepBuilders`
- Accessibility semantics on each step indicator
- Example app demonstrating all features
- Zero external dependencies beyond the Flutter SDK
