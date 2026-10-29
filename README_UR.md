# Sahil Khata — Flutter source aur APK guide

Sahil Khata ek offline-first personal finance app hai jo salaried teacher ke liye banayi gayi hai. Data phone ke private SQLite database mein save hota hai; internet ki zaroorat nahi hoti.

## Features

- Dark purple gradient dashboard with month selector, Net Worth, Income aur Expense totals.
- Cash Wallet, Bank Account aur Savings wallet cards.
- Payable accounts: dukandar ka naam, address, phone, category, outstanding udhaar, search, edit, delete aur inactive toggle.
- Receivable accounts: Salary, Property Rent aur Business Share ke liye outstanding balance tracking.
- Expense transaction: Payable account select karte hi name, category, address, phone aur current balance auto-fill hota hai.
- Income transaction: Receivable select karne par details auto-fill hoti hain; receipt wallet balance mein add hoti hai aur receivable outstanding kam hota hai.
- Payment, account-to-account transfer, transaction search, edit/delete, recent activity aur category donut breakdown.
- Dedicated Reports tab: old-record search, category/type/account filters, one date ya two-date range, payable statement opening balance, period movement, closing balance aur PDF share/export.
- Account history wale records delete karne ke bajaye inactive mark hote hain, is liye history safe rehti hai.

## Project files

- `lib/main.dart` — dashboard, accounts, transaction forms aur navigation.
- `lib/models.dart` — `KhataAccount` aur `KhataTransaction` models.
- `lib/database.dart` — SQLite schema aur atomic balance updates.
- `lib/report.dart` — date/category/account filters, payable statements aur PDF export.
- `lib/widgets.dart` — shared colors, cards, icons aur formatting helpers.
- `codemagic.yaml` — cloud APK build workflow.

## Codemagic se APK (Android Studio ke baghair)

1. Is folder ko GitHub par new repository mein upload karein. Repository root mein `pubspec.yaml`, `codemagic.yaml` aur `lib/` zaroor hon.
2. [codemagic.io](https://codemagic.io/) par GitHub se sign in karein aur **Add application** select karein.
3. GitHub repository choose karein, project type **Flutter** rakhein, aur repository mein mojood `codemagic.yaml` workflow use karein.
4. Workflow `flutter create --platforms=android` se Android platform files generate karega, phir packages, analyzer aur release APK build karega.
5. **Start new build** dabayein. Build complete hone par Artifacts section se `app-release.apk` download karein.
6. Phone par APK open karke “Install unknown apps” permission allow karein. Play Store release ke liye signing key configure karna zaroori hai.

## App mein report kaise nikalein

1. Neeche **Reports** tab open karein.
2. **From** aur **To** dates select karein. Same date rakhne se single-day report milti hai.
3. Search box mein dukandar, category ya note likh kar purana record find karein.
4. Category, transaction type ya payable/receivable account select karein. Account select karne par statement card mein opening balance, period movement aur closing balance dikhega.
5. **Export report as PDF** dabayein. Android ka share/save sheet khulega; PDF ko Files, WhatsApp, email ya Drive mein save/share kar sakte hain.

## Codemagic signing (Play Store ke liye)

Testing APK unsigned/debug-compatible cloud artifact ke liye theek hai. Production/Play Store ke liye Codemagic mein Android keystore upload karein, keystore reference ko workflow mein configure karein, aur `flutter build appbundle --release` use karein. Keystore ko GitHub mein commit na karein.

## Local checks

Flutter SDK install hone ke baad project root mein:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

APK yahan milegi:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Important data note

Database app ke private storage mein `sahil_khata.db` naam se banta hai. App uninstall karne se local data delete ho sakta hai. Production use se pehle backup/export feature add karna recommended hai.
