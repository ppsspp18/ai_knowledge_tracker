import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class BYOKSetupScreen extends StatefulWidget {
  final bool isSettingsMode;

  const BYOKSetupScreen({super.key, this.isSettingsMode = false});

  @override
  State<BYOKSetupScreen> createState() => _BYOKSetupScreenState();
}

class _BYOKSetupScreenState extends State<BYOKSetupScreen> {
  // Use OpenRouter endpoint as the default example
  final _endpointController = TextEditingController(text: 'https://openrouter.ai/api/v1/chat/completions');
  final _apiKeyController = TextEditingController();
  final _modelController = TextEditingController(text: 'openrouter/free');

  @override
  void initState() {
    super.initState();
    // If we are editing settings, pre-fill the text fields with saved data
    final state = Provider.of<AppState>(context, listen: false);
    if (state.apiEndpoint != null) _endpointController.text = state.apiEndpoint!;
    if (state.apiKey != null) _apiKeyController.text = state.apiKey!;
    if (state.selectedModel != null) _modelController.text = state.selectedModel!;
  }

  void _saveConfiguration() async {
    if (_endpointController.text.isEmpty || _modelController.text.isEmpty) return;

    await Provider.of<AppState>(context, listen: false).saveApiConfiguration(
      _endpointController.text.trim(),
      _apiKeyController.text.trim(),
      _modelController.text.trim(),
    );

    if (mounted) {
      if (widget.isSettingsMode) {
        // If opened from settings, pop back to the app
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('API Settings Updated!')),
        );
      }
      // If it's the first time setup, AppState will automatically trigger MainLayout to route to the Dashboard
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isSettingsMode ? 'API Settings' : 'Setup AI Connection')),
      body: SingleChildScrollView( // Added to prevent overflow when keyboard pops up
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.cloud_sync, size: 64, color: Colors.blueGrey),
            const SizedBox(height: 16),
            const Text(
              'API Configuration',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _endpointController,
              decoration: const InputDecoration(
                  labelText: 'Full API Endpoint URL',
                  helperText: 'e.g., https://generativelanguage.googleapis.com/v1beta/openai/chat/completions',
                  border: OutlineInputBorder()
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(labelText: 'API Key', border: OutlineInputBorder()),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _modelController,
              decoration: const InputDecoration(labelText: 'Model Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveConfiguration,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.blueGrey),
              child: const Text('Save Settings', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}