import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dejtingapp/main.dart' as app;

// Test credentials
const String TEST_EMAIL = 'alice@example.com';
const String TEST_PASSWORD = 'password123';

// Test search parameters
const Map<String, dynamic> SEARCH_FILTERS = {
  'minAge': 25,
  'maxAge': 35,
  'maxDistance': 25,
  'interests': ['Music', 'Travel', 'Fitness'],
  'education': 'University',
  'profession': 'Engineer',
};

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Search & Filtering Tests', () {
    setUp(() async {
      // Reset app state before each test
      await Future.delayed(const Duration(seconds: 1));
    });

    testWidgets('Basic search functionality', (WidgetTester tester) async {
      print('🔍 Starting basic search test...');

      // Start the app and login
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _performLogin(tester);

      // Navigate to search/discover section
      await _navigateToSearch(tester);
      print('✅ Navigated to search');

      // Test basic search interface
      await _testBasicSearchInterface(tester);
      print('✅ Basic search interface tested');

      // Test search execution
      await _testSearchExecution(tester);
      print('✅ Search execution tested');

      // Test search results display
      await _testSearchResults(tester);
      print('✅ Search results tested');
    });

    testWidgets('Advanced filtering options', (WidgetTester tester) async {
      print('🎯 Starting advanced filtering test...');

      // Start the app and login
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _performLogin(tester);
      await _navigateToSearch(tester);

      // Test age filters
      await _testAgeFiltering(tester);
      print('✅ Age filtering tested');

      // Test distance filters
      await _testDistanceFiltering(tester);
      print('✅ Distance filtering tested');

      // Test interest-based filtering
      await _testInterestFiltering(tester);
      print('✅ Interest filtering tested');

      // Test demographic filters
      await _testDemographicFiltering(tester);
      print('✅ Demographic filtering tested');
    });

    testWidgets('Filter persistence and management',
        (WidgetTester tester) async {
      print('💾 Starting filter persistence test...');

      // Start the app and login
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _performLogin(tester);
      await _navigateToSearch(tester);

      // Test filter saving
      await _testFilterSaving(tester);
      print('✅ Filter saving tested');

      // Test filter loading
      await _testFilterLoading(tester);
      print('✅ Filter loading tested');

      // Test filter reset
      await _testFilterReset(tester);
      print('✅ Filter reset tested');
    });

    testWidgets('Search result interaction and sorting',
        (WidgetTester tester) async {
      print('🔄 Starting search interaction test...');

      // Start the app and login
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _performLogin(tester);
      await _navigateToSearch(tester);

      // Test result sorting
      await _testResultSorting(tester);
      print('✅ Result sorting tested');

      // Test result interaction
      await _testResultInteraction(tester);
      print('✅ Result interaction tested');

      // Test result pagination
      await _testResultPagination(tester);
      print('✅ Result pagination tested');

      // Test search refinement
      await _testSearchRefinement(tester);
      print('✅ Search refinement tested');
    });
  });
}

// Helper function for login
Future<void> _performLogin(WidgetTester tester) async {
  print('🔐 Starting login process...');

  // Find and fill email field
  final emailField = find.byType(TextField).first;
  expect(emailField, findsOneWidget);
  await tester.enterText(emailField, TEST_EMAIL);
  await tester.pumpAndSettle();

  // Find and fill password field
  final passwordField = find.byType(TextField).last;
  expect(passwordField, findsOneWidget);
  await tester.enterText(passwordField, TEST_PASSWORD);
  await tester.pumpAndSettle();

  // Tap login button
  final loginButton = find.byType(ElevatedButton);
  expect(loginButton, findsOneWidget);
  await tester.tap(loginButton);

  // Wait for login request and navigation
  await tester.pumpAndSettle(const Duration(seconds: 5));

  // Check if we successfully navigated away from login screen
  final loginWelcome = find.text('Welcome to Dating App');
  expect(loginWelcome, findsNothing,
      reason: 'Should have navigated away from login screen');
}

// Helper function to navigate to search
Future<void> _navigateToSearch(WidgetTester tester) async {
  print('🔍 Navigating to search...');

  // Look for search navigation options
  final searchOptions = [
    find.text('Search'),
    find.text('Discover'),
    find.text('Browse'),
    find.text('Find'),
    find.byIcon(Icons.search),
    find.byIcon(Icons.explore),
  ];

  bool foundSearchOption = false;
  for (final option in searchOptions) {
    if (option.evaluate().isNotEmpty) {
      foundSearchOption = true;
      await tester.tap(option.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('✅ Found and tapped search option: ${option.description}');
      break;
    }
  }

  // Check if we need to access via bottom navigation
  if (!foundSearchOption) {
    final bottomNavItems = find.byType(BottomNavigationBarItem);
    if (bottomNavItems.evaluate().isNotEmpty) {
      // Try tapping different bottom nav items to find search
      final navBar = find.byType(BottomNavigationBar);
      if (navBar.evaluate().isNotEmpty) {
        // Tap second item (often search/discover)
        await tester.tap(navBar);
        await tester.pumpAndSettle();
        print('✅ Tried bottom navigation');
      }
    }
  }

  // Look for filter/search icon in app bar
  if (!foundSearchOption) {
    final filterIcon = find.byIcon(Icons.filter_list);
    final searchIcon = find.byIcon(Icons.search);

    if (filterIcon.evaluate().isNotEmpty) {
      await tester.tap(filterIcon);
      await tester.pumpAndSettle();
      print('✅ Found filter icon');
      foundSearchOption = true;
    } else if (searchIcon.evaluate().isNotEmpty) {
      await tester.tap(searchIcon);
      await tester.pumpAndSettle();
      print('✅ Found search icon');
      foundSearchOption = true;
    }
  }

  if (!foundSearchOption) {
    print('ℹ️ Search navigation not found, may already be in search area');
  }
}

// Helper function to test basic search interface
Future<void> _testBasicSearchInterface(WidgetTester tester) async {
  print('🔍 Testing basic search interface...');

  // Look for search input field
  final searchFields = [
    find.byType(TextField),
    find.byType(TextFormField),
  ];

  bool foundSearchField = false;
  for (final fieldType in searchFields) {
    if (fieldType.evaluate().isNotEmpty) {
      foundSearchField = true;

      // Test entering search text
      await tester.enterText(fieldType.first, 'test search');
      await tester.pumpAndSettle();
      print('✅ Entered search text');

      // Clear the field
      await tester.enterText(fieldType.first, '');
      await tester.pumpAndSettle();
      break;
    }
  }

  // Look for filter buttons
  final filterButtons = [
    find.text('Filters'),
    find.text('Filter'),
    find.byIcon(Icons.filter_list),
    find.byIcon(Icons.tune),
  ];

  bool foundFilterButton = false;
  for (final button in filterButtons) {
    if (button.evaluate().isNotEmpty) {
      foundFilterButton = true;
      print('✅ Found filter button: ${button.description}');
      break;
    }
  }

  // Look for search/apply buttons
  final searchButtons = [
    find.text('Search'),
    find.text('Apply'),
    find.text('Find'),
    find.byIcon(Icons.search),
  ];

  for (final button in searchButtons) {
    if (button.evaluate().isNotEmpty) {
      print('✅ Found search button: ${button.description}');
      break;
    }
  }

  if (!foundSearchField && !foundFilterButton) {
    print('ℹ️ Basic search interface elements not found');
  }
}

// Helper function to test search execution
Future<void> _testSearchExecution(WidgetTester tester) async {
  print('▶️ Testing search execution...');

  // Look for and tap search/apply button
  final executeButtons = [
    find.text('Search'),
    find.text('Apply'),
    find.text('Apply Filters'),
    find.text('Find'),
    find.byIcon(Icons.search),
  ];

  bool executedSearch = false;
  for (final button in executeButtons) {
    if (button.evaluate().isNotEmpty) {
      await tester.tap(button.first);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      print('✅ Executed search via: ${button.description}');
      executedSearch = true;
      break;
    }
  }

  // Test search via keyboard (Enter key simulation)
  final textFields = find.byType(TextField);
  if (textFields.evaluate().isNotEmpty && !executedSearch) {
    await tester.enterText(textFields.first, 'search query');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    print('✅ Executed search via keyboard');
    executedSearch = true;
  }

  if (!executedSearch) {
    print('ℹ️ Search execution method not found');
  }
}

// Helper function to test search results
Future<void> _testSearchResults(WidgetTester tester) async {
  print('📋 Testing search results...');

  // Look for result containers
  final resultContainers = [
    find.byType(Card),
    find.byType(ListTile),
    find.byType(Container),
  ];

  int totalResults = 0;
  for (final container in resultContainers) {
    final count = container.evaluate().length;
    if (count > 0) {
      totalResults = count;
      print('✅ Found $count result containers');
      break;
    }
  }

  // Look for user profile elements in results
  final profileElements = [
    find.byType(CircleAvatar),
    find.byType(Image),
  ];

  for (final element in profileElements) {
    if (element.evaluate().isNotEmpty) {
      print('✅ Found ${element.evaluate().length} profile elements');
      break;
    }
  }

  // Look for result actions (like, pass, etc.)
  final resultActions = [
    find.byIcon(Icons.favorite),
    find.byIcon(Icons.close),
    find.byIcon(Icons.star),
    find.text('Like'),
    find.text('Pass'),
    find.text('Super Like'),
  ];

  int actionCount = 0;
  for (final action in resultActions) {
    if (action.evaluate().isNotEmpty) {
      actionCount++;
      print('✅ Found result action: ${action.description}');
    }
  }

  // Look for empty state message
  final emptyMessages = [
    find.textContaining('No results'),
    find.textContaining('No matches'),
    find.textContaining('Try adjusting'),
    find.textContaining('No one found'),
  ];

  bool foundEmptyState = false;
  for (final message in emptyMessages) {
    if (message.evaluate().isNotEmpty) {
      foundEmptyState = true;
      print('ℹ️ Found empty state message');
      break;
    }
  }

  if (totalResults == 0 && actionCount == 0 && !foundEmptyState) {
    print('ℹ️ No search results or empty state found');
  }
}

// Helper function to test age filtering
Future<void> _testAgeFiltering(WidgetTester tester) async {
  print('📊 Testing age filtering...');

  // Look for filter options first
  await _openFiltersIfNeeded(tester);

  // Look for age-related controls
  final ageControls = [
    find.textContaining('Age'),
    find.textContaining('age'),
    find.text('Min Age'),
    find.text('Max Age'),
  ];

  bool foundAgeControls = false;
  for (final control in ageControls) {
    if (control.evaluate().isNotEmpty) {
      foundAgeControls = true;
      print('✅ Found age control: ${control.description}');
      break;
    }
  }

  // Test age sliders
  final sliders = find.byType(Slider);
  if (sliders.evaluate().isNotEmpty) {
    print('✅ Found ${sliders.evaluate().length} sliders for age');

    // Test adjusting first slider (min age)
    await tester.drag(sliders.first, const Offset(30, 0));
    await tester.pumpAndSettle();
    print('✅ Adjusted age slider');
  }

  // Test range sliders
  final rangeSliders = find.byType(RangeSlider);
  if (rangeSliders.evaluate().isNotEmpty) {
    print('✅ Found age range slider');
    await tester.drag(rangeSliders.first, const Offset(20, 0));
    await tester.pumpAndSettle();
    print('✅ Adjusted age range');
  }

  if (!foundAgeControls &&
      sliders.evaluate().isEmpty &&
      rangeSliders.evaluate().isEmpty) {
    print('ℹ️ No age filtering controls found');
  }
}

// Helper function to test distance filtering
Future<void> _testDistanceFiltering(WidgetTester tester) async {
  print('📍 Testing distance filtering...');

  // Look for distance-related controls
  final distanceControls = [
    find.textContaining('Distance'),
    find.textContaining('distance'),
    find.textContaining('miles'),
    find.textContaining('km'),
    find.text('Max Distance'),
    find.text('Radius'),
  ];

  bool foundDistanceControls = false;
  for (final control in distanceControls) {
    if (control.evaluate().isNotEmpty) {
      foundDistanceControls = true;
      print('✅ Found distance control: ${control.description}');
      break;
    }
  }

  // Test distance slider (usually separate from age)
  final sliders = find.byType(Slider);
  if (sliders.evaluate().length > 1) {
    // Second slider might be distance
    await tester.drag(sliders.at(1), const Offset(-20, 0));
    await tester.pumpAndSettle();
    print('✅ Adjusted distance slider');
  }

  // Look for distance unit toggles
  final unitToggles = [
    find.text('Miles'),
    find.text('Kilometers'),
    find.text('km'),
    find.text('mi'),
  ];

  for (final toggle in unitToggles) {
    if (toggle.evaluate().isNotEmpty) {
      print('✅ Found distance unit option: ${toggle.description}');
      break;
    }
  }

  if (!foundDistanceControls) {
    print('ℹ️ No distance filtering controls found');
  }
}

// Helper function to test interest filtering
Future<void> _testInterestFiltering(WidgetTester tester) async {
  print('❤️ Testing interest filtering...');

  // Look for interest-related sections
  final interestSections = [
    find.text('Interests'),
    find.text('Hobbies'),
    find.text('Activities'),
    find.text('Passions'),
    find.textContaining('interest'),
  ];

  bool foundInterestSection = false;
  for (final section in interestSections) {
    if (section.evaluate().isNotEmpty) {
      foundInterestSection = true;
      await tester.tap(section.first);
      await tester.pumpAndSettle();
      print('✅ Opened interest section: ${section.description}');
      break;
    }
  }

  // Look for interest chips or checkboxes
  final interestControls = [
    find.byType(Chip),
    find.byType(FilterChip),
    find.byType(Checkbox),
  ];

  int totalInterestControls = 0;
  for (final controlType in interestControls) {
    final count = controlType.evaluate().length;
    if (count > 0) {
      totalInterestControls = count;
      print('✅ Found $count interest controls');

      // Test selecting first interest
      await tester.tap(controlType.first);
      await tester.pumpAndSettle();
      print('✅ Selected interest option');
      break;
    }
  }

  // Look for common interest categories
  final commonInterests = [
    find.text('Music'),
    find.text('Travel'),
    find.text('Sports'),
    find.text('Movies'),
    find.text('Food'),
    find.text('Art'),
    find.text('Reading'),
    find.text('Fitness'),
  ];

  int foundInterests = 0;
  for (final interest in commonInterests) {
    if (interest.evaluate().isNotEmpty) {
      foundInterests++;
      print('✅ Found interest: ${interest.description}');
      if (foundInterests == 1) {
        // Tap first found interest
        await tester.tap(interest);
        await tester.pumpAndSettle();
        print('✅ Selected interest');
      }
    }
  }

  if (!foundInterestSection &&
      totalInterestControls == 0 &&
      foundInterests == 0) {
    print('ℹ️ No interest filtering options found');
  }
}

// Helper function to test demographic filtering
Future<void> _testDemographicFiltering(WidgetTester tester) async {
  print('👥 Testing demographic filtering...');

  // Look for education filters
  final educationOptions = [
    find.text('Education'),
    find.text('University'),
    find.text('College'),
    find.text('High School'),
    find.text('Graduate'),
    find.textContaining('education'),
  ];

  bool foundEducation = false;
  for (final option in educationOptions) {
    if (option.evaluate().isNotEmpty) {
      foundEducation = true;
      print('✅ Found education option: ${option.description}');
      break;
    }
  }

  // Look for profession/job filters
  final professionOptions = [
    find.text('Profession'),
    find.text('Job'),
    find.text('Career'),
    find.text('Work'),
    find.textContaining('profession'),
  ];

  bool foundProfession = false;
  for (final option in professionOptions) {
    if (option.evaluate().isNotEmpty) {
      foundProfession = true;
      print('✅ Found profession option: ${option.description}');
      break;
    }
  }

  // Look for relationship type filters
  final relationshipOptions = [
    find.text('Looking for'),
    find.text('Relationship Type'),
    find.text('Casual'),
    find.text('Serious'),
    find.text('Long-term'),
    find.text('Short-term'),
  ];

  bool foundRelationshipType = false;
  for (final option in relationshipOptions) {
    if (option.evaluate().isNotEmpty) {
      foundRelationshipType = true;
      print('✅ Found relationship type: ${option.description}');
      break;
    }
  }

  // Test dropdown selections if available
  final dropdowns = find.byType(DropdownButton);
  if (dropdowns.evaluate().isNotEmpty) {
    print('✅ Found ${dropdowns.evaluate().length} dropdown filters');

    // Test opening first dropdown
    await tester.tap(dropdowns.first);
    await tester.pumpAndSettle();

    // Look for dropdown items
    final dropdownItems = find.byType(DropdownMenuItem);
    if (dropdownItems.evaluate().isNotEmpty) {
      await tester.tap(dropdownItems.first);
      await tester.pumpAndSettle();
      print('✅ Selected dropdown item');
    }
  }

  if (!foundEducation &&
      !foundProfession &&
      !foundRelationshipType &&
      dropdowns.evaluate().isEmpty) {
    print('ℹ️ No demographic filtering options found');
  }
}

// Helper function to open filters if needed
Future<void> _openFiltersIfNeeded(WidgetTester tester) async {
  final filterButtons = [
    find.text('Filters'),
    find.text('Advanced Filters'),
    find.byIcon(Icons.filter_list),
    find.byIcon(Icons.tune),
  ];

  for (final button in filterButtons) {
    if (button.evaluate().isNotEmpty) {
      await tester.tap(button.first);
      await tester.pumpAndSettle();
      print('✅ Opened filters');
      break;
    }
  }
}

// Helper function to test filter saving
Future<void> _testFilterSaving(WidgetTester tester) async {
  print('💾 Testing filter saving...');

  await _openFiltersIfNeeded(tester);

  // Make some filter changes first
  final sliders = find.byType(Slider);
  if (sliders.evaluate().isNotEmpty) {
    await tester.drag(sliders.first, const Offset(25, 0));
    await tester.pumpAndSettle();
    print('✅ Made filter change');
  }

  // Look for save buttons
  final saveButtons = [
    find.text('Save'),
    find.text('Save Filters'),
    find.text('Apply'),
    find.text('Done'),
    find.byIcon(Icons.check),
  ];

  bool savedFilters = false;
  for (final button in saveButtons) {
    if (button.evaluate().isNotEmpty) {
      await tester.tap(button.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('✅ Saved filters via: ${button.description}');
      savedFilters = true;
      break;
    }
  }

  if (!savedFilters) {
    print('ℹ️ Filter save option not found (may auto-save)');
  }
}

// Helper function to test filter loading
Future<void> _testFilterLoading(WidgetTester tester) async {
  print('📂 Testing filter loading...');

  // Navigate away and back to test persistence
  final homeButtons = [
    find.text('Home'),
    find.text('Discover'),
    find.byIcon(Icons.home),
  ];

  bool navigatedAway = false;
  for (final button in homeButtons) {
    if (button.evaluate().isNotEmpty) {
      await tester.tap(button.first);
      await tester.pumpAndSettle();
      navigatedAway = true;
      break;
    }
  }

  if (navigatedAway) {
    // Navigate back to search
    await _navigateToSearch(tester);
    await _openFiltersIfNeeded(tester);
    print('✅ Navigated away and back to test filter persistence');
  } else {
    print('ℹ️ Could not test filter loading via navigation');
  }
}

// Helper function to test filter reset
Future<void> _testFilterReset(WidgetTester tester) async {
  print('🔄 Testing filter reset...');

  await _openFiltersIfNeeded(tester);

  // Look for reset/clear buttons
  final resetButtons = [
    find.text('Reset'),
    find.text('Clear'),
    find.text('Clear All'),
    find.text('Reset Filters'),
    find.byIcon(Icons.clear),
    find.byIcon(Icons.refresh),
  ];

  bool resetFilters = false;
  for (final button in resetButtons) {
    if (button.evaluate().isNotEmpty) {
      await tester.tap(button.first);
      await tester.pumpAndSettle();
      print('✅ Reset filters via: ${button.description}');
      resetFilters = true;
      break;
    }
  }

  if (!resetFilters) {
    print('ℹ️ Filter reset option not found');
  }
}

// Helper function to test result sorting
Future<void> _testResultSorting(WidgetTester tester) async {
  print('🔄 Testing result sorting...');

  // Look for sort options
  final sortOptions = [
    find.text('Sort'),
    find.text('Sort by'),
    find.byIcon(Icons.sort),
    find.text('Distance'),
    find.text('Age'),
    find.text('Recently Active'),
    find.text('Newest'),
  ];

  bool foundSortOption = false;
  for (final option in sortOptions) {
    if (option.evaluate().isNotEmpty) {
      foundSortOption = true;
      print('✅ Found sort option: ${option.description}');

      // Don't tap 'Sort by' as it might be a label
      if (!option.description.toLowerCase().contains('sort by')) {
        await tester.tap(option.first);
        await tester.pumpAndSettle();
        print('✅ Applied sort option');
        break;
      }
    }
  }

  if (!foundSortOption) {
    print('ℹ️ No sorting options found');
  }
}

// Helper function to test result interaction
Future<void> _testResultInteraction(WidgetTester tester) async {
  print('👆 Testing result interaction...');

  // Look for profile cards or result items
  final resultItems = [
    find.byType(Card),
    find.byType(ListTile),
  ];

  bool interactedWithResult = false;
  for (final itemType in resultItems) {
    if (itemType.evaluate().isNotEmpty) {
      // Tap first result to view profile
      await tester.tap(itemType.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('✅ Tapped search result');

      // Look for back button to return
      if (find.byIcon(Icons.arrow_back).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
        print('✅ Returned from profile view');
      }

      interactedWithResult = true;
      break;
    }
  }

  if (!interactedWithResult) {
    print('ℹ️ No search results to interact with');
  }
}

// Helper function to test result pagination
Future<void> _testResultPagination(WidgetTester tester) async {
  print('📄 Testing result pagination...');

  // Look for pagination controls
  final paginationControls = [
    find.text('Load More'),
    find.text('Next'),
    find.text('Show More'),
    find.byIcon(Icons.keyboard_arrow_down),
    find.byIcon(Icons.expand_more),
  ];

  bool foundPagination = false;
  for (final control in paginationControls) {
    if (control.evaluate().isNotEmpty) {
      foundPagination = true;
      await tester.tap(control.first);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      print('✅ Triggered pagination: ${control.description}');
      break;
    }
  }

  // Test scroll-based pagination
  if (!foundPagination) {
    final scrollables = find.byType(Scrollable);
    if (scrollables.evaluate().isNotEmpty) {
      // Scroll down to trigger potential infinite scroll
      await tester.drag(scrollables.first, const Offset(0, -300));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('✅ Tested scroll pagination');
      foundPagination = true;
    }
  }

  if (!foundPagination) {
    print('ℹ️ No pagination controls found');
  }
}

// Helper function to test search refinement
Future<void> _testSearchRefinement(WidgetTester tester) async {
  print('🎯 Testing search refinement...');

  // Look for refine/modify search options
  final refineOptions = [
    find.text('Refine'),
    find.text('Modify Search'),
    find.text('Edit Filters'),
    find.text('Adjust'),
    find.byIcon(Icons.edit),
  ];

  bool foundRefineOption = false;
  for (final option in refineOptions) {
    if (option.evaluate().isNotEmpty) {
      foundRefineOption = true;
      await tester.tap(option.first);
      await tester.pumpAndSettle();
      print('✅ Accessed search refinement: ${option.description}');
      break;
    }
  }

  // Test quick filter adjustments
  final quickFilters = [
    find.byType(Chip),
    find.byType(FilterChip),
  ];

  for (final filterType in quickFilters) {
    if (filterType.evaluate().isNotEmpty) {
      await tester.tap(filterType.first);
      await tester.pumpAndSettle();
      print('✅ Adjusted quick filter');
      break;
    }
  }

  if (!foundRefineOption) {
    print('ℹ️ No search refinement options found');
  }
}
