# Pass It On

## GitHub Pages deployment

The `Deploy Pass It On to GitHub Pages` workflow runs on every push or merge to
`main`. It installs Flutter 3.47.2, resolves the committed dependency lockfile,
runs the widget tests, builds the release web app, and publishes the successful
build through the `github-pages` environment. Pull requests to `main` run the
same tests and build without deploying. A failed test or build leaves the
previous website in place. Concurrent updates deploy the latest main commit.

One-time repository setup: open **Settings → Pages**, set **Source** to
**GitHub Actions**, and save. The repository is public, so Pages can host it
without a private-repository plan upgrade. If it is made private later, the
GitHub plan must support Pages for private repositories.

The default site URL is https://gkcse14.github.io/passiton/. The workflow uses
`/passiton/` as the base path and Flutter's default hash navigation so refreshing
an app route works on GitHub Pages. If a custom domain is added, update the
workflow's `--base-href` argument to `/`.

To redeploy the current main commit, open **Actions → Deploy Pass It On to
GitHub Pages → Run workflow** and choose `main`. No deployment secret is needed;
GitHub provides a short-lived token with Pages and OIDC permissions to the
deployment job.

To validate locally:

```bash
flutter pub get --enforce-lockfile
flutter test --no-pub
flutter build web --release --no-pub --base-href /passiton/
```

The web app remains a device-local preview: it uses browser storage for its demo
journeys and preferences. GitHub Pages hosts the app but does not add a backend.

A modern Flutter-based mobile application utilizing the latest mobile development technologies and tools for building responsive cross-platform applications.

## 📋 Prerequisites

- Flutter SDK (3.47.2, matching CI)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android SDK / Xcode (for iOS development)

## 🛠️ Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Run the application:
```bash
flutter run
```

## 📁 Project Structure

```
flutter_app/
├── android/            # Android-specific configuration
├── ios/                # iOS-specific configuration
├── lib/
│   ├── core/           # Core utilities and services
│   │   └── utils/      # Utility classes
│   ├── presentation/   # UI screens and widgets
│   │   └── splash_screen/ # Splash screen implementation
│   ├── routes/         # Application routing
│   ├── theme/          # Theme configuration
│   ├── widgets/        # Reusable UI components
│   └── main.dart       # Application entry point
├── assets/             # Static assets (images, fonts, etc.)
├── pubspec.yaml        # Project dependencies and configuration
└── README.md           # Project documentation
```

## 🧩 Adding Routes

To add new routes to the application, update the `lib/routes/app_routes.dart` file:

```dart
import 'package:flutter/material.dart';
import 'package:package_name/presentation/home_screen/home_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String home = '/home';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    home: (context) => const HomeScreen(),
    // Add more routes as needed
  }
}
```

## 🎨 Theming

This project includes a comprehensive theming system with both light and dark themes:

```dart
// Access the current theme
ThemeData theme = Theme.of(context);

// Use theme colors
Color primaryColor = theme.colorScheme.primary;
```

The theme configuration includes:
- Color schemes for light and dark modes
- Typography styles
- Button themes
- Input decoration themes
- Card and dialog themes

## 📱 Responsive Design

The app is built with responsive design using the Sizer package:

```dart
// Example of responsive sizing
Container(
  width: 50.w, // 50% of screen width
  height: 20.h, // 20% of screen height
  child: Text('Responsive Container'),
)
```
## 📦 Deployment

Build the application for production:

```bash
# For Android
flutter build apk --release

# For iOS
flutter build ios --release
```

## Journeys discovery

Journeys uses optional device location or a chosen city to rank active objects
within 50 km (expandable to 250 km or everywhere). Only the latest city-visible
stop with coordinates is eligible. Hidden and country-only stops never reveal an
earlier location. Distances to city locations are approximate. Device coordinates
are neither persisted nor published. A manually chosen city is saved.

Creation, saved objects, and joined chapters persist in device-local storage.
Seeded journeys are labelled **Preview**. There is no shared account/backend yet:
newly created journeys and participation are not synchronized across users.
Preview invitations have reload-safe detail links; local-journey invitations
link to the app rather than implying another device can retrieve local data.
Known origin cities can appear in local nearby discovery; other origins without
coordinates remain available in Everywhere. New joined chapters hide location.

Every pull request runs the interaction/repository tests and builds Flutter web.
Merging to `main` automatically publishes the release to
[GitHub Pages](https://gkcse14.github.io/passiton/).

## App experience

The app uses a shared Material 3 design in light and dark mode. Mobile has a fixed
three-tab navigation bar; desktop has a sidebar and comfortable content widths.
System text size is respected, and reduced motion applies to artwork and routes.

- **Journeys:** discover nearby objects, choose a city, and revisit started,
  joined, or saved journeys.
- **Explore:** search names and missions, filter by object or saved state, and
  sort by newest, name, or support. Creations and saves use the same repository
  as journey details and profile activity.
- **Create:** choose an object, add a name and mission, then review. Opening notes
  and goals are optional. Location defaults to hidden, or the preference in You.
- **You:** edit the name used for new chapters and gifts, view live activity,
  choose appearance and accessibility preferences, and reset local data.
- **Journey details:** read the timeline and map, save a journey, join with a note,
  give a preview gift, and copy an invitation. Local-only invitations explain
  that another device cannot retrieve the local journey.

Resetting restores sample journeys and gifts in memory and storage, removes local
preferences, and returns to the introduction. The app remains a device-local
preview; cloud accounts, cross-device sync, notifications, and real payments are
not implemented.

Tests cover persistence, profile preferences, search/save interactions, creation,
joining, reset, and compact/desktop/dark/large-text layouts. To export widget
renders while running the tests:

```bash
PASSITON_TEST_FONT=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf \
  flutter test --no-pub --dart-define=PASSITON_PREVIEW_DIR=/tmp/passiton-previews
```

## 🙏 Acknowledgments
- Built with [Rocket.new](https://rocket.new)
- Powered by [Flutter](https://flutter.dev) & [Dart](https://dart.dev)
- Styled with Material Design

Built with ❤️ on Rocket.new
