class AIService {
  Future<String> getResponse(String userMessage) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock responses - replace with actual AI API calls
    final responses = [
      "I understand you're asking about: $userMessage",
      "That's an interesting question about $userMessage",
      "I'm analyzing your query: $userMessage",
      "Thanks for your message! Regarding $userMessage...",
      "I'm designed to help with topics like $userMessage"
    ];
    
    return responses[DateTime.now().millisecond % responses.length];
  }
}