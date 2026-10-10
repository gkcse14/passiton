import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../presentation/onboarding_screen/onboarding_screen.dart';
import '../presentation/journeys_screen/journeys_screen.dart';
import '../presentation/journey_detail_screen/journey_detail_screen.dart';
import '../presentation/create_journey_screen/create_journey_screen.dart';
import '../presentation/explore_screen/explore_screen.dart';
import '../presentation/you_screen/you_screen.dart';
import '../widgets/app_scaffold.dart';

class AppRoutes {
  static const String initial = '/';
  static const String onboardingScreen = '/onboarding-screen';
  static const String journeysScreen = '/journeys-screen';
  static const String journeyDetailScreen = '/journey-detail-screen';
  static const String createJourneyScreen = '/create-journey-screen';
  static const String exploreScreen = '/explore-screen';
  static const String youScreen = '/you-screen';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.initial,
  routes: [
    GoRoute(
      path: AppRoutes.initial,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const _RootRedirector(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: child,
          );
        },
        transitionDuration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 280),
      ),
    ),
    GoRoute(
      path: AppRoutes.onboardingScreen,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const OnboardingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: child,
          );
        },
        transitionDuration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 280),
      ),
    ),
    GoRoute(
      path: AppRoutes.journeyDetailScreen,
      pageBuilder: (context, state) {
        final journeyId =
            state.uri.queryParameters['id'] ?? state.extra as String? ?? '';
        return CustomTransitionPage(
          key: state.pageKey,
          child: JourneyDetailScreen(journeyId: journeyId),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
          transitionDuration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 280),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.createJourneyScreen,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const CreateJourneyScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.journeysScreen,
              builder: (context, state) => const JourneysScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.exploreScreen,
              builder: (context, state) => const ExploreScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.youScreen,
              builder: (context, state) => const YouScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class _RootRedirector extends StatefulWidget {
  const _RootRedirector();

  @override
  State<_RootRedirector> createState() => _RootRedirectorState();
}

class _RootRedirectorState extends State<_RootRedirector> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('onboarding_seen') ?? false;
    if (!mounted) return;
    if (seen) {
      context.go(AppRoutes.journeysScreen);
    } else {
      context.go(AppRoutes.onboardingScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
