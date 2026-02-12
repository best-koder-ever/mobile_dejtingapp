import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dejtingapp/widgets/profile_completeness_ring.dart';
import 'package:dejtingapp/utils/profile_completion_calculator.dart';

void main() {
  // ──── ProfileCompletenessRing Widget ────
  group('ProfileCompletenessRing Widget', () {
    Widget buildRing({double percentage = 0.5, double size = 120, bool showNudge = true}) {
      return MaterialApp(
        home: Scaffold(body: ProfileCompletenessRing(percentage: percentage, size: size, showNudge: showNudge)),
      );
    }

    testWidgets('renders at 0% with red color', (tester) async {
      await tester.pumpWidget(buildRing(percentage: 0.0));
      expect(find.text('0%'), findsOneWidget);
      expect(find.text('complete'), findsOneWidget);
    });

    testWidgets('renders at 25% (red zone)', (tester) async {
      await tester.pumpWidget(buildRing(percentage: 0.25));
      expect(find.text('25%'), findsOneWidget);
    });

    testWidgets('renders at 49% still shows red nudge', (tester) async {
      await tester.pumpWidget(buildRing(percentage: 0.49));
      expect(find.text('49%'), findsOneWidget);
      expect(find.text('Add more info to get matches'), findsOneWidget);
    });

    testWidgets('renders at 50% shows amber nudge', (tester) async {
      await tester.pumpWidget(buildRing(percentage: 0.50));
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('Looking good — keep going!'), findsOneWidget);
    });

    testWidgets('renders at 65% (amber zone)', (tester) async {
      await tester.pumpWidget(buildRing(percentage: 0.65));
      expect(find.text('65%'), findsOneWidget);
      expect(find.text('Looking good — keep going!'), findsOneWidget);
    });

    testWidgets('renders at 79% still amber', (tester) async {
      await tester.pumpWidget(buildRing(percentage: 0.79));
      expect(find.text('79%'), findsOneWidget);
      expect(find.text('Looking good — keep going!'), findsOneWidget);
    });

    testWidgets('renders at 80% shows green nudge', (tester) async {
      await tester.pumpWidget(buildRing(percentage: 0.80));
      expect(find.text('80%'), findsOneWidget);
      expect(find.text('Almost there — add a few more details'), findsOneWidget);
    });

    testWidgets('renders at 95% (green zone)', (tester) async {
      await tester.pumpWidget(buildRing(percentage: 0.95));
      expect(find.text('95%'), findsOneWidget);
      expect(find.text('Almost there — add a few more details'), findsOneWidget);
    });

    testWidgets('renders at 100% shows celebration', (tester) async {
      await tester.pumpWidget(buildRing(percentage: 1.0));
      expect(find.text('100%'), findsOneWidget);
      expect(find.textContaining('complete'), findsWidgets);
    });

    testWidgets('hides nudge when showNudge is false', (tester) async {
      await tester.pumpWidget(buildRing(percentage: 0.5, showNudge: false));
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('Looking good — keep going!'), findsNothing);
    });

    testWidgets('respects custom size', (tester) async {
      await tester.pumpWidget(buildRing(percentage: 0.5, size: 200));
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox))
          .where((s) => s.width == 200 && s.height == 200);
      expect(sizedBoxes.isNotEmpty, isTrue);
    });

    testWidgets('clamps percentage above 1.0', (tester) async {
      await tester.pumpWidget(buildRing(percentage: 1.5));
      // Should render 150% text but clamp the ring value
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('handles negative percentage', (tester) async {
      await tester.pumpWidget(buildRing(percentage: -0.1));
      // Should still render without crashing
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('has two CircularProgressIndicators (track + arc)', (tester) async {
      await tester.pumpWidget(buildRing(percentage: 0.5));
      expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
    });
  });

  // ──── ProfileCompletionCalculator ────
  group('ProfileCompletionCalculator', () {
    int calc({
      String firstName = '',
      String lastName = '',
      String bio = '',
      List<String> photoUrls = const [],
      List<String> interests = const [],
      String? city,
      String? occupation,
      String? education,
      String? gender,
      String? lookingFor,
      String? relationshipType,
      String? drinking,
      String? smoking,
      String? workout,
      String? height,
      List<String>? languages,
    }) {
      return ProfileCompletionCalculator.calculateProfileCompletion(
        firstName: firstName,
        lastName: lastName,
        bio: bio,
        photoUrls: photoUrls,
        interests: interests,
        city: city,
        occupation: occupation,
        education: education,
        gender: gender,
        lookingFor: lookingFor,
        relationshipType: relationshipType,
        drinking: drinking,
        smoking: smoking,
        workout: workout,
        height: height,
        languages: languages,
      );
    }

    test('empty profile returns 0%', () {
      expect(calc(), 0);
    });

    test('full profile returns 100%', () {
      final result = calc(
        firstName: 'Alice',
        lastName: 'Smith',
        bio: 'A well-written bio that is definitely more than fifty characters long to qualify.',
        photoUrls: ['a.jpg', 'b.jpg', 'c.jpg'],
        interests: ['hiking', 'cooking', 'reading'],
        city: 'Stockholm',
        occupation: 'Engineer',
        education: 'University',
        gender: 'Woman',
        lookingFor: 'Man',
        relationshipType: 'Long-term',
        drinking: 'Socially',
        smoking: 'Never',
        workout: 'Often',
      );
      expect(result, 100);
    });

    test('firstName only contributes', () {
      expect(calc(firstName: 'Bob'), greaterThan(0));
    });

    test('bio under 50 chars does not get bonus', () {
      final short = calc(bio: 'Hello');
      final long = calc(bio: 'A bio that is definitely over fifty characters in length to get the bonus points');
      expect(long, greaterThan(short));
    });

    test('one photo contributes 2 points', () {
      final none = calc();
      final one = calc(photoUrls: ['a.jpg']);
      expect(one, greaterThan(none));
    });

    test('three photos get bonus point', () {
      final two = calc(photoUrls: ['a.jpg', 'b.jpg']);
      final three = calc(photoUrls: ['a.jpg', 'b.jpg', 'c.jpg']);
      expect(three, greaterThan(two));
    });

    test('interests >= 3 contribute 2 points', () {
      final two = calc(interests: ['a', 'b']);
      final three = calc(interests: ['a', 'b', 'c']);
      expect(three, greaterThan(two));
    });

    test('city contributes', () {
      final without = calc();
      final with_ = calc(city: 'NYC');
      expect(with_, greaterThan(without));
    });

    test('lifestyle fields contribute', () {
      final base = calc();
      final withLifestyle = calc(drinking: 'Socially', smoking: 'Never', workout: 'Daily');
      expect(withLifestyle, greaterThan(base));
    });

    test('result is clamped to 0-100', () {
      final result = calc();
      expect(result, greaterThanOrEqualTo(0));
      expect(result, lessThanOrEqualTo(100));
    });

    // ──── getProfileCompletionMessage ────
    test('message at 0% is get-started', () {
      final msg = ProfileCompletionCalculator.getProfileCompletionMessage(0);
      expect(msg, contains('get started'));
    });

    test('message at 40% encourages completion', () {
      final msg = ProfileCompletionCalculator.getProfileCompletionMessage(40);
      expect(msg, contains('Good start'));
    });

    test('message at 60% says looking good', () {
      final msg = ProfileCompletionCalculator.getProfileCompletionMessage(60);
      expect(msg, contains('Looking good'));
    });

    test('message at 85% says almost there', () {
      final msg = ProfileCompletionCalculator.getProfileCompletionMessage(85);
      expect(msg, contains('Almost there'));
    });

    test('message at 95% says excellent', () {
      final msg = ProfileCompletionCalculator.getProfileCompletionMessage(95);
      expect(msg, contains('Excellent'));
    });

    test('message at 100% says perfect', () {
      final msg = ProfileCompletionCalculator.getProfileCompletionMessage(100);
      expect(msg, contains('Perfect'));
    });

    // ──── getCompletionColor ────
    test('color red at 30%', () {
      final c = ProfileCompletionCalculator.getCompletionColor(30);
      expect(c, const Color(0xFFEF4444));
    });

    test('color amber at 60%', () {
      final c = ProfileCompletionCalculator.getCompletionColor(60);
      expect(c, const Color(0xFFF59E0B));
    });

    test('color green at 90%', () {
      final c = ProfileCompletionCalculator.getCompletionColor(90);
      expect(c, const Color(0xFF10B981));
    });

    // ──── getCompletionSuggestions ────
    test('suggestions for empty profile include photos', () {
      final s = ProfileCompletionCalculator.getCompletionSuggestions(
        bio: '', photoUrls: [], interests: [],
      );
      expect(s.any((x) => x.contains('photo')), isTrue);
    });

    test('suggestions for empty profile include bio', () {
      final s = ProfileCompletionCalculator.getCompletionSuggestions(
        bio: '', photoUrls: ['a.jpg', 'b.jpg', 'c.jpg'], interests: ['a', 'b', 'c'],
      );
      expect(s.any((x) => x.contains('bio')), isTrue);
    });

    test('suggestions capped at 3', () {
      final s = ProfileCompletionCalculator.getCompletionSuggestions(
        bio: '', photoUrls: [], interests: [],
      );
      expect(s.length, lessThanOrEqualTo(3));
    });

    test('short bio gets expand suggestion', () {
      final s = ProfileCompletionCalculator.getCompletionSuggestions(
        bio: 'Hi', photoUrls: ['a.jpg', 'b.jpg', 'c.jpg'], interests: ['a', 'b', 'c'],
      );
      expect(s.any((x) => x.contains('Expand')), isTrue);
    });

    // ──── getMatchQualityBonus ────
    test('match quality bonus at 30%', () {
      expect(
        ProfileCompletionCalculator.getMatchQualityBonus(30),
        contains('Complete your profile'),
      );
    });

    test('match quality bonus at 60%', () {
      expect(
        ProfileCompletionCalculator.getMatchQualityBonus(60),
        contains('+25%'),
      );
    });

    test('match quality bonus at 90%', () {
      expect(
        ProfileCompletionCalculator.getMatchQualityBonus(90),
        contains('+50%'),
      );
    });

    test('match quality bonus at 100%', () {
      expect(
        ProfileCompletionCalculator.getMatchQualityBonus(100),
        contains('+75%'),
      );
    });
  });
}
