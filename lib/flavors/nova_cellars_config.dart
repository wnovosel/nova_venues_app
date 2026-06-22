import '../core/config/tenant_config.dart';

/// Nova Cellars / Nova Destinations — the flagship tenant.
/// This is the reference config. Copy and modify for each new venue.
const TenantConfig kNovaCellarsConfig = TenantConfig(
  appName:        'Nova Destinations',
  tagline:        'Your Nova Experience',
  apiBaseUrl:     'https://wondernetwork.net',
  tenantId:       '00000000-0000-0000-0000-000000000001',

  // Nova light theme — cream, wine red, dark text
  primaryColor:     0xFF9B1B2B,   // wine red
  backgroundColor:  0xFFF5F3F0,   // cream
  surfaceColor:     0xFFFFFFFF,   // white cards
  textColor:        0xFF1A1714,   // dark text
  mutedColor:       0xFF8A8078,   // muted gray
  borderColor:      0xFFE8E4E0,   // border
  navBarColor:      0xFFFFFFFF,

  headingFont:    'Cinzel',
  bodyFont:       'Inter',

  bundleId:       'com.novadestinations.wonder',
  androidPackage: 'com.novadestinations.wonder',
  appleTeamId:    'S9687U7PPC',

  logoAsset:      'assets/icons/nova_logo.png',
  splashAsset:    'assets/images/nova_splash.jpg',
  heroAsset:      'assets/images/nova_hero.jpg',

  supportEmail:   'hello@novadestinations.com',
  websiteUrl:     'https://nova.wine',

  enableMenu:               true,
  enableEvents:             true,
  enableStore:              true,
  enableLoyalty:            true,
  enableMap:                true,
  enableWonder:             true,   // Nova-only: Project Wonder dark experience
  enablePushNotifications:  true,
  enableQrCheckin:          true,
);
