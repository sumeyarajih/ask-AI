import 'dart:async';
import '../models/chat_session.dart';

class ChatSessionService {
  static final ChatSessionService _instance = ChatSessionService._internal();
  factory ChatSessionService() => _instance;
  ChatSessionService._internal();

  final List<ChatSession> _sessions = [
    ChatSession(
      id: 'session-1',
      title: 'Previous conversation about AI',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ChatSession(
      id: 'session-2',
      title: 'Help with Flutter app',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  Future<List<ChatSession>> getSessions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_sessions);
  }

  Future<ChatSession> createSession() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newSession = ChatSession(
      id: 'session-${DateTime.now().millisecondsSinceEpoch}',
      title: 'New Chat',
      createdAt: DateTime.now(),
    );
    _sessions.insert(0, newSession);
    return newSession;
  }

  Future<void> updateSessionTitle(String id, String newTitle) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _sessions.indexWhere((s) => s.id == id);
    if (index != -1) {
      _sessions[index].title = newTitle;
    }
  }

  Future<void> deleteSession(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _sessions.removeWhere((s) => s.id == id);
  }
}
