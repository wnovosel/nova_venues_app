import '../core/config/tenant_config.dart';

/// Brew 32 — standalone venue app example.
/// Shows how little changes between venues: colors, name, IDs, assets.
/// Everything else (menu, events, map, auth, API) is identical core code.
const TenantConfig kBrew32Config = TenantConfig(
  appName:        'Brew 32',
  tagline:        'Craft Beer & Pub Fare',
  apiBaseUrl:     'https://wondernetwork.net',
  tenantId:       '00000000-0000-0000-0000-000000000001', // same tenant for now; update when multi-tenant

  // Brew 32 brand — dark amber, cream, slate
  primaryColor:     0xFFB45309,   // amber
  backgroundColor:  0xFFFAF7F2,   // warm cream
  surfaceColor:     0xFFFFFFFF,
  textColor:        0xFF1C1917,
  mutedColor:       0xFF78716C,
  borderColor:      0xFFE7E5E4,
  navBarColor:      0xFFFFFFFF,

  headingFont:    'Montserrat',   // different heading font — still uses Inter body
  bodyFont:       'Inter',

  bundleId:       'com.novavenues.brew32',
  androidPackage: 'com.novavenues.brew32',
  appleTeamId:    'S9687U7PPC',

  logoAsset:      'assets/icons/brew32_logo.png',
  splashAsset:    'assets/images/brew32_splash.jpg',
  heroAsset:      'assets/images/brew32_hero.jpg',

  supportEmail:   'hello@brew32.com',
  websiteUrl:     'https://brew32.com',

  enableMenu:               true,
  enableEvents:             true,
  enableStore:              false,  // no online store for Brew 32 yet
  enableLoyalty:            false,  // loyalty not enabled
  enableMap:                true,
  enableWonder:             false,  // Wonder is Nova-only
  enablePushNotifications:  true,
  enableQrCheckin:          false,
);
