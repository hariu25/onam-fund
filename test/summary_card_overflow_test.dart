import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:onam/providers/auth_provider.dart';
import 'package:onam/providers/contributor_provider.dart';
import 'package:onam/views/dashboard/dashboard_view.dart';
import 'package:onam/widgets/summary_card.dart';
import 'package:onam/theme/app_colors.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Financial Summary Overview Card & Mobile Responsive Tests', () {
    testWidgets('SummaryCard renders cleanly without overflow in constrained box', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 150,
              height: 140,
              child: SummaryCard(
                title: 'Total Amount Expected',
                value: '₹1,500,000',
                icon: Icons.account_balance_wallet,
                iconColor: AppColors.primaryGreen,
                subtitle: 'Target',
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Total Amount Expected'), findsOneWidget);
      expect(find.text('₹1,500,000'), findsOneWidget);
      expect(find.text('Target'), findsOneWidget);
    });

    testWidgets('DashboardView financial summary cards render with zero overflow on mobile screen (360x640)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final contributorProvider = ContributorProvider();
      final authProvider = AuthProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ContributorProvider>.value(value: contributorProvider),
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ],
          child: MaterialApp(
            home: DashboardView(
              onNavigateToContributors: () {},
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
      expect(find.text('Financial Summary Overview'), findsOneWidget);
      expect(find.text('Total Members'), findsOneWidget);
      expect(find.text('Total Amount Expected'), findsOneWidget);
      expect(find.text('Total Collected'), findsOneWidget);
      expect(find.text('Pending Balance'), findsOneWidget);
    });

    testWidgets('DashboardView financial summary cards render on small mobile screen (320x568)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final contributorProvider = ContributorProvider();
      final authProvider = AuthProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ContributorProvider>.value(value: contributorProvider),
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ],
          child: MaterialApp(
            home: DashboardView(
              onNavigateToContributors: () {},
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
      expect(find.text('Financial Summary Overview'), findsOneWidget);
    });
  });
}
