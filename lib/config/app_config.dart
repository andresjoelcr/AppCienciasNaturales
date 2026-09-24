class AppConfig {
  static const String groqApiKey = String.fromEnvironment('GROQ_API_KEY');
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String groqApiUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String groqModel = String.fromEnvironment(
    'GROQ_MODEL',
    defaultValue: 'openai/gpt-oss-20b',
  );
}
