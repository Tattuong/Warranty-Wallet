# Warranty Wallet

Manage warranties, invoices, receipts, serial numbers, and expiry dates — fully offline on your device.

## Features

- **Device tracking** — name, category, serial number, store, purchase date, warranty expiry
- **Invoice & photos** — save receipt images and up to 3 photos per device (10 with Multi Photos unlock)
- **Dashboard** — expired, expiring soon, and active warranty overview
- **Coin economy** — earn coins by daily login, adding devices, saving photos/invoices
- **Shop** — spend coins on themes, backgrounds, card skins, and premium features
- **Google Play IAP** — 10 consumable coin packs (`ww_pack_1` … `ww_pack_10`) + remove ads (`ww_remove_ads`)
- **Remote config** — `https://api2.blwsmartware.net/R225.json` (`disable=1` hides billing, shop still works)

## Package

| Platform | ID |
|----------|-----|
| Android `applicationId` | `com.warrantywalletmng.warrantywallet` |
| iOS bundle | `com.warrantywalletmng.warrantywallet` |

## Setup

```bash
flutter pub get
python tool/generate_logo.py
dart run flutter_launcher_icons
flutter run
```

## Google Play IAP products

Configure in Play Console using IDs from `docs/iap_config.json`:

- `ww_pack_1` … `ww_pack_10` (consumable)
- `ww_remove_ads` (non-consumable)

## Build release

```bash
flutter build appbundle --release
```

Requires `key.properties` for signing.
