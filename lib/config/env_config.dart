/// Environment configuration
/// 
/// For local development, these values are set directly.
/// For production builds, use --dart-define to override:
/// 
/// flutter build web \
///   --dart-define=SUPABASE_URL=your_url \
///   --dart-define=SUPABASE_ANON_KEY=your_key \
///   --dart-define=GROQ_API_KEY=your_key

class EnvConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );
  
  static const String groqApiKey = String.fromEnvironment(
    'GROQ_API_KEY',
    defaultValue: '',
  );
}
