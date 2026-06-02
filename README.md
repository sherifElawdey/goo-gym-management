# Goo GYM - GYM PRO MANAGER

Enterprise-ready Flutter app for gym operations:
- Membership and subscription lifecycle
- Daily attendance (members + visitors)
- Finance and expense tracking
- Admin/staff operations with Firebase backend

## Stack
- Flutter + Material 3
- Bloc/Cubit + Equatable
- Clean/feature-based architecture
- Repository pattern + GetIt DI
- Firebase Auth, Firestore, FCM, Analytics, Crashlytics, Storage

## Project Structure
- `lib/core`: constants, theme, services, utils, shared widgets
- `lib/domain`: entities and repository contracts
- `lib/data`: Firebase repository implementations
- `lib/features`: auth, dashboard, attendance, users, subscriptions, finance, notifications, settings
- `lib/injection_container.dart`: dependency wiring

## Firebase Setup
1. Install FlutterFire CLI and login:
   - `dart pub global activate flutterfire_cli`
   - `firebase login`
2. Configure project:
   - `flutterfire configure`
3. Enable services in Firebase Console:
   - Authentication (Email/Password)
   - Cloud Firestore
   - Cloud Messaging
   - Analytics
   - Crashlytics
   - Storage
4. Deploy rules and indexes:
   - `firebase deploy --only firestore:rules`
   - `firebase deploy --only firestore:indexes`
5. Create your first admin — see [docs/FIREBASE_ADMIN_SETUP.md](docs/FIREBASE_ADMIN_SETUP.md)

## Run
- `flutter pub get`
- `flutter gen-l10n` (after changing `lib/l10n/app_ar.arb`)
- `dart run flutter_launcher_icons` (after replacing `assets/icon/app_icon.png`)
- `flutter run`

Default UI: **Arabic (ar_EG)**, **RTL**, **light theme**, currency **EGP (ج.م.)**.

## Quality
- `flutter analyze`
- `flutter test`
