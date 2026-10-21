# Broker (بروكر)

Flutter real-estate broker app, Clean Architecture + Firebase (project `broker-app-2026`, Android + iOS). Visual identity: **black + green** — `AppColors.primary` (#1A1A1A) / `primaryDark` (#000) for headers & surfaces, `AppColors.brand`/`link` (#1ED445 green) for actions, selected nav state, links, focus. Icons are `iconsax_plus` app-wide (Linear unselected / Bold selected or filled).

## Structure
- `lib/core/` — theme (`app_colors.dart`, `app_theme.dart` — use these app-wide), DI (`get_it`), errors, usecase base, shared widgets.
- `lib/features/<feature>/{domain,data,presentation}` — entities/usecases/repo contracts → Firestore models/datasources/repo impl → cubit/pages/widgets.

## Commands
- Analyze: `flutter analyze`
- Tests: `flutter test`
- Deploy Firestore rules: `firebase deploy --only firestore`
- Seed sample data: `node tool/seed_firestore.js` (uses the logged-in Firebase CLI session)
- List/approve registrations: `node tool/list_registrations.js [approve|delete <uid>]`
- Check Firebase Auth status: `node tool/enable_email_auth.js`

## Branding / shared UI
- Logo is a vector `core/widgets/brand_logo.dart` (`BrandLogo`, color `AppColors.brand`) — supports `progress` (stroke trace) and `fill` for animation; don't replace with a PNG.
- Splash: staged `AnimationController` (trace → fill/scale/glow → name → tagline → dots); navigates only after both the animation and `checkSession()` finish. Android native launch bg = `@color/splash_background` (#000000) to avoid a white flash.
- Auth screens use `AuthHeader` (gradient, `compact` variant w/ back button), `AppPrimaryButton`, `AppFormField(prefixIcon:)`, `AppPinField` (4-digit PIN w/ show/hide), `FadeSlideIn`.

## Auth flow
- App starts on `SplashPage` → `AuthCubit.checkSession()` → login / home / pending-review.
- Firebase Auth Email/Password: credentials derived via `core/utils/auth_credentials.dart` (`phone@broker.app` / `pin + "#b"` — Firebase needs ≥6 chars; users only ever type the 4-digit PIN).
- One-time console steps: Authentication → Get started → enable Email/Password.
- Media Storage: Cloudinary (cloud `kb1kx0do` / unsigned preset `pd5xbzdr`) via `core/services/cloudinary_service.dart`; uploads directly from mobile client, returns secure HTTPS URL, and stores URL in Firestore (`registrations.photoUrl`, `compounds.imageUrl`), keeping Firebase Storage usage at 0. URLs are auto-optimized (`f_auto,q_auto`) in `AppNetworkImage`.

## Firestore collections
- `developers` {name, logoUrl, order}
- `offers` {title, imageUrl, order}
- `compounds` {name, location, developerName, developerLogoUrl, imageUrl, developerStartPrice, resaleStartPrice (nullable → "غير متوفر"), commission (EGP amount), phone, propertyTypes[], region, district, readiness, finishing}
- `config/filter_options` {propertyTypes[], regions[{name, districts[]}], readinessStatuses[], finishings[]} — drives the compounds filter sheet; compound filter values must match these strings exactly. Edited by the (planned in-app) admin panel; public read, client write denied.
- `commissions` {brokerId, amount, compoundName?, status ("approved"/"pending"/"completed"/"rejected"), createdAt} — read own only, write denied.
- `withdrawal_requests` {brokerId, amount, method ("instapay"/"wallet"), status ("pending" initially), createdAt} — broker creates + reads own.
- `clients` {brokerId, name, phone, interest, note?, createdAt} — broker-scoped (read/create/delete own only; update denied). Sorted client-side by createdAt (no composite index).

## Main shell (4 tabs)
- `features/shell/presentation/pages/main_shell.dart` — `IndexedStack` preserves tab state: الرئيسية → `HomePage`, العملاء → `ClientsPage`, عمولاتي → `CommissionsPage`, حسابي → `AccountPage`. Approved auth lands here, not on HomePage directly.
- Clients: add via bottom-centered green pill FAB (not in the header) → `AddClientSheet` (name, phone, interest w/ compound-name autocomplete, optional note); card actions call/WhatsApp (`Launcher.call/whatsapp` — whatsapp converts 01…→+20)/delete w/ confirm.
- Commissions: wallet = approved commissions − completed − pending withdrawals (rejected returns to balance). Withdraw sheet validates amount, method instapay/wallet.
- Account: profile from `registrations/{uid}`, terms page (shared `terms_text.dart`), sign-out → `LoginPage`.

## Compounds filter
- Filter icon next to "كمبوندات في مصر" → `compound_filter_sheet.dart`. Logic is pure domain: `CompoundFilter.matches/apply` (client-side over loaded compounds; price filter uses `developerStartPrice`). Price/commission slider bounds come from the loaded data. Sections with no options in Firestore are hidden.
- `registrations` — 3-step broker sign-up requests: {fullName, birthDate, governorate ("بني سويف" only), phone, whatsapp, pinHash (sha256 — never store plain PIN), instaPayNumber?, walletNumber?, photoUrl?, status ("pending"), createdAt}. Rules: create is public, read/update/delete denied. Inspect via `node tool/list_registrations.js`.
