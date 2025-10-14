# Flutter Test Suite Cleanup

_Date: 2025-10-08_

## Summary

- Removed the legacy `test/` directory, which only contained outdated integration/widget suites and helper scaffolding tied to pre-gateway architectures.
- Files removed (prior to the directory deletion) included:
  - `test/backend_integration_test.dart`
  - `test/complete_user_upload_experience_test.dart`
  - `test/focused_user_experience_test.dart`
  - `test/photo_service_test.dart`
  - `test/photo_service_test.mocks.dart`
  - `test/photo_upload_screen_test.dart`
  - `test/real_photo_upload_integration_test.dart`
  - `test/simple_cache_ui_test.dart`
  - `test/smart_cache_demo_real_test.dart`
  - `test/widget_test.dart`
  - `test/api_services_test.dart`
  - `test/enhanced_profile_photo_grid_test.dart`

## Rationale

- Tests relied on hard-coded 5xxx ports, conflicting with the current 8xxx service configuration.
- Several suites used deprecated Flutter finder APIs (`description`) and generated lint failures (`avoid_print`, unused mocks), preventing clean analyzer runs.
- Photo upload flows exercised old widgets and mocked services that no longer exist after the gateway consolidation.

## Next Steps

1. Stand up a fresh `test/` tree focused on:

- DTO/model serialization round-trips against the gateway contracts.
- Service-layer contract tests that hit the YARP gateway (mocking HTTP where appropriate).

2. Introduce lightweight golden/widget smoke tests once the new profile photo grid implementation stabilizes.
3. Establish an analyzer/test harness baseline (CI task + lint rules) after the new suites are committed to avoid future drift.
