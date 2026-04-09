import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _userDataKey = 'user_knowledge_data';

  Future<void> saveUserData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, jsonEncode(data));
  }

  Future<Map<String, dynamic>> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataString = prefs.getString(_userDataKey);

    if (dataString != null) {
      return jsonDecode(dataString);
    }

    // Default dataset now includes a 'goal' field
    return {
      "goal": null, // null means user hasn't onboarded yet
      "subjects": {},
      "dailyStreak": 0,
    };
  }
}