/// App configuration and environment variables.
/// Replace the values below with your real Supabase project URL and anon key
/// from: Supabase Dashboard → Project Settings → API.
class AppConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://bxcwlrwelomwdraclnmq.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_lXaE5yGrJbk3cAwEtnt7Sg_GJW3-dZt',
  );

  /// True if Supabase is configured (not using placeholders).
  static bool get isConfigured =>
      !supabaseUrl.contains('YOUR_PROJECT_REF') &&
      !supabaseUrl.contains('your_project_ref') &&
      supabaseAnonKey != 'YOUR_ANON_KEY';
}
