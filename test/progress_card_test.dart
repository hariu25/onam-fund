import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onam/widgets/progress_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProgressCard Widget Tests', () {
    testWidgets('Renders header, donut chart, financial summary, and progress bar accurately', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProgressCard(
                totalCollected: 500,
                totalExpected: 3300,
                pendingAmount: 2800,
              ),
            ),
          ),
        ),
      );

      // Verify Header
      expect(find.text('Fund Collection Target Progress'), findsOneWidget);
      expect(find.byIcon(Icons.pie_chart_rounded), findsOneWidget);
      expect(find.byIcon(Icons.more_vert_rounded), findsOneWidget);

      // Verify Donut Chart Center Text
      // 500 / 3300 * 100 = 15.1515... -> 15.2%
      expect(find.text('15.2%'), findsNWidgets(2)); // Donut center + Progress bar end label
      expect(find.text('Collected'), findsOneWidget);

      // Verify Financial Summary Labels and Values
      expect(find.text('Collected Amount'), findsOneWidget);
      expect(find.text('₹500'), findsOneWidget);

      expect(find.text('Target Amount'), findsOneWidget);
      expect(find.text('₹3,300'), findsOneWidget);

      expect(find.text('Pending Amount'), findsOneWidget);
      expect(find.text('₹2,800'), findsOneWidget);

      // Verify Linear Progress Bar
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('Renders cleanly on desktop screen (1000px width)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressCard(
              totalCollected: 1200,
              totalExpected: 4000,
              pendingAmount: 2800,
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Fund Collection Target Progress'), findsOneWidget);
      // 1200 / 4000 * 100 = 30.0%
      expect(find.text('30.0%'), findsNWidgets(2));
      expect(find.text('₹1,200'), findsOneWidget);
      expect(find.text('₹4,000'), findsOneWidget);
      expect(find.text('₹2,800'), findsOneWidget);
    });

    testWidgets('Renders cleanly on small mobile screen (360x640) without overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProgressCard(
                totalCollected: 500,
                totalExpected: 3300,
                pendingAmount: 2800,
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Fund Collection Target Progress'), findsOneWidget);
      expect(find.text('15.2%'), findsNWidgets(2));
    });
  });
}
