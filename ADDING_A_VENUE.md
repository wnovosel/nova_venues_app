# Adding a New Venue App

End-to-end checklist for launching a white-label app for a new venue.
Target time: ~2 hours once you have assets from the venue.

---

## 1. Get from the venue

- [ ] App name (e.g. "Knockin Noggin")
- [ ] Tagline (e.g. "Hard Cider & Good Times")
- [ ] Primary brand color (hex)
- [ ] Logo PNG (1024×1024, no background)
- [ ] Hero/splash image (1920×1080+)
- [ ] Support email
- [ ] Website URL
- [ ] Which features they want: menu / events / store / loyalty / map

---

## 2. Create the config file

Copy `lib/flavors/brew32_config.dart` → `lib/flavors/knockin_noggin_config.dart`

Change:
```dart
const TenantConfig kKnockinNogginConfig = TenantConfig(
  appName:        'Knockin Noggin',
  tagline:        'Hard Cider & Good Times',
  tenantId:       '<their UUID from Supabase tenants table>',
  primaryColor:   0xFF2D6A4F,   // their brand green
  bundleId:       'com.novavenues.knockinnoggin',
  androidPackage: 'com.novavenues.knockinnoggin',
  // ... rest of fields
);
```

---

## 3. Create the entry point

Create `lib/main_knockin_noggin.dart`:
```dart
import 'main.dart';
import 'flavors/knockin_noggin_config.dart';
void main() => runVenueApp(kKnockinNogginConfig);
```

---

## 4. Android — add flavor

In `android/app/build.gradle`, add inside `productFlavors {}`:
```groovy
knockin_noggin {
    dimension "venue"
    applicationId "com.novavenues.knockinnoggin"
    versionName "1.0.0"
    resValue "string", "app_name", "Knockin Noggin"
}
```

---

## 5. iOS — add scheme + export options

**Scheme:** Copy `ios/Runner.xcodeproj/xcshareddata/xcschemes/brew32.xcscheme`
→ `knockin_noggin.xcscheme`, update `buildConfiguration` to `Release-knockin_noggin`

**Export options:** Copy `ios/ExportOptions-brew32.plist`
→ `ios/ExportOptions-knockin_noggin.plist`, update bundle ID and provisioning profile name

---

## 6. Add assets

Place in `assets/`:
```
assets/icons/knockin_noggin_logo.png      (1024×1024)
assets/images/knockin_noggin_splash.jpg   (1920×1080)
assets/images/knockin_noggin_hero.jpg     (1200×800)
```

Update config fields: `logoAsset`, `splashAsset`, `heroAsset`

---

## 7. Register App Store presence

**iOS:**
- Log into [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
- New App → Bundle ID `com.novavenues.knockinnoggin`
- Fill in name, category, screenshots (can use simulator)
- Create provisioning profile in [developer.apple.com](https://developer.apple.com)

**Android:**
- Log into [play.google.com/console](https://play.google.com/console)
- Create new app → package `com.novavenues.knockinnoggin`
- $25 one-time fee if new Google account

---

## 8. Add CI matrix entry

In `.github/workflows/build_all_venues.yml`, add to both `ios` and `android` matrix:
```yaml
- flavor: knockin_noggin
  entry: main_knockin_noggin.dart
  bundle_id: com.novavenues.knockinnoggin
  package: com.novavenues.knockinnoggin
```

---

## 9. Add Fastfile lanes

In `fastlane/Fastfile`:
```ruby
lane :submit_knockin_noggin do
  flutter_build(flavor: "knockin_noggin", entry: "main_knockin_noggin.dart")
  upload_to_tf(app_id: "com.novavenues.knockinnoggin", ipa_path: "build/ios/ipa/Runner.ipa")
end
```

---

## 10. Build + test

```bash
# Test locally first
flutter run -t lib/main_knockin_noggin.dart --flavor knockin_noggin

# Submit to TestFlight
fastlane ios submit_knockin_noggin

# Submit to Play Store internal track
fastlane android submit_knockin_noggin
```

---

## GitHub Secrets needed (one-time setup)

| Secret | What it is |
|---|---|
| `IOS_CERTIFICATE_BASE64` | Distribution cert (.p12) base64 encoded |
| `IOS_CERTIFICATE_PASSWORD` | .p12 password |
| `IOS_PROVISIONING_PROFILE` | Per-venue .mobileprovision base64 encoded |
| `KEYCHAIN_PASSWORD` | Any password for the CI keychain |
| `ASC_KEY_ID` | App Store Connect API key ID |
| `ASC_ISSUER_ID` | App Store Connect issuer ID |
| `ASC_KEY_CONTENT` | App Store Connect .p8 key content |
| `ANDROID_KEYSTORE_BASE64` | Keystore .jks base64 encoded |
| `ANDROID_KEY_ALIAS` | Keystore alias |
| `ANDROID_KEY_PASSWORD` | Key password |
| `ANDROID_STORE_PASSWORD` | Keystore password |
| `PLAY_STORE_JSON_KEY` | Google Play service account JSON |

These are set once in GitHub → Settings → Secrets. All venues share the same secrets
(same Apple Developer account, same Android keystore) unless a venue has their own accounts.
