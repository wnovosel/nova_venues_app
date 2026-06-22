/// TenantConfig — the entire identity of one white-label app instance.
///
/// To launch a new venue app:
///   1. Create a new file in lib/flavors/  (e.g. brew32_config.dart)
///   2. Return a TenantConfig with that venue's values
///   3. Add a Flutter flavor in android/ios build config pointing to that file
///   4. Submit to App Store / Play Store under the venue's account (or yours)
///
/// Nothing else changes. The entire core app reads from this config.

class TenantConfig {
  /// Display name — used in app bar, splash, store listings
  final String appName;

  /// Short tagline shown on home screen hero
  final String tagline;

  /// API base URL — always https://wondernetwork.net for Nova-hosted tenants
  final String apiBaseUrl;

  /// Tenant ID passed as X-Tenant-ID header on every API request.
  /// Maps to org_id / winery_id on the backend.
  final String tenantId;

  // ── Branding ───────────────────────────────────────────────────────────────

  /// Primary brand color (buttons, active nav, accents)
  final int primaryColor;

  /// Background color for light surfaces
  final int backgroundColor;

  /// Card/surface color
  final int surfaceColor;

  /// Primary text color
  final int textColor;

  /// Muted/secondary text color
  final int mutedColor;

  /// Border color
  final int borderColor;

  /// Nav bar background
  final int navBarColor;

  // ── Typography ─────────────────────────────────────────────────────────────

  /// Font family for headings (e.g. 'Cinzel', 'Playfair Display', 'Montserrat')
  final String headingFont;

  /// Font family for body text (e.g. 'Inter', 'Lato', 'Open Sans')
  final String bodyFont;

  // ── Features — toggle which tabs/features are enabled ─────────────────────

  final bool enableMenu;
  final bool enableEvents;
  final bool enableStore;
  final bool enableLoyalty;      // Nova Keys / loyalty program
  final bool enableMap;
  final bool enableWonder;       // Project Wonder dark experience — Nova only
  final bool enablePushNotifications;
  final bool enableQrCheckin;    // Staff check-in scanner

  // ── App Store metadata ─────────────────────────────────────────────────────

  /// iOS Bundle ID  e.g. com.novavenues.brew32
  final String bundleId;

  /// Android package name  e.g. com.novavenues.brew32
  final String androidPackage;

  /// Apple Team ID (from Apple Developer account)
  final String appleTeamId;

  /// Asset paths (relative to assets/) for this tenant's branding
  final String logoAsset;        // e.g. 'assets/icons/brew32_logo.png'
  final String splashAsset;      // e.g. 'assets/images/brew32_splash.jpg'
  final String heroAsset;        // e.g. 'assets/images/brew32_hero.jpg'

  /// Support email shown in Account tab
  final String supportEmail;

  /// Website URL shown in Account tab
  final String websiteUrl;

  const TenantConfig({
    required this.appName,
    required this.tagline,
    required this.apiBaseUrl,
    required this.tenantId,
    required this.primaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.textColor,
    required this.mutedColor,
    required this.borderColor,
    required this.navBarColor,
    required this.headingFont,
    required this.bodyFont,
    required this.bundleId,
    required this.androidPackage,
    required this.appleTeamId,
    required this.logoAsset,
    required this.splashAsset,
    required this.heroAsset,
    required this.supportEmail,
    required this.websiteUrl,
    this.enableMenu = true,
    this.enableEvents = true,
    this.enableStore = false,
    this.enableLoyalty = false,
    this.enableMap = true,
    this.enableWonder = false,
    this.enablePushNotifications = true,
    this.enableQrCheckin = false,
  });
}
