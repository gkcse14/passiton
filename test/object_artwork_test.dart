import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:passiton/core/repositories/journey_repository.dart';
import 'package:passiton/core/services/nearby_journeys.dart';
import 'package:passiton/presentation/create_journey_screen/create_journey_screen.dart';
import 'package:passiton/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:passiton/core/models/journey_models.dart';
import 'package:passiton/core/repositories/gift_repository.dart';
import 'package:passiton/presentation/onboarding_screen/onboarding_screen.dart';
import 'package:passiton/presentation/onboarding_screen/widgets/object_artwork_widget.dart';
import 'package:passiton/presentation/create_journey_screen/widgets/object_picker_widget.dart';
import 'package:passiton/presentation/journeys_screen/journeys_screen.dart';
import 'package:passiton/presentation/explore_screen/explore_screen.dart';
import 'package:passiton/presentation/journey_detail_screen/journey_detail_screen.dart';
import 'package:passiton/presentation/you_screen/you_screen.dart';
import 'package:passiton/widgets/immersive_artwork.dart';
import 'package:passiton/theme/app_theme.dart';

const _names = ['potato', 'heart', 'lotus', 'plane', 'star', 'seedling'];
const _captureDir = String.fromEnvironment('PASSITON_PREVIEW_DIR');
const _previewFont = String.fromEnvironment('PASSITON_PREVIEW_FONT');
final _boundary = GlobalKey();

class _DeniedLocation extends NearbyLocationService {
  @override
  Future<DiscoveryArea> locate() async =>
      throw LocationIssue('Location denied. Choose a city instead.');
}

// Offline layout typography; the production theme continues using DM Sans.
ThemeData _theme(bool dark) => ThemeData(
  useMaterial3: true,
  brightness: dark ? Brightness.dark : Brightness.light,
  fontFamily: 'DM Sans',
  scaffoldBackgroundColor: dark
      ? AppTheme.backgroundDark
      : AppTheme.backgroundLight,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppTheme.primary,
    brightness: dark ? Brightness.dark : Brightness.light,
  ),
  textTheme: TextTheme(
    headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
    headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    bodyLarge: TextStyle(fontSize: 15),
    bodyMedium: TextStyle(fontSize: 14),
    bodySmall: TextStyle(fontSize: 13),
  ).apply(fontFamily: 'DM Sans'),
);

Future<void> _render(
  WidgetTester tester,
  Widget screen,
  String name, {
  Size size = const Size(390, 844),
  bool dark = false,
}) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  await tester.pumpWidget(
    MaterialApp(
      theme: _theme(dark),
      home: RepaintBoundary(key: _boundary, child: screen),
    ),
  );
  await tester.runAsync(() async {
    for (final image in tester.widgetList<Image>(find.byType(Image)).toList()) {
      await precacheImage(
        image.image,
        tester.element(find.byType(RepaintBoundary).first),
      );
    }
  });
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  await tester.pump(const Duration(milliseconds: 50));
  expect(tester.takeException(), isNull, reason: name);
  if (_captureDir.isNotEmpty) {
    await tester.runAsync(() async {
      final boundary =
          _boundary.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await Directory(_captureDir).create(recursive: true);
      await File(
        '$_captureDir/$name.png',
      ).writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }
  await tester.pumpWidget(const SizedBox.shrink());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await GiftRepository().init();
    await JourneyRepository.instance.init();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    // Flutter's default Ahem test font has square glyphs, unlike app fonts.
    // Use real offline typography: CI supplies a Linux system font and local
    // captures may override it. Windows can use the SDK's bundled Roboto.
    final artifacts = File(Platform.resolvedExecutable).parent.parent.parent;
    final ciFont = Platform.environment['PASSITON_TEST_FONT'] ?? '';
    final fontPath = _previewFont.isNotEmpty
        ? _previewFont
        : ciFont.isNotEmpty
        ? ciFont
        : '${artifacts.path}/material_fonts/roboto-regular.ttf';
    final bytes = await File(fontPath).readAsBytes();
    final loader = FontLoader('DM Sans')
      ..addFont(Future.value(ByteData.sublistView(bytes)));
    await loader.load();
  });

  testWidgets('all six locally bundled renders decode successfully', (
    tester,
  ) async {
    await tester.runAsync(() async {
      for (final name in _names) {
        final bytes = await rootBundle.load(
          'assets/images/object-$name-3d.webp',
        );
        final codec = await ui.instantiateImageCodec(
          bytes.buffer.asUint8List(),
        );
        final frame = await codec.getNextFrame();
        expect(frame.image.width, greaterThanOrEqualTo(512));
        expect(frame.image.height, greaterThanOrEqualTo(512));
        frame.image.dispose();
        codec.dispose();
      }
    });
  });

  testWidgets('reduced motion settles and artwork preserves parent taps', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: GestureDetector(
            onTap: () => taps++,
            child: const Center(
              child: ObjectArtworkWidget(type: ObjectType.heart, size: 160),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.binding.transientCallbackCount, 0);
    await tester.tap(find.byType(ImmersiveArtwork));
    await tester.pumpAndSettle();
    expect(taps, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'picker selects every object on a compact phone without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      ObjectType? selected;
      await tester.pumpWidget(
        MaterialApp(
          theme: _theme(false),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => ObjectPickerWidget(
                selectedType: selected,
                onSelect: (value) => setState(() => selected = value),
              ),
            ),
          ),
        ),
      );
      for (final type in ObjectType.values) {
        final label = find.text(type.displayName);
        await tester.ensureVisible(label);
        await tester.pump(const Duration(milliseconds: 400));
        await tester.tap(label);
        await tester.pump(const Duration(milliseconds: 400));
        expect(selected, type);
        expect(tester.takeException(), isNull, reason: type.displayName);
      }
    },
  );

  testWidgets('object screens render in light, dark, and compact layouts', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _render(tester, const OnboardingScreen(), 'onboarding');
    await _render(
      tester,
      Scaffold(
        body: ObjectPickerWidget(
          selectedType: ObjectType.potato,
          onSelect: (_) {},
        ),
      ),
      'objects',
    );
    await _render(tester, const JourneysScreen(), 'journeys');
    await _render(
      tester,
      const JourneysScreen(),
      'journeys-compact',
      size: const Size(320, 640),
    );
    await _render(
      tester,
      const JourneysScreen(),
      'journeys-desktop',
      size: const Size(1200, 900),
    );
    await _render(tester, const ExploreScreen(), 'explore');
    await _render(
      tester,
      const JourneyDetailScreen(journeyId: 'journey-001'),
      'detail',
    );
    await _render(tester, const YouScreen(), 'profile');
    await _render(tester, const JourneysScreen(), 'journeys-dark', dark: true);
    await _render(
      tester,
      const JourneyDetailScreen(journeyId: 'journey-004'),
      'detail-dark',
      dark: true,
    );
    await _render(
      tester,
      const OnboardingScreen(),
      'onboarding-compact',
      size: const Size(320, 640),
    );
  });

  testWidgets(
    'location denial still allows choosing a city and saving an object',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final repo = JourneyRepository();
      await repo.init();
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: _theme(false),
          home: JourneysScreen(
            repository: repo,
            locationService: _DeniedLocation(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Find objects near you'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Use my location'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(
        find.text('Location denied. Choose a city instead.'),
        findsOneWidget,
      );
      await tester.enterText(find.byType(TextField), 'Mumbai');
      await tester.pump();
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pump();
      await tester.ensureVisible(find.widgetWithText(ListTile, 'Mumbai'));
      await tester.pump();
      expect(tester.takeException(), isNull);
      await tester.tap(find.widgetWithText(ListTile, 'Mumbai'));
      tester.view.resetViewInsets();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Around your corner'), findsOneWidget);
      final save = find.byTooltip('Save Seeds of Hope');
      await tester.ensureVisible(save);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(save);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(repo.find('journey-005')!.isFollowed, isTrue);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('create wizard opens the newly saved journey, not a sample', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: AppRoutes.createJourneyScreen,
      routes: [
        GoRoute(
          path: AppRoutes.createJourneyScreen,
          builder: (_, _) => const CreateJourneyScreen(),
        ),
        GoRoute(
          path: AppRoutes.journeyDetailScreen,
          builder: (_, state) =>
              JourneyDetailScreen(journeyId: state.uri.queryParameters['id']!),
        ),
      ],
    );
    addTearDown(router.dispose);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp.router(theme: _theme(false), routerConfig: router),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Potato'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.enterText(
      find.byType(TextField).at(0),
      'Little Test Traveller',
    );
    await tester.enterText(
      find.byType(TextField).at(1),
      'Share a kind word today',
    );
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Start its journey'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    final id = router.routeInformationProvider.value.uri.queryParameters['id'];
    expect(id, isNotNull);
    expect(JourneyRepository.instance.find(id!)!.name, 'Little Test Traveller');
    expect(find.text('Little Test Traveller'), findsWidgets);
    expect(find.text('Pass it on'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('join adds a chapter and unlocks the pass-it-on action', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: _theme(false),
        home: const JourneyDetailScreen(journeyId: 'journey-006'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Join this journey'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.enterText(find.byType(TextField), 'A little kindness from me');
    await tester.ensureVisible(find.text('Join the journey'));
    await tester.tap(find.text('Join the journey'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('You’re part of the story.'), findsOneWidget);
    await tester.tap(find.text('See my chapter'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Pass it on'), findsOneWidget);
    expect(
      JourneyRepository.instance.stops.any(
        (s) =>
            s.objectId == 'journey-006' &&
            s.message == 'A little kindness from me',
      ),
      isTrue,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
