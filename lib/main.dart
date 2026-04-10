import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/dashboard_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/byok_setup_screen.dart'; // ADD THIS
// import 'package:flutter_dotenv/flutter_dotenv.dart'; // Optional: remove if unused


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await dotenv.load(fileName: ".env"); // Optional: remove if fully BYOK now

  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const AICompanionApp(),
    ),
  );
}

class AICompanionApp extends StatelessWidget {
  const AICompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Knowledge Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final List<Widget> _screens = [const DashboardScreen(), const ChatScreen()];

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    // 1. Show loading screen while reading local storage
    if (state.isInitializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 2. NEW: Enforce BYOK setup before anything else
    if (!state.isConfigured) {
      return const BYOKSetupScreen();
    }

    // 3. Show original Onboarding if no learning goal is set
    if (state.userData['goal'] == null) {
      return const OnboardingScreen();
    }

    // 4. Show Main App
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'AI Mentor'),
        ],
      ),
    );
  }
}