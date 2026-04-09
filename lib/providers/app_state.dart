import 'package:flutter/material.dart';
import '../services/openrouter_service.dart';
import '../services/local_storage_service.dart';

class AppState extends ChangeNotifier {
  final OpenRouterService _aiService = OpenRouterService();
  final LocalStorageService _storage = LocalStorageService();

  List<Map<String, dynamic>> chatHistory = [];
  List<Map<String, dynamic>> archivedChats = [];

  Map<String, dynamic> userData = {};
  String currentMode = 'Tutor';
  bool isTyping = false;
  bool isInitializing = true;

  AppState() {
    _loadData();
  }

  // --- CHAT LOGIC (This was missing!) ---
  void setMode(String mode) {
    currentMode = mode;
    notifyListeners();
  }


  // --- ONBOARDING LOGIC ---
  Future<void> setLearningGoal(String goal) async {
    userData['goal'] = goal;
    userData['subjects'] = {
      goal: {
        "Foundations": 10.0, // Use decimals now
      }
    };
    await _storage.saveUserData(userData);
    notifyListeners();
  }

  // --- QUIZ LOGIC ---
  Future<void> updateMastery(String subject, String topic, double scoreChange) async {
    num currentScore = userData['subjects'][subject][topic] ?? 0;
    // Add change, clamp between 0 and 100, and ensure it's a double
    double newScore = (currentScore + scoreChange).clamp(0, 100).toDouble();

    userData['subjects'][subject][topic] = newScore;
    await _storage.saveUserData(userData);
    notifyListeners();
  }

  Future<String> fetchQuiz(String subject, String topic) async {
    return await _aiService.generateQuizQuestion(subject, topic);
  }

  // --- KNOWLEDGE MANAGEMENT LOGIC (CRUD) ---
  Future<void> addSubject(String subjectName) async {
    if (!userData['subjects'].containsKey(subjectName)) {
      // FIX: Automatically add a default topic so the Quiz/Progress UI appears immediately
      userData['subjects'][subjectName] = <String, dynamic>{
        "Foundations": 0.0
      };
      await _storage.saveUserData(userData);
      notifyListeners();
    }
  }

  Future<void> renameSubject(String oldName, String newName) async {
    if (userData['subjects'].containsKey(oldName) && !userData['subjects'].containsKey(newName)) {
      userData['subjects'][newName] = userData['subjects'].remove(oldName);
      await _storage.saveUserData(userData);
      notifyListeners();
    }
  }

  Future<void> deleteSubject(String subjectName) async {
    userData['subjects'].remove(subjectName);
    await _storage.saveUserData(userData);
    notifyListeners();
  }

  Future<void> addTopic(String subjectName, String topicName) async {
    if (userData['subjects'].containsKey(subjectName)) {
      userData['subjects'][subjectName][topicName] = 0.0; // Use decimal
      await _storage.saveUserData(userData);
      notifyListeners();
    }
  }

  Future<void> renameTopic(String subjectName, String oldTopic, String newTopic) async {
    if (userData['subjects'][subjectName].containsKey(oldTopic) &&
        !userData['subjects'][subjectName].containsKey(newTopic)) {
      userData['subjects'][subjectName][newTopic] = userData['subjects'][subjectName].remove(oldTopic);
      await _storage.saveUserData(userData);
      notifyListeners();
    }
  }

  Future<void> editTopicScore(String subjectName, String topicName, double newScore) async {
    if (userData['subjects'].containsKey(subjectName)) {
      userData['subjects'][subjectName][topicName] = newScore.clamp(0, 100);
      await _storage.saveUserData(userData);
      notifyListeners();
    }
  }

  Future<void> deleteTopic(String subjectName, String topicName) async {
    if (userData['subjects'].containsKey(subjectName)) {
      userData['subjects'][subjectName].remove(topicName);
      await _storage.saveUserData(userData);
      notifyListeners();
    }
  }

  Future<void> _loadData() async {
    userData = await _storage.loadUserData();

    // Load persistent chat history
    if (userData['current_chat'] != null) {
      chatHistory = List<Map<String, dynamic>>.from(userData['current_chat']);
    }
    if (userData['archived_chats'] != null) {
      archivedChats = List<Map<String, dynamic>>.from(userData['archived_chats']);
    }

    isInitializing = false;
    notifyListeners();
  }

  // --- ADD THESE NEW CHAT MANAGEMENT METHODS ---
  void _saveChatState() {
    userData['current_chat'] = chatHistory;
    userData['archived_chats'] = archivedChats;
    _storage.saveUserData(userData);
  }

  void startNewChat() {
    if (chatHistory.isNotEmpty) {
      // Save current chat to archives with a preview snippet
      archivedChats.insert(0, {
        'preview': chatHistory.first['content'],
        'messages': List.from(chatHistory),
      });
    }
    chatHistory.clear();
    _saveChatState();
    notifyListeners();
  }

  void loadArchivedChat(int index) {
    // Save the current chat before swapping
    if (chatHistory.isNotEmpty) {
      archivedChats.insert(0, {
        'preview': chatHistory.first['content'],
        'messages': List.from(chatHistory),
      });
    }
    // Swap the requested chat into the active view
    chatHistory = List<Map<String, dynamic>>.from(archivedChats[index]['messages']);
    archivedChats.removeAt(index);

    _saveChatState();
    notifyListeners();
  }

  // --- UPDATE YOUR sendMessage METHOD ---
  Future<void> sendMessage(String text) async {
    chatHistory.add({'role': 'user', 'content': text});
    isTyping = true;
    _saveChatState(); // Save immediately so it persists if app crashes
    notifyListeners();

    try {
      String aiResponse = await _aiService.generateResponse(text, currentMode);
      chatHistory.add({'role': 'ai', 'content': aiResponse});
      _saveChatState(); // Save final response
    } catch (e) {
      chatHistory.add({'role': 'ai', 'content': 'Error details: $e'});
    } finally {
      isTyping = false;
      notifyListeners();
    }
  }


  // --- UPDATED CHAT MANAGEMENT LOGIC ---

  // Renamed for clarity: saves the active chat into the list
  void saveCurrentChat() {
    if (chatHistory.isNotEmpty) {
      archivedChats.insert(0, {
        'preview': chatHistory.first['content'],
        'messages': List.from(chatHistory),
      });
      chatHistory.clear();
      _saveChatState();
      notifyListeners();
    }
  }

  // New Feature: Delete a specific chat from the list
  void deleteSavedChat(int index) {
    archivedChats.removeAt(index);
    _saveChatState();
    notifyListeners();
  }

  void loadSavedChat(int index) {
    // If current chat isn't empty, save it first so it isn't lost
    if (chatHistory.isNotEmpty) {
      archivedChats.insert(0, {
        'preview': chatHistory.first['content'],
        'messages': List.from(chatHistory),
      });
    }

    // Load the selected chat
    chatHistory = List<Map<String, dynamic>>.from(archivedChats[index]['messages']);
    archivedChats.removeAt(index); // Remove it from the list since it's now active

    _saveChatState();
    notifyListeners();
  }

}