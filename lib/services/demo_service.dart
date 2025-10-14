class DemoService {
  const DemoService._();

  static Never _unsupported() => throw UnsupportedError(
        'DemoService has been removed. Use Keycloak-backed services instead.',
      );

  static Never initializeDemoEnvironment() => _unsupported();
  static Never loginWithDemoUser(String email) => _unsupported();
  static Never getDemoProfiles(String token) => _unsupported();
  static Never getMatches(String token, int userId) => _unsupported();
}
