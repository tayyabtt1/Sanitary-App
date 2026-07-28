/// Central place for simple app-wide toggles.
///
/// Set [useDummyData] to false once you start entering the client's
/// real 40-50 products, so dummy products never get seeded again on
/// a fresh install/reset. Leave it true during development/demos.
class AppConfig {
  static const bool useDummyData = true;
}