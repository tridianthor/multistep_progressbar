import 'package:flutter/material.dart';
import 'package:multistep_progressbar/multistep_progressbar.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multistep Progressbar Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const ProgressBarDemo(),
    );
  }
}

class ProgressBarDemo extends StatefulWidget {
  const ProgressBarDemo({super.key});

  @override
  State<ProgressBarDemo> createState() => _ProgressBarDemoState();
}

class _ProgressBarDemoState extends State<ProgressBarDemo> {
  late final MultistepProgressController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MultistepProgressController(
      totalSteps: [
        ProgressStep(stepName: 'Account'),
        ProgressStep(stepName: 'Address'),
        ProgressStep(stepName: 'Payment'),
        ProgressStep(stepName: 'Review'),
        ProgressStep(stepName: 'Confirm'),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multistep Progressbar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- Horizontal progress bar ---
            MultistepProgressBar(
              controller: _controller,
              onStepChange: (step) {
                setState(() {});
              },
            ),
            const SizedBox(height: 48),

            // --- Current step info ---
            ValueListenableBuilder<ProgressStep>(
              valueListenable: _controller.currentStepListenable,
              builder: (context, step, _) {
                return Text(
                  'Current: ${step.stepName} (step ${step.stepIndex + 1} of ${_controller.totalSteps.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                );
              },
            ),
            const SizedBox(height: 48),

            // --- Navigation buttons ---
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: () => _controller.previousStep(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                ),
                FilledButton.icon(
                  onPressed: () => _controller.nextStep(),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _controller.resetProgress(),
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Reset'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _controller.pushToLastStep(),
                  icon: const Icon(Icons.last_page),
                  label: const Text('Last'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _controller.jumpToStep(2),
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Jump to 3'),
                ),
              ],
            ),
            const SizedBox(height: 48),

            // --- Vertical progress bar demo ---
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Vertical orientation',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: MultistepProgressBar(
                controller: _controller,
                direction: Axis.vertical,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
