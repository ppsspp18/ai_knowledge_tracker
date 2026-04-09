# 🧠 AI Knowledge Tracker Companion

A local-first, AI-powered mentor built with Flutter. This app helps you map out your learning goals, tests your knowledge with dynamically generated quizzes, and acts as a multi-mode AI companion to accelerate your learning.

Powered by OpenRouter.

---

## ✨ Features

* **🎯 Knowledge Mapping (CRUD):** Break down your learning goals into Subjects and Topics. Add, rename, edit mastery scores, and delete topics as you progress.
* **🤖 Multi-Mode AI Mentor:** Switch your AI companion's persona instantly:
    * **Tutor:** Explains complex concepts with analogies.
    * **Mock Interviewer:** Asks tough technical questions.
    * **Evaluator:** Grades your responses.
    * **Motivator:** Keeps you on track to build daily habits.
* **🧠 Dynamic Quizzes:** Generate highly specific Multiple-Choice Questions (MCQs) for any topic. Earn +1 mastery for correct answers and -0.5 for incorrect ones.
* **💾 Local-First Storage:** All your progress, subjects, and chat histories are saved directly to your device using `shared_preferences`.
* **💬 Persistent Chat Memory:** Beautiful markdown-rendered chat interface that lets you save, load, and delete past conversations without losing context.

---

## 🛠️ Tech Stack

* **Frontend:** Flutter & Dart
* **State Management:** `provider`
* **Local Storage:** `shared_preferences`
* **AI Backend:** OpenRouter REST API (`http` package)
* **LLM:** `openrouter/free`
* **UI Utilities:** `flutter_markdown`

---

## 🚀 Getting Started

### Prerequisites
1. Install [Flutter SDK](https://docs.flutter.dev/get-started/install).
2. Get a free API key from [OpenRouter.ai](https://openrouter.ai/).

### Installation

1. **Clone or create the project:**
   ```bash
   flutter create ai_knowledge_tracker
   cd ai_knowledge_tracker