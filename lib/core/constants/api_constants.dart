class ApiConstants {
  static const String openRouterKey = String.fromEnvironment(
    'OPENROUTER_KEY',
    defaultValue: 'sk-or-v1-YOUR_OPENROUTER_KEY_HERE',
  );
  static const String openRouterUrl = 'https://openrouter.ai/api/v1/chat/completions';
}
