/// App configuration and environment variables.
///
/// Override at build time:
/// ```sh
/// flutter build apk --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
/// ```
class AppConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://bxcwlrwelomwdraclnmq.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_lXaE5yGrJbk3cAwEtnt7Sg_GJW3-dZt',
  );

  /// `development` | `staging` | `production`
  static const String environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'production',
  );

  static bool get isProduction => environment == 'production';

  static const String legalSiteBaseUrl = String.fromEnvironment(
    'LEGAL_SITE_URL',
    defaultValue: 'https://mrazem-piscine.github.io/najd-legal',
  );

  /// External privacy policy URL (in-app policy is also available offline).
  static const String privacyPolicyUrl = String.fromEnvironment(
    'PRIVACY_POLICY_URL',
    defaultValue: 'https://mrazem-piscine.github.io/najd-legal/privacy',
  );

  static const String termsOfServiceUrl = String.fromEnvironment(
    'TERMS_URL',
    defaultValue: 'https://mrazem-piscine.github.io/najd-legal/terms',
  );

  /// Account deletion info page (Apple/Google compliance).
  static const String accountDeletionWebUrl = String.fromEnvironment(
    'ACCOUNT_DELETION_URL',
    defaultValue: 'https://mrazem-piscine.github.io/najd-legal/account-deletion',
  );

  static const String supportPageUrl = String.fromEnvironment(
    'SUPPORT_PAGE_URL',
    defaultValue: 'https://mrazem-piscine.github.io/najd-legal/support',
  );

  static const String supportEmail = String.fromEnvironment(
    'SUPPORT_EMAIL',
    defaultValue: 'mo3azrazem1@gmail.com',
  );

  static const String supportPhone = String.fromEnvironment(
    'SUPPORT_PHONE',
    defaultValue: '',
  );

  /// App Store / Play reviewer demo account (set via CI for review builds).
  static const String reviewerEmail = String.fromEnvironment(
    'REVIEWER_EMAIL',
    defaultValue: '',
  );

  static const String reviewerPassword = String.fromEnvironment(
    'REVIEWER_PASSWORD',
    defaultValue: '',
  );

  static bool get hasReviewerCredentials =>
      reviewerEmail.isNotEmpty && reviewerPassword.isNotEmpty;

  /// True if Supabase is configured (not using placeholders).
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty &&
      !supabaseUrl.contains('YOUR_PROJECT_REF') &&
      !supabaseUrl.contains('your_project_ref') &&
      supabaseAnonKey.isNotEmpty &&
      supabaseAnonKey != 'YOUR_ANON_KEY';

  static const String appVersion = '1.0.0';
  static const String androidPackageId = 'sa.najd.volunteer';
  static const String iosBundleId = 'sa.najd.volunteer';
}
