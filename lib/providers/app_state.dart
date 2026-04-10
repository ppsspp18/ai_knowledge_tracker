import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../services/secure_storage_service.dart';

class AppState extends ChangeNotifier {
  final ApiService _aiService = ApiService();
  final LocalStorageService _storage = LocalStorageService();
  final SecureStorageService _secureStorage = SecureStorageService();

  List<Map<String, dynamic>> chatHistory = [];
  List<Map<String, dynamic>> archivedChats = [];

  Map<String, dynamic> userData = {};

  // --- NEW BYOK PROPERTIES ---
  String? apiEndpoint;
  String? apiKey;
  String? selectedModel;
  bool isConfigured = false;

  String currentMode = 'Tutor';
  bool isTyping = false;
  bool isInitializing = true;

  AppState() {
    _loadData();
  }

  // --- BYOK SETUP LOGIC ---
  Future<void> saveApiConfiguration(String endpoint, String key, String model) async {
    await _secureStorage.saveCredentials(endpoint, key, model);
    apiEndpoint = endpoint;
    apiKey = key;
    selectedModel = model;
    isConfigured = true;
    notifyListeners();
  }

  // --- CHAT LOGIC ---
  void setMode(String mode) {
    currentMode = mode;
    notifyListeners();
  }

  // --- ONBOARDING LOGIC ---
  Future<void> setLearningGoal(String goal) async {
    userData['goal'] = goal;
    userData['subjects'] = {
      goal: {
        "Foundations": 10.0,
      }
    };
    await _storage.saveUserData(userData);
    notifyListeners();
  }

  // --- QUIZ LOGIC ---
  Future<void> updateMastery(String subject, String topic, double scoreChange) async {
    num currentScore = userData['subjects'][subject][topic] ?? 0;
    double newScore = (currentScore + scoreChange).clamp(0, 100).toDouble();

    userData['subjects'][subject][topic] = newScore;
    await _storage.saveUserData(userData);
    notifyListeners();
  }

  Future<String> fetchQuiz(String subject, String topic) async {
    if (!isConfigured) throw Exception("API Not Configured");
    return await _aiService.generateQuizQuestion(
        subject: subject,
        topic: topic,
        endpoint: apiEndpoint!,
        apiKey: apiKey!,
        model: selectedModel!
    );
  }

  // --- KNOWLEDGE MANAGEMENT LOGIC (CRUD) ---
  Future<void> addSubject(String subjectName) async {
    if (!userData['subjects'].containsKey(subjectName)) {
      userData['subjects'][subjectName] = <String, dynamic>{"Foundations": 0.0};
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
      userData['subjects'][subjectName][topicName] = 0.0;
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

    // Load BYOK Credentials
    final creds = await _secureStorage.getCredentials();
    apiEndpoint = creds['api_endpoint'];
    apiKey = creds['api_key'];
    selectedModel = creds['selected_model'];
    isConfigured = (apiEndpoint != null && apiKey != null && selectedModel != null);

    if (userData['current_chat'] != null) {
      chatHistory = List<Map<String, dynamic>>.from(userData['current_chat']);
    }
    if (userData['archived_chats'] != null) {
      archivedChats = List<Map<String, dynamic>>.from(userData['archived_chats']);
    }

    isInitializing = false;
    notifyListeners();
  }

  void _saveChatState() {
    userData['current_chat'] = chatHistory;
    userData['archived_chats'] = archivedChats;
    _storage.saveUserData(userData);
  }

  // --- STREAMING sendMessage METHOD ---
  Future<void> sendMessage(String text) async {
    if (!isConfigured) return;

    chatHistory.add({'role': 'user', 'content': text});
    // Add empty AI bubble to populate via stream
    chatHistory.add({'role': 'ai', 'content': ''});
    isTyping = true;
    _saveChatState();
    notifyListeners();

    await _aiService.generateStreamResponse(
        prompt: text,
        mode: currentMode,
        endpoint: apiEndpoint!,
        apiKey: apiKey!,
        model: selectedModel!,
        onChunk: (chunk) {
          chatHistory.last['content'] += chunk;
          notifyListeners(); // Updates UI in real-time
        },
        onError: (error) {
          chatHistory.last['content'] += '\nError details: $error';
          isTyping = false;
          notifyListeners();
        },
        onDone: () {
          isTyping = false;
          _saveChatState(); // Save final complete response
          notifyListeners();
        }
    );
  }

  // --- CHAT MANAGEMENT LOGIC (Preserved) ---
  void startNewChat() {
    if (chatHistory.isNotEmpty) {
      archivedChats.insert(0, {
        'preview': chatHistory.first['content'],
        'messages': List.from(chatHistory),
      });
    }
    chatHistory.clear();
    _saveChatState();
    notifyListeners();
  }

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

  void deleteSavedChat(int index) {
    archivedChats.removeAt(index);
    _saveChatState();
    notifyListeners();
  }

  void loadSavedChat(int index) {
    if (chatHistory.isNotEmpty) {
      archivedChats.insert(0, {
        'preview': chatHistory.first['content'],
        'messages': List.from(chatHistory),
      });
    }
    chatHistory = List<Map<String, dynamic>>.from(archivedChats[index]['messages']);
    archivedChats.removeAt(index);
    _saveChatState();
    notifyListeners();
  }

  void loadArchivedChat(int index) => loadSavedChat(index);
}