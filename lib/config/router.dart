import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/onboarding_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/contact_form_screen.dart';
import '../features/auth/screens/profile_setup_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/learn/screens/module_journey_screen.dart';
import '../features/learn/screens/lesson_screen.dart';
import '../features/learn/screens/memory_verse_trainer.dart';
import '../features/mentor/screens/mentor_dashboard.dart';
import '../features/mentor/screens/session_scheduler.dart';
import '../features/matching/screens/match_path_selector.dart';
import '../features/matching/screens/invite_peer_screen.dart';
import '../features/matching/screens/discovery_search_screen.dart';
import '../features/matching/screens/smart_match_screen.dart';
import '../features/matching/screens/group_join_screen.dart';
import '../features/forest/screens/personal_forest_screen.dart';
import '../features/forest/screens/global_heatmap_screen.dart';
import '../features/upper_room/screens/root_prayer_screen.dart';
import '../features/upper_room/screens/live_prayer_rooms.dart';
import '../features/upper_room/screens/nation_prayer_wall.dart';
import '../features/fruit/screens/fruit_collection_screen.dart';
import '../features/missions/screens/missions_hub.dart';
import '../features/missions/screens/weekly_challenge.dart';
import '../features/stubs/verify_otp_screen.dart';
import '../features/stubs/tree_ceremony_screen.dart';
import '../features/stubs/active_session_screen.dart';
import '../features/stubs/hall_of_faith_screen.dart';
import '../features/stubs/mega_harvest_screen.dart';
import 'routes.dart';

// ── Auth-state listenable ─────────────────────────────────────────────────────

/// Bridges Supabase's auth stream into a [ChangeNotifier] so GoRouter can
/// re-evaluate redirect rules whenever the session changes.
class _SupabaseAuthNotifier extends ChangeNotifier {
  _SupabaseAuthNotifier() {
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }

  late final dynamic _sub; // AuthSubscription

  bool get isAuthenticated =>
      Supabase.instance.client.auth.currentSession != null;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

// ── Public router instance ────────────────────────────────────────────────────

/// Top-level GoRouter singleton consumed by [P2PBibleStudyApp].
final GoRouter appRouter = _buildRouter();

GoRouter _buildRouter() {
  final authNotifier = _SupabaseAuthNotifier();

  // Routes that don't require authentication.
  const _publicRoutes = {
    Routes.splash,
    Routes.onboarding,
    Routes.login,
    Routes.register,
    Routes.verifyOtp,
  };

  return GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final isAuth = authNotifier.isAuthenticated;
      final loc = state.matchedLocation;

      // Redirect unauthenticated users away from protected screens.
      if (!isAuth && !_publicRoutes.contains(loc)) {
        return Routes.onboarding;
      }
      // No redirect needed.
      return null;
    },
    routes: [
      // ── Auth flow ──────────────────────────────────────────────────────
      GoRoute(
        path: Routes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.register,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: Routes.verifyOtp,
        builder: (_, __) => const VerifyOtpScreen(),
      ),
      GoRoute(
        path: Routes.contactForm,
        builder: (_, __) => const ContactFormScreen(),
      ),
      GoRoute(
        path: Routes.profileSetup,
        builder: (_, __) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: Routes.treeCeremony,
        builder: (_, __) => const TreeCeremonyScreen(),
      ),

      // ── Home ───────────────────────────────────────────────────────────
      GoRoute(
        path: Routes.home,
        builder: (_, __) => const HomeScreen(),
      ),

      // ── Learn ──────────────────────────────────────────────────────────
      GoRoute(
        path: Routes.journey,
        builder: (_, __) => const ModuleJourneyScreen(),
      ),
      GoRoute(
        path: Routes.lesson,
        builder: (_, state) {
          final id = state.uri.queryParameters['id'] ?? '';
          return LessonScreen(lessonId: id);
        },
      ),
      GoRoute(
        path: Routes.memoryVerse,
        builder: (_, state) {
          final id = state.uri.queryParameters['id'] ?? '';
          return MemoryVerseTrainer(verseId: id);
        },
      ),

      // ── Mentor / Matching ──────────────────────────────────────────────
      GoRoute(
        path: Routes.mentorDashboard,
        builder: (_, __) => const MentorDashboard(),
      ),
      GoRoute(
        path: Routes.sessionScheduler,
        builder: (_, __) => const SessionScheduler(),
      ),
      GoRoute(
        path: Routes.activeSession,
        builder: (_, __) => const ActiveSessionScreen(),
      ),
      GoRoute(
        path: Routes.matchPaths,
        builder: (_, __) => const MatchPathSelector(),
      ),
      GoRoute(
        path: Routes.invitePeer,
        builder: (_, __) => const InvitePeerScreen(),
      ),
      GoRoute(
        path: Routes.discoverySearch,
        builder: (_, __) => const DiscoverySearchScreen(),
      ),
      GoRoute(
        path: Routes.smartMatch,
        builder: (_, __) => const SmartMatchScreen(),
      ),
      GoRoute(
        path: Routes.groupJoin,
        builder: (_, __) => const GroupJoinScreen(),
      ),

      // ── Forest ─────────────────────────────────────────────────────────
      GoRoute(
        path: Routes.personalForest,
        builder: (_, __) => const PersonalForestScreen(),
      ),
      GoRoute(
        path: Routes.globalHeatmap,
        builder: (_, __) => const GlobalHeatmapScreen(),
      ),

      // ── Upper Room / Prayer ────────────────────────────────────────────
      GoRoute(
        path: Routes.rootPrayer,
        builder: (_, __) => const RootPrayerScreen(),
      ),
      GoRoute(
        path: Routes.liveRooms,
        builder: (_, __) => const LivePrayerRoomsScreen(),
      ),
      GoRoute(
        path: Routes.nationWall,
        builder: (_, __) => const NationPrayerWallScreen(),
      ),

      // ── Fruit / Gamification ───────────────────────────────────────────
      GoRoute(
        path: Routes.fruitCollection,
        builder: (_, __) => const FruitCollectionScreen(),
      ),
      GoRoute(
        path: Routes.hallOfFaith,
        builder: (_, __) => const HallOfFaithScreen(),
      ),

      // ── Missions ───────────────────────────────────────────────────────
      GoRoute(
        path: Routes.missions,
        builder: (_, __) => const MissionsHub(),
      ),
      GoRoute(
        path: Routes.weeklyChallenge,
        builder: (_, __) => const WeeklyChallenge(),
      ),
      GoRoute(
        path: Routes.megaHarvest,
        builder: (_, __) => const MegaHarvestScreen(),
      ),
    ],
    errorBuilder: (_, state) => _RouterErrorScreen(state.error),
  );
}

// ── 404 screen ────────────────────────────────────────────────────────────────

class _RouterErrorScreen extends StatelessWidget {
  final Exception? error;
  const _RouterErrorScreen(this.error);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Page not found',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                error?.toString() ?? 'Unknown route',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => GoRouter.of(context).go(Routes.home),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
