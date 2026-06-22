# Nova Venues App — White-Label Mobile Platform

A config-driven Flutter app that powers one branded venue app per tenant.
Same codebase. Different icon, colors, name, feature flags. One build per venue.

## How It Works

Every venue app is a **Flutter flavor** — a separate entry point (`main_<venue>.dart`)
that passes a `TenantConfig` into the shared app core.

```
lib/
  flavors/
    nova_cellars_config.dart   ← Nova Destinations (flagship)
    brew32_config.dart         ← Brew 32 example
    <your_venue>_config.dart   ← add new venues here
  main_nova_cellars.dart       ← flavor entry point
  main_brew32.dart
  core/                        ← shared: api, theme, config, widgets
  features/                    ← shared: home, menu, events, map, account, store
```

## Adding a New Venue App

1. Copy `lib/flavors/brew32_config.dart` → `lib/flavors/yourplace_config.dart`
2. Fill in: name, colors, Bundle ID, tenantId, enabled features
3. Create `lib/main_yourplace.dart` pointing to your config
4. Add iOS scheme + Android flavor in build config (see below)
5. Submit to App Store under the venue's (or your) Apple Developer account

## Build Commands

```bash
# Run Nova Destinations
flutter run -t lib/main_nova_cellars.dart --flavor nova_cellars

# Run Brew 32
flutter run -t lib/main_brew32.dart --flavor brew32

# Build IPA for App Store (Nova Cellars)
flutter build ipa -t lib/main_nova_cellars.dart --flavor nova_cellars
```

## TenantConfig Fields

| Field | Description |
|---|---|
| `appName` | Display name in app bar and App Store |
| `tagline` | Hero card subtitle |
| `apiBaseUrl` | Always `https://wondernetwork.net` for Nova tenants |
| `tenantId` | UUID maps to backend org_id |
| `primaryColor` | Brand color (buttons, accents, active nav) |
| `headingFont` | Cinzel for Nova, any Google Font for others |
| `enableMenu` | Show/hide Menu tab |
| `enableEvents` | Show/hide Events tab |
| `enableStore` | Show/hide Store tab |
| `enableLoyalty` | Nova Keys loyalty program |
| `enableWonder` | Project Wonder dark experience (Nova only) |
| `enableQrCheckin` | Staff QR scanner for event check-in |
| `bundleId` | iOS Bundle ID — unique per app |
| `androidPackage` | Android package name — unique per app |

## Architecture

- `AppProvider` — holds auth state + `ApiClient`, provided at root
- `ApiClient` — tenant-aware HTTP client, sends `X-Tenant-ID` on every request
- `AppTheme` — builds `ThemeData` from `TenantConfig` at runtime
- `ShellScreen` — tab navigation, tabs built dynamically from feature flags
- All screens receive `TenantConfig` and use `AppTheme` — zero hardcoded colors

## Backend

Flask API at `wondernetwork.net`. Reads from Nova Brain spine tables (work_units,
offers, ledger_entries, etc.) via `spine.py` service layer. Tenant isolation via RLS.

Repo: `wnovosel/nova_venues`
