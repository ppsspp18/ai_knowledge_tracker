import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'quiz_screen.dart';
import 'byok_setup_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<void> _showInputDialog(BuildContext context, String title, String hint, Function(String) onSubmit, {String? initialValue, bool isNumber = false}) async {
    final TextEditingController controller = TextEditingController(text: initialValue);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(hintText: hint),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                onSubmit(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final subjects = state.userData['subjects'] as Map<String, dynamic>? ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Knowledge Tracker'),
        backgroundColor: Colors.blueGrey[50],
        // --- ADD THE ACTIONS ARRAY HERE ---
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'API Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BYOKSetupScreen(isSettingsMode: true),
                ),
              );
            },
          )
        ],
        // ----------------------------------
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showInputDialog(
            context, 'Add New Subject', 'e.g., Python Programming',
                (val) => state.addSubject(val)
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Subject'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: subjects.isEmpty
          ? const Center(child: Text("Set a goal in the chat or add a subject!", style: TextStyle(fontSize: 16)))
          : ListView.builder(
        padding: const EdgeInsets.all(16).copyWith(bottom: 80),
        itemCount: subjects.keys.length,
        itemBuilder: (context, index) {
          String subjectName = subjects.keys.elementAt(index);
          Map<String, dynamic> topics = subjects[subjectName];

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SUBJECT HEADER ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                            subjectName,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey)
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'add_topic') {
                            _showInputDialog(context, 'Add Topic to $subjectName', 'e.g., Variables', (val) => state.addTopic(subjectName, val));
                          } else if (value == 'rename') {
                            _showInputDialog(context, 'Rename Subject', 'New Name', (val) => state.renameSubject(subjectName, val), initialValue: subjectName);
                          } else if (value == 'delete') {
                            state.deleteSubject(subjectName);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'add_topic', child: Text('Add Topic')),
                          const PopupMenuItem(value: 'rename', child: Text('Rename Subject')),
                          const PopupMenuItem(value: 'delete', child: Text('Delete Subject', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),

                  // --- TOPIC LIST ---
                  ...topics.entries.map((topic) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Row(
                        children: [
                          // --- PROGRESS INFO ---
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(topic.key, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),

                                    // REPLACE the old percentage text with this dynamically formatted one:
                                    Text(
                                        '${(topic.value as num).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}%',
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    // Ensure we parse it as a double correctly
                                    value: (topic.value as num).toDouble() / 100,
                                    minHeight: 10,
                                    backgroundColor: Colors.grey[200],
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          // --- 1. EXPLICIT QUIZ BUTTON (Restored!) ---
                          ElevatedButton.icon(
                            icon: const Icon(Icons.psychology, size: 18),
                            label: const Text("Take Quiz"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => QuizScreen(
                                    subject: subjectName,
                                    topic: topic.key,
                                  ),
                                ),
                              );
                            },
                          ),

                          // --- 2. EDIT/DELETE TOPIC MENU ---
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'rename') {
                                _showInputDialog(context, 'Rename Topic', 'New Name', (val) => state.renameTopic(subjectName, topic.key, val), initialValue: topic.key);
                              } else if (value == 'edit_score') {
                                _showInputDialog(context, 'Edit Score (0-100)', 'e.g., 50', (val) => state.editTopicScore(subjectName, topic.key, double.tryParse(val) ?? 0), initialValue: topic.value.toString(), isNumber: true);
                              } else if (value == 'delete') {
                                state.deleteTopic(subjectName, topic.key);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'rename', child: Text('Rename Topic')),
                              const PopupMenuItem(value: 'edit_score', child: Text('Edit Score')),
                              const PopupMenuItem(value: 'delete', child: Text('Delete Topic', style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}