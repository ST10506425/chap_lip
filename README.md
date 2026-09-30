# Moist Me Up

Moist Me Up is a playful, interactive digital lip care mobile app that turns hydration into a game. When your real life lips feel chapped, you open the app and apply moisturising products to your own customised digital lips. You start with classic Vaseline, and the more you look after your digital lips, the more balms, lipsticks and treats you unlock.

The app is built with Flutter, so the same code runs on Android and iPhone. Everything (your account, your session, your lips and your progress) is stored in a SQLite database on the phone itself. There is no server and no internet connection is needed.

---

## Contents

1. [Features](#features)
2. [Screens](#screens)
3. [How the game works](#how-the-game-works)
4. [The product shelf](#the-product-shelf)
5. [Animations](#animations)
6. [What you need](#what-you-need)
7. [Get the code running](#get-the-code-running)
8. [Put the app on an Android phone](#put-the-app-on-an-android-phone)
9. [Put the app on an iPhone](#put-the-app-on-an-iphone)
10. [Run the tests](#run-the-tests)
11. [How the data is stored](#how-the-data-is-stored)
12. [Project structure](#project-structure)
13. [Troubleshooting](#troubleshooting)

---

## Features

* **Personalisation:** choose how you identify, then pick one of four lip shapes (Soft, Full, Cupid, Wide) and one of six natural shades (Petal, Blush, Rose, Mauve, Plum, Cocoa).
* **Gamified hydration:** your lips start chapped, with dry cracks and flakes. Swipe across them, drag your product onto them, or tap the button, and they turn smooth and glossy strip by strip.
* **Progression:** every finished application is saved. Milestones at 5, 15, 30, 50 and 100 applications unlock new products, and your level goes up every 10 applications.
* **Product collection:** a shelf showing what you own and what is still locked, with the number of applications each locked item needs.
* **Accounts and sessions on the phone:** sign up, log in, stay logged in after closing the app, log out, edit your details and reset a forgotten password. Passwords are salted and hashed before they are saved.

---

## Screens

The app follows the ten screens in the Figma file (the exported designs live on the `mobile-app-designs` branch of this repository), plus two small extra screens that the menu items needed.

| # | Screen | What it does |
|---|--------|--------------|
| 01 | Welcome | Branding, floating glossy lips and the entry buttons |
| 02 | Sign up | Create a local account (name, email, password) |
| 03 | Log in | Return to an existing account, with a password reset sheet |
| 04 | Personalize | "How do you identify?" (optional, step 1 of 2) |
| 05 | Choose lips | Pick your pout and shade with live previews (step 2 of 2) |
| 06 | Moist Up | Chapped lips, your next unlock, and your current product |
| 07 | Application complete | "+1 application" and progress toward the next treat |
| 08 | Product unlocked | Celebration when a milestone is reached |
| 09 | Collection | "The gloss club" shelf of owned and locked products |
| 10 | Your profile | Your lips, level, stats and account menu |
| Extra | Customize my lips | Reuses screen 05 to change your pout later |
| Extra | Profile | Change name, email, identity or password |

Colours, spacing and type (Inter) were measured from the design exports so the screens line up with them on a standard 390 by 844 phone. On smaller phones the screens scroll instead of squashing.

---

## How the game works

1. Open the **Moist Up** tab. Your lips are chapped.
2. Apply your product in any of three ways:
   * **Swipe** a finger across the lips.
   * **Drag** the product from under the lips and rub it across them.
   * **Tap** "Apply a little love" and watch the product glide across on its own.
3. Each part of the lips you cover turns glossy. Once most of the mouth is covered, the rest fills in, the shine highlights draw on, sparkles burst and the application is saved.
4. You land on **Application complete**, which shows how close you are to the next product.
5. When you reach a milestone, **Product unlocked** appears. Choose "Try my ..." to start using it straight away, or "View my collection" to see your shelf.
6. In **Collection**, tap any owned product to switch to it. Tap a locked one to see how many applications are left.
7. Your lips stay moisturised for a while, depending on what you applied: Vaseline 1 hour, Rose balm and Peach butter 2 hours, Berry gloss and Golden glow 3 hours, Cloud mask 4 hours. The **Moist Up** tab shows how long is left, and the lips turn chapped again when it wears off.

Each product leaves its own finish on your lips: Vaseline keeps your natural shade, Rose balm adds a rosy tint, Berry gloss is a bold berry lipstick with extra shine, Peach butter warms the colour, Cloud mask adds a wet look glow and Golden glow adds twinkling gold shimmer.

---

## The product shelf

Products are not all Vaseline tubs. Each one is drawn as its own kind of packaging:

| Product | Packaging | Unlocks at |
|---------|-----------|-----------|
| Vaseline | Classic tub with screw lid | Starter |
| Rose balm | Lip balm stick | 5 applications |
| Berry gloss | Lipstick with its cap | 15 applications |
| Peach butter | Lip balm stick | 30 applications |
| Cloud mask | Squeeze tube | 50 applications |
| Golden glow | Gold lipstick with its cap | 100 applications |

On the collection shelf, owned products use the purple tint from the design and locked ones show as grey silhouettes with a "?" label, just like the Collection screen in Figma.

---

## Animations

* Staggered fade and rise entrances on every screen, and soft fade transitions between screens.
* Lips that breathe, float and catch a moving glint of light; shade changes blend smoothly.
* Swipe reveal from chapped to glossy, highlight strokes that draw themselves on, a sheen sweep, a little pop and a sparkle burst when an application finishes.
* A ghost finger that shows where to swipe, and a product that wiggles until you touch it.
* Twinkling sparkles and slowly drifting colour blobs in every illustration panel.
* Buttons and cards that squash on press and spring back, with light haptic taps.
* A shine that sweeps across the main buttons, and bouncing dots while something saves.
* Animated radio dots, lip shape cards and shade swatches during personalisation.
* Progress bars that fill, numbers that count up, and a level chip that pops when it changes.
* A product that drops in with a bounce, a glowing halo and falling confetti on the unlock screen.
* Form fields with an animated focus ring, and a gentle shake when something needs fixing.

---

## What you need

| Tool | Why |
|------|-----|
| [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.32 or newer (tested with 3.47) | Builds and runs the app |
| [Android Studio](https://developer.android.com/studio) | Android SDK, emulator and USB drivers |
| Xcode on a Mac (only for iPhone) | Builds and signs the iPhone app |
| An Android phone or iPhone and a USB cable | To run the app on a real device |

After installing Flutter, open a terminal and run:

```bash
flutter doctor
```

Fix anything it marks with a red cross for the platform you want (Android toolchain for Android, Xcode for iPhone). If it asks you to accept Android licences, run `flutter doctor --android-licenses` and answer `y` to each one.

---

## Get the code running

```bash
git clone https://github.com/ST10506425/chap_lip.git
cd chap_lip
git checkout mobile-app
flutter pub get
```

To try it quickly on an emulator:

1. In Android Studio open **Device Manager** and create a phone (a Pixel with a recent Android version works well), then press play to start it.
2. Back in the terminal run:

```bash
flutter devices
flutter run
```

The app opens on the emulator. While it is running, press `r` in the terminal to hot reload after a code change, `R` to restart, and `q` to quit.

---

## Put the app on an Android phone

### Option A: run it straight from your computer

1. On the phone open **Settings**, then **About phone**, and tap **Build number** seven times to unlock **Developer options**.
2. Open **Settings**, then **Developer options**, and turn on **USB debugging**.
3. Plug the phone into your computer and tap **Allow** on the phone when it asks to trust the computer.
4. Check that Flutter can see the phone, then run the app:

```bash
flutter devices
flutter run
```

For a smooth, full speed version (without the debug tools), use release mode:

```bash
flutter run --release
```

The app stays installed on the phone afterwards, so you can open it from the home screen like any other app.

### Update the app on your phone, then unplug

Use this after changing code when you want to test without the phone staying attached to the computer. Run each command on its own, from the `chap_lip` folder, with the phone plugged in and unlocked.

1. Find your phone's device ID (the second column, for example `QTC4C19A18009821`):

```bash
flutter devices
```

2. Build the release APK (takes about a minute after the first build):

```bash
flutter build apk --release
```

3. Install it over the old version. Your account and progress are kept (`flutter install` would uninstall first and wipe them):

```powershell
& "$env:LOCALAPPDATA\Android\sdk\platform-tools\adb.exe" -s YOUR_DEVICE_ID install -r build\app\outputs\flutter-apk\app-release.apk
```

When it prints `Success`, the command is finished. Unplug the phone and open **Moist Me Up** from the home screen.

### Option B: build an installable APK file

```bash
flutter build apk
```

This creates a release APK at:

```
build/app/outputs/flutter-apk/app-release.apk
```

To install it:

* **With the phone plugged in:** run `flutter install`.
* **Without a cable:** copy the APK file to the phone (email, cloud drive or a file transfer), open it on the phone and allow installing from that source when asked.

The release build is signed with the debug key so it installs on any phone for testing. To publish it on the Google Play Store you would create your own upload key and build an app bundle with `flutter build appbundle`, following the [Flutter Android release guide](https://docs.flutter.dev/deployment/android).

---

## Put the app on an iPhone

You need a Mac with Xcode installed.

1. Install CocoaPods if you do not have it: `sudo gem install cocoapods`.
2. Open the iOS project in Xcode:

```bash
open ios/Runner.xcworkspace
```

3. In Xcode select **Runner**, then **Signing and Capabilities**, choose your Apple ID under **Team** and, if Xcode complains, change the **Bundle Identifier** to something unique (for example add your initials to the end).
4. Plug in the iPhone, trust the computer on the phone, and turn on **Developer Mode** when iOS asks (Settings, Privacy and Security, Developer Mode).
5. Run it:

```bash
flutter run --release
```

6. The first time, open **Settings, General, VPN and Device Management** on the iPhone and trust your developer certificate, then open the app.

With a free Apple ID the app works for 7 days before it needs to be run again from Xcode. A paid Apple Developer account lets you share it through TestFlight using `flutter build ipa`.

---

## Run the tests

```bash
flutter analyze
flutter test
```

The tests in `test/lip_store_test.dart` run against a real SQLite database in memory and check signing up, sessions surviving a restart, logging in and out, duplicate emails, password resets, profile changes and product unlocks at the right milestones.

---

## How the data is stored

Everything lives in one SQLite file (`moist_me_up.db`) in the app's private storage on the phone, using the `sqflite` package. Deleting the app deletes the data.

| Table | What it holds |
|-------|---------------|
| `users` | Name, email, salted password hash, identity, lip shape, lip shade, active product, onboarding status |
| `sessions` | The one signed in account on this phone, so you stay logged in after closing the app |
| `applications` | One row per finished application, with the product used and the time |
| `unlocks` | Which products each account has unlocked, and when |

Level, streak and the "owned" and "new" labels are worked out from these tables whenever they are needed.

---

## Project structure

```
lib/
  main.dart                  App start, theme, and choosing the first screen from the saved session
  data/
    lip_store.dart           SQLite schema and every database read and write
    password_hasher.dart     Salted password hashing
  models/
    lip_style.dart           The four lip shapes and six shades
    product.dart             The six products, their packaging, colours and milestones
    user_profile.dart        Account and progress models
  state/
    app_state.dart           App wide state shared by every screen
  theme/
    app_colors.dart          Colours measured from the designs
    app_text.dart            Type styles (Inter)
  widgets/
    lips.dart                The lip painter (shapes, chapped and glossy states, swipe reveal, shine)
    product_art.dart         Packaging painter (tub, balm stick, lipstick, tube)
    decor.dart               Sparkles, drifting blobs, sparkle bursts, confetti
    motion.dart              Entrances, press feedback, shake, count up, page transitions
    common.dart              Buttons, fields, cards, panels, progress bar, bottom navigation
  screens/                   One file per screen listed above
assets/fonts/                Inter font files and their open font licence
test/                        Database tests
```

---

## Troubleshooting

* **`flutter devices` does not list my Android phone:** make sure USB debugging is on, try a different cable or port, and accept the "Allow USB debugging" prompt on the phone. On Windows, install the Google USB driver from Android Studio's SDK Manager.
* **Gradle or Android licence errors:** run `flutter doctor --android-licenses`, then `flutter clean` and `flutter pub get`, and try again.
* **`zip END header not found`, `did not have a source.properties file` or `Could not read workspace metadata`:** a download was cut off, almost always because the C: drive is full. Free up space, then move Gradle's downloads to another drive and delete the broken copy on C:. Run each line on its own in PowerShell, then open a new PowerShell window before building again:

```powershell
[Environment]::SetEnvironmentVariable('GRADLE_USER_HOME','D:\.gradle','User')
```

```powershell
Remove-Item -Recurse -Force "$env:USERPROFILE\.gradle"
```
* **iPhone says "Untrusted Developer":** trust your certificate under Settings, General, VPN and Device Management.
* **I forgot my password:** tap "Forgot password?" on the log in screen and confirm the name and email you signed up with. Because accounts only exist on the phone, there is no email reset.
* **Start fresh:** log out from the profile screen, or uninstall and reinstall the app to wipe all local data.

---

## Design credits

The design assets for this project were generated directly inside Figma. Inter is used under the SIL Open Font License (see `assets/fonts/Inter-OFL.txt`).
