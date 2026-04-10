import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _goalController = TextEditingController();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.rocket_launch, size: 80, color: Colors.blueGrey),
              const SizedBox(height: 24),
              const Text(
                "What do you want to master?",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _goalController,
                decoration: const InputDecoration(
                  labelText: 'Enter your primary learning goal',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  ActionChip(
                    label: const Text("Machine Learning"),
                    onPressed: () => _goalController.text = "Machine Learning",
                  ),
                  ActionChip(
                    label: const Text("SAS Programming"),
                    onPressed: () => _goalController.text = "C++ Programming",
                  ),
                  ActionChip(
                    label: const Text("Culvert Design"),
                    onPressed: () => _goalController.text = "Culvert Design",
                  ),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                onPressed: () {
                  if (_goalController.text.isNotEmpty) {
                    Provider.of<AppState>(context, listen: false)
                        .setLearningGoal(_goalController.text);
                  }
                },
                child: const Text('Start Tracking', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}