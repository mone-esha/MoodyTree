#  MoodyTree

A simple, offline-first mood tracking app built with Flutter. Log how you're feeling each day with a swipeable mood picker, an optional note, and see your history laid out on a calendar, no account or sign-in required.

## Features

- Animated splash screen followed by a one-time name input
- Swipe through mood illustrations, pick one, and add an optional note
- See logged moods marked with color on a full month calendar; tap any past date to edit
-Bar chart (counts) and pie chart (percentages) of your moods, broken down by month
- Download your mood history as a JSON file and share it anywhere (Drive, email, etc.)
- No accounts, no sign-in, no cloud dependency; all data is stored locally on-device

## Screens

| Screen | Description |
|---|---|
| Splash | Shows the app logo on launch |
| Name Input | Collects the user's name once, on first launch |
| Select Mood | Swipeable mood picker with note field, used for both adding today's mood and editing past entries |
| Home (Calendar) | Month calendar with colored markers for logged days |
| Stats | Monthly bar and pie charts of mood distribution |

## Tech Stack

- **Framework:** [Flutter](https://flutter.dev) (Dart)
- **Local storage:** [`shared_preferences`](https://pub.dev/packages/shared_preferences)
- **Calendar UI:** [`table_calendar`](https://pub.dev/packages/table_calendar)
- **Charts:** [`fl_chart`](https://pub.dev/packages/fl_chart)
- **Page indicators:** [`smooth_page_indicator`](https://pub.dev/packages/smooth_page_indicator)
- **Theme toggle:** [`animated_toggle_switch`](https://pub.dev/packages/animated_toggle_switch)
- **Splash screen generation:** [`flutter_native_splash`](https://pub.dev/packages/flutter_native_splash)
- **Data export:** [`path_provider`](https://pub.dev/packages/path_provider) + [`share_plus`](https://pub.dev/packages/share_plus)

## Project Structure

```
lib/
├── main.dart                   # App entry point, theme setup
├── models/
│   └── mood_entry.dart         # Data model for a single mood entry
├── screens/
│   ├── splash_screen.dart
│   ├── name_input_screen.dart
│   ├── startup_decider.dart    # Routes to the correct screen on launch
│   ├── select_mood_screen.dart # Swipeable mood + note picker
│   ├── home_screen.dart        # Shell: app bar, drawer, bottom nav
│   ├── calendar_tab.dart       # Calendar view
│   └── stats_tab.dart          # Charts
├── services/
│   ├── storage_service.dart    # Read/write mood entries locally
│   └── export_service.dart     # JSON export + share
└── utils/
    └── mood_constants.dart     # Mood definitions (label, image, color)
```
## Screenshots
<img width="1434" height="744" alt="image" src="https://github.com/user-attachments/assets/6bf5d856-6e30-4c07-976b-4a9dee75210e" />

<img width="1600" height="1113" alt="image" src="https://github.com/user-attachments/assets/156d3629-3ad2-4208-b287-3fde06eb6634" />





## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed
- An Android emulator or physical device connected

### Setup

```bash
# Clone the repo
git clone https://github.com/<your-username>/mood_tracker.git
cd mood_tracker

# Install dependencies
flutter pub get

# Generate the native splash screen
dart run flutter_native_splash:create

# Run the app
flutter run
```

### Building a Release APK

```bash
flutter build apk --release
```

## Data & Privacy

All mood data is stored **locally on the device** using `shared_preferences`. Users can manually export their data as a JSON file via the sidebar's "Download Data" option and share/back it up however they like (e.g., saving to Google Drive through the native share sheet).


