import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class QuizScreen extends StatefulWidget {
  final String subject;
  final String topic;

  const QuizScreen({super.key, required this.subject, required this.topic});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  String? question;
  List<String> options = [];
  int correctIndex = -1;
  bool isLoading = true;
  String feedbackMessage = '';

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    final state = Provider.of<AppState>(context, listen: false);
    try {
      // CHANGE THIS LINE to pass both widget.subject and widget.topic
      String rawQuiz = await state.fetchQuiz(widget.subject, widget.topic);

      List<String> parts = rawQuiz.split('|');

      setState(() {
        question = parts[0];
        options = [parts[1], parts[2], parts[3], parts[4]];
        correctIndex = int.parse(parts[5]);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        feedbackMessage = "Error loading quiz. Please try again.";
        isLoading = false;
      });
    }
  }

  void _submitAnswer(int selectedIndex) {
    final state = Provider.of<AppState>(context, listen: false);

    if (selectedIndex == correctIndex) {
      setState(() => feedbackMessage = "Correct! +1 Mastery");
      // Send 1.0 (double) instead of 10
      state.updateMastery(widget.subject, widget.topic, 1.0);
    } else {
      setState(() => feedbackMessage = "Incorrect. -0.5 Mastery");
      // Send -0.5 (double) instead of -5
      state.updateMastery(widget.subject, widget.topic, -0.5);
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.topic} Quiz')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(question ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            ...List.generate(options.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: feedbackMessage.isEmpty ? () => _submitAnswer(index) : null,
                  child: Text(options[index], style: const TextStyle(fontSize: 16)),
                ),
              );
            }),
            const SizedBox(height: 24),
            if (feedbackMessage.isNotEmpty)
              Text(
                feedbackMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: feedbackMessage.contains('Correct') ? Colors.green : Colors.red
                ),
              )
          ],
        ),
      ),
    );
  }
}