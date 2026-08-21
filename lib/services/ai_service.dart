import 'dart:async';

class AIService {
  Future<String> getResponse(String userMessage, {String? documentId}) async {
    await Future.delayed(const Duration(seconds: 1));
    final responses = [
      "I understand you're asking about: $userMessage",
      "That's an interesting question about $userMessage",
      "I'm analyzing your query: $userMessage",
      if (documentId != null) "Based on the provided document, here is the answer: $userMessage",
    ];
    return responses[DateTime.now().millisecond % responses.length];
  }

  Stream<String> getStreamingResponse(String userMessage, {String? documentId}) async* {
    String fullResponse = await getResponse(userMessage, documentId: documentId);
    
    // Simulate streaming by yielding chunks
    String current = "";
    final words = fullResponse.split(' ');
    
    for (var word in words) {
      await Future.delayed(const Duration(milliseconds: 100)); // Streaming delay
      current += "$word ";
      yield current;
    }
  }

  Future<String> uploadDocument(String fileName, List<int> bytes) async {
    // Mock uploading file to pgvector indexing endpoint
    await Future.delayed(const Duration(seconds: 2));
    return 'doc-${DateTime.now().millisecondsSinceEpoch}';
  }
}