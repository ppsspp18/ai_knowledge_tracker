import 'package:flutter/material.dart';
import '../services/openrouter_service.dart';
import '../services/local_storage_service.dart';

class AppState extends ChangeNotifier {
  final OpenRouterService _aiService = OpenRouterService();
  final LocalStorageService _storage = LocalStorageService();

  Map<String, dynamic> userData = {};
  String currentMode = 'Tutor';
  List<Map<String, String>> chatHistory = [];
  bool isTyping = false;
  bool isInitializing = true;

  AppState() {
    _loadData();
  }

  Future<void> _loadData() async {
    userData = await _storage.loadUserData();
    isInitializing = false;
    notifyListeners();
  }

  // --- CHAT LOGIC (This was missing!) ---
  void setMode(String mode) {
    currentMode = mode;
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    chatHistory.add({'role': 'user', 'content': text});
    isTyping = true;
    notifyListeners();

    try {
      String aiResponse = await _aiService.generateResponse(text, currentMode);
      chatHistory.add({'role': 'ai', 'content': aiResponse});
    } catch (e) {
      chatHistory.add({'role': 'ai', 'content': 'Error details: $e'});
    } finally {
      isTyping = false;
      notifyListeners();
    }
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
}