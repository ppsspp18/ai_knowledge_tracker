import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // Add this import
import '../providers/app_state.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final TextEditingController controller = TextEditingController();
    final List<String> modes = ['Tutor', 'Mock Interviewer', 'Evaluator', 'Motivator'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Mentor'),
        backgroundColor: Colors.blueGrey[50],
      ),
      // --- ADD THE ARCHIVE DRAWER ---
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueGrey),
              child: Center(
                child: Text('Saved Conversations',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add_comment, color: Colors.blueGrey),
              title: const Text('New Conversation', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                state.saveCurrentChat(); // Automatically saves and clears
                Navigator.pop(context);
              },
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: state.archivedChats.length,
                itemBuilder: (context, index) {
                  final savedChat = state.archivedChats[index];
                  return ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(
                      savedChat['preview'] ?? 'Untitled Chat',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                    // --- THE DELETE BUTTON ---
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () {
                        // Show a quick confirmation or just delete
                        state.deleteSavedChat(index);
                      },
                    ),
                    onTap: () {
                      state.loadSavedChat(index);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // MODE SWITCHER
          Container(
            width: double.infinity,
            color: Colors.blueGrey[50],
            padding: const EdgeInsets.only(bottom: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: modes.map((mode) {
                  bool isSelected = state.currentMode == mode;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(mode),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) state.setMode(mode);
                      },
                      selectedColor: Colors.blueGrey,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1),

          // CHAT HISTORY
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.chatHistory.length,
              itemBuilder: (context, index) {
                final msg = state.chatHistory[index];
                bool isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blueGrey[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    // --- RENDER MARKDOWN INSTEAD OF PLAIN TEXT ---
                    child: MarkdownBody(
                      data: msg['content'] ?? '',
                      selectable: true, // Allows the user to copy text!
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(fontSize: 16),
                        code: const TextStyle(backgroundColor: Colors.black12, fontFamily: 'monospace'),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (state.isTyping) const LinearProgressIndicator(),

          // MESSAGE INPUT
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Discuss a topic or answer a prompt...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (val) {
                      if (val.isNotEmpty) {
                        state.sendMessage(val);
                        controller.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueGrey),
                  iconSize: 28,
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      state.sendMessage(controller.text);
                      controller.clear();
                    }
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}