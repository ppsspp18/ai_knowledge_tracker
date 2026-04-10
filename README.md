# 🧠 AI Knowledge Tracker Companion

A local-first, AI-powered mentor built with Flutter. This app helps you map out your learning goals, tests your knowledge with dynamically generated quizzes, and acts as a multi-mode AI companion to accelerate your learning.

Powered by a **Bring Your Own Key (BYOK)** architecture, allowing you to connect to any OpenAI or Ollama-compatible endpoint.

---

## ✨ Features

* **🔑 Bring Your Own Key (BYOK) Architecture [NEW]:** Connect to any cloud or local LLM (such as OpenRouter, Google AI Studio, or a local Ollama instance) by configuring your own Base URL, API Key, and Model Name directly within the app.
* **🔒 Secure Local Storage [NEW]:** Your custom API configurations and credentials are encrypted and stored securely on your device, ensuring you maintain full control over your data and billing.
* **🎯 Knowledge Mapping (CRUD):** Break down your learning goals into Subjects and Topics. Add, rename, edit mastery scores, and delete topics as you progress.
* **🤖 Multi-Mode AI Mentor:** Switch your AI companion's persona instantly:
    * **Tutor:** Explains complex concepts with analogies.
    * **Mock Interviewer:** Asks tough technical questions.
    * **Evaluator:** Grades your responses.
    * **Motivator:** Keeps you on track to build daily habits.
* **🧠 Dynamic Quizzes:** Generate highly specific Multiple-Choice Questions (MCQs) for any topic. Earn +1 mastery for correct answers and -0.5 for incorrect ones.
* **💬 Persistent Chat Memory:** Beautiful markdown-rendered chat interface with streaming responses that lets you save, load, and delete past conversations without losing context.
* **💾 Local Progress Tracking:** All your learning progress, subjects, and chat histories are saved directly to your device.

---

## 🛠️ Tech Stack

* **Frontend:** Flutter & Dart
* **State Management:** `provider`
* **Local Storage:** `shared_preferences` (for progress/chat) & `flutter_secure_storage` (for API keys)
* **AI Backend:** Universal HTTP client supporting OpenAI-compatible and Ollama streaming formats
* **UI Utilities:** `flutter_markdown`

---

## 🚀 Getting Started

### Prerequisites
1. Install [Flutter SDK](https://docs.flutter.dev/get-started/install).
2. Get an API key from your preferred provider (e.g., [Google AI Studio](https://aistudio.google.com/), [OpenRouter.ai](https://openrouter.ai/), or set up [Ollama](https://ollama.com/) locally).

### Installation

1. **Clone or create the project:**
   ```bash
   flutter create ai_knowledge_tracker
   cd ai_knowledge_tracker
   ```
   
## Improvements : 
guide on onboarding
chat history should be share with LLM for better output. 
quiz is generating mostly same as the prompt is same. 
