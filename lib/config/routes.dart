/// Named route paths — single source of truth.
abstract final class Routes {
  // ── Auth ─────────────────────────────────────────────────────────────────
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const verifyOtp = '/verify-otp';
  static const contactForm = '/contact-form';
  static const profileSetup = '/profile-setup';
  static const treeCeremony = '/tree-ceremony';

  // ── Main tabs ─────────────────────────────────────────────────────────────
  static const home = '/home';
  static const learn = '/learn';
  static const mentor = '/mentor';
  static const forest = '/forest';
  static const upperRoom = '/upper-room';

  // ── Learn ──────────────────────────────────────────────────────────────────
  static const journey = '/learn/journey';
  static const lesson = '/learn/lesson'; // + /:id
  static const memoryVerse = '/learn/verse'; // + /:id

  // ── Mentor / matching ──────────────────────────────────────────────────────
  static const matchPaths = '/mentor/find';
  static const invitePeer = '/mentor/invite';
  static const discoverySearch = '/mentor/discover';
  static const smartMatch = '/mentor/smart-match';
  static const groupJoin = '/mentor/group';
  static const mentorDashboard = '/mentor/dashboard';
  static const sessionScheduler = '/mentor/schedule';
  static const activeSession = '/mentor/session'; // + /:id

  // ── Forest ────────────────────────────────────────────────────────────────
  static const personalForest = '/forest/personal';
  static const globalHeatmap = '/forest/global';

  // ── Upper Room ────────────────────────────────────────────────────────────
  static const rootPrayer = '/prayer';
  static const liveRooms = '/prayer/rooms';
  static const nationWall = '/prayer/nations';

  // ── Fruit / gamification ──────────────────────────────────────────────────
  static const fruitCollection = '/fruit';
  static const hallOfFaith = '/faith';

  // ── Missions ──────────────────────────────────────────────────────────────
  static const missions = '/missions';
  static const weeklyChallenge = '/missions/challenge';
  static const megaHarvest = '/missions/harvest';

  // ── Curriculum ────────────────────────────────────────────────────────────
  static const curriculum = '/curriculum';           // list
  static const curriculumModules = '/curriculum/modules';  // ?id=<curriculumId>
  static const curriculumLessons = '/curriculum/lessons';  // ?id=<moduleId>
  static const curriculumReader  = '/curriculum/reader';   // ?id=<lessonId>
}
