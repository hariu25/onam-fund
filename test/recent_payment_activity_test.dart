import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onam/models/contributor.dart';
import 'package:onam/models/payment.dart';
import 'package:onam/providers/contributor_provider.dart';
import 'package:onam/widgets/transaction_table.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Recent Payment Activity — Contributor Name Display Tests', () {
    testWidgets('Displays actual contributor names instead of Member ID', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final contributors = [
        Contributor(
          id: 'SMB-1001',
          name: 'GOVINDAN',
          address: 'Kochi',
          phone: '9847012345',
          amountDue: 5000,
        ),
        Contributor(
          id: 'SMB-1002',
          name: 'RAHUL',
          address: 'Trivandrum',
          phone: '9447154321',
          amountDue: 5000,
        ),
        Contributor(
          id: 'SMB-1003',
          name: 'ANITA',
          address: 'Thrissur',
          phone: '9745889911',
          amountDue: 3000,
        ),
      ];

      final payments = [
        Payment(
          id: 'PAY-1',
          contributorId: 'SMB-1001',
          amount: 5000,
          paymentDate: DateTime.now(),
          paymentMethod: 'UPI',
        ),
        Payment(
          id: 'PAY-2',
          contributorId: 'SMB-1002',
          amount: 2500,
          paymentDate: DateTime.now(),
          paymentMethod: 'Cash',
        ),
        Payment(
          id: 'PAY-3',
          contributorId: 'SMB-1003',
          amount: 3000,
          paymentDate: DateTime.now(),
          paymentMethod: 'Bank Transfer',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionTable(
              payments: payments,
              contributors: contributors,
            ),
          ),
        ),
      );

      // Verify actual contributor names are present
      expect(find.text('GOVINDAN'), findsOneWidget);
      expect(find.text('RAHUL'), findsOneWidget);
      expect(find.text('ANITA'), findsOneWidget);

      // Verify avatar initials
      expect(find.text('G'), findsOneWidget);
      expect(find.text('R'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);

      // Verify NO Member (SMB-1001) or Member (ONAM-1001) strings exist
      expect(find.textContaining('Member ('), findsNothing);
      expect(find.textContaining('Member (SMB-'), findsNothing);
      expect(find.textContaining('Member (ONAM-'), findsNothing);
    });

    testWidgets('Handles legacy ONAM- prefix mapping to SMB- contributor', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final contributors = [
        Contributor(
          id: 'SMB-1001',
          name: 'VISHNU',
          address: 'Calicut',
          phone: '9895011223',
          amountDue: 10000,
        ),
      ];

      final payments = [
        Payment(
          id: 'PAY-1001',
          contributorId: 'ONAM-1001', // Legacy ID in payment record
          amount: 10000,
          paymentDate: DateTime.now(),
          paymentMethod: 'GPay',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionTable(
              payments: payments,
              contributors: contributors,
            ),
          ),
        ),
      );

      expect(find.text('VISHNU'), findsOneWidget);
      expect(find.text('V'), findsOneWidget);
      expect(find.textContaining('Member ('), findsNothing);
    });
  });

  group('Recent Payment Activity — Sync Payment Status Tests', () {
    test('Status calculation logic: Paid, Partial Payment, and Unpaid', () {
      final contributor = Contributor(
        id: 'SMB-1001',
        name: 'Test Member',
        address: 'Kochi',
        phone: '9847012345',
        amountDue: 500.0,
      );

      // Paid: required = 500, paid = 500 => Paid
      expect(contributor.getStatusFromPaid(500.0), PaymentStatus.paid);

      // Paid excess: required = 500, paid = 2500 => Paid
      expect(contributor.getStatusFromPaid(2500.0), PaymentStatus.paid);

      // Partial: required = 500, paid = 150 => Partial Payment
      expect(contributor.getStatusFromPaid(150.0), PaymentStatus.partial);

      // Unpaid: required = 500, paid = 0 => Unpaid
      expect(contributor.getStatusFromPaid(0.0), PaymentStatus.unpaid);
    });

    testWidgets('TransactionTable renders data-driven status badges correctly', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final jithu = Contributor(id: 'SMB-1001', name: 'Jithu', address: 'A', phone: '1', amountDue: 500);
      final sreejith = Contributor(id: 'SMB-1002', name: 'Sreejith', address: 'B', phone: '2', amountDue: 500);
      final testMember = Contributor(id: 'SMB-1003', name: 'Test', address: 'C', phone: '3', amountDue: 500);
      final govindan = Contributor(id: 'SMB-1004', name: 'GOVINDAN', address: 'D', phone: '4', amountDue: 500);

      final contributors = [jithu, sreejith, testMember, govindan];

      final payments = [
        Payment(id: 'P1', contributorId: 'SMB-1001', amount: 500, paymentDate: DateTime.now(), paymentMethod: 'UPI'),
        Payment(id: 'P2', contributorId: 'SMB-1002', amount: 300, paymentDate: DateTime.now(), paymentMethod: 'Cash'),
        Payment(id: 'P3', contributorId: 'SMB-1003', amount: 0, paymentDate: DateTime.now(), paymentMethod: 'Cash'),
        Payment(id: 'P4', contributorId: 'SMB-1004', amount: 150, paymentDate: DateTime.now(), paymentMethod: 'Card'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionTable(
              payments: payments,
              contributors: contributors,
            ),
          ),
        ),
      );

      // Verify status labels in table
      expect(find.text('Paid'), findsOneWidget); // Jithu
      expect(find.text('Partial Payment'), findsNWidgets(2)); // Sreejith (300/500) & GOVINDAN (150/500)
      expect(find.text('Unpaid'), findsOneWidget); // Test (0/500)
    });
  });

  group('Recent Payment Activity — Latest Payments Filtering & Sorting Tests', () {
    test('recentPayments getter sorts descending by date and limits to 5 latest valid transactions', () {
      final now = DateTime.now();
      final p1 = Payment(id: 'P1', contributorId: 'SMB-1001', amount: 500, paymentDate: now.subtract(const Duration(days: 10)), paymentMethod: 'Cash');
      final p2 = Payment(id: 'P2', contributorId: 'SMB-1002', amount: 2500, paymentDate: now.subtract(const Duration(days: 1)), paymentMethod: 'UPI/GPay');
      final p3 = Payment(id: 'P3', contributorId: 'SMB-1003', amount: 300, paymentDate: now.subtract(const Duration(hours: 12)), paymentMethod: 'UPI/GPay');
      final p4 = Payment(id: 'P4', contributorId: 'SMB-1004', amount: 150, paymentDate: now.subtract(const Duration(hours: 1)), paymentMethod: 'UPI/GPay');
      final p5 = Payment(id: 'P5', contributorId: 'SMB-1005', amount: 1000, paymentDate: now.subtract(const Duration(days: 5)), paymentMethod: 'Card');
      final p6 = Payment(id: 'P6', contributorId: 'SMB-1006', amount: 200, paymentDate: now.subtract(const Duration(days: 20)), paymentMethod: 'Cash'); // 6th older payment

      final provider = ContributorProvider();
      provider.setMockPayments([p1, p2, p3, p4, p5, p6]);

      final recent = provider.recentPayments;

      // Must limit to 5 latest payments
      expect(recent.length, 5);

      // Must be sorted in descending order of paymentDate (newest first)
      expect(recent[0].id, 'P4'); // 1 hour ago (Govindan)
      expect(recent[1].id, 'P3'); // 12 hours ago (Sreejith)
      expect(recent[2].id, 'P2'); // 1 day ago (Hari)
      expect(recent[3].id, 'P5'); // 5 days ago
      expect(recent[4].id, 'P1'); // 10 days ago (Jithu)

      // Oldest 6th payment (P6, 20 days ago) should not be included in recent payments
      expect(recent.any((p) => p.id == 'P6'), false);
    });

    test('recentPayments handles fewer than 5 payments without creating placeholders', () {
      final now = DateTime.now();
      final p1 = Payment(id: 'P1', contributorId: 'SMB-1001', amount: 500, paymentDate: now.subtract(const Duration(days: 2)), paymentMethod: 'Cash');
      final p2 = Payment(id: 'P2', contributorId: 'SMB-1002', amount: 2500, paymentDate: now.subtract(const Duration(days: 1)), paymentMethod: 'UPI/GPay');

      final provider = ContributorProvider();
      provider.setMockPayments([p1, p2]);

      final recent = provider.recentPayments;

      // Returns exactly available transactions (2)
      expect(recent.length, 2);
      expect(recent[0].id, 'P2'); // Newest first
      expect(recent[1].id, 'P1');
    });

    testWidgets('Renders payments strictly sorted descending by date/time and excludes unpaid members', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final now = DateTime(2026, 8, 11, 12, 0);

      final jithu = Contributor(id: 'SMB-1001', name: 'Jithu', address: 'Kochi', phone: '9800000001', amountDue: 500);
      final hari = Contributor(id: 'SMB-1002', name: 'Hari', address: 'Trivandrum', phone: '9800000002', amountDue: 2500);
      final sreejith = Contributor(id: 'SMB-1003', name: 'Sreejith', address: 'Thrissur', phone: '9800000003', amountDue: 300);
      final govindan = Contributor(id: 'SMB-1004', name: 'Govindan', address: 'Calicut', phone: '9800000004', amountDue: 150);
      final unpaidMember = Contributor(id: 'SMB-1005', name: 'Unpaid Member', address: 'Kollam', phone: '9800000005', amountDue: 1000);

      final contributors = [jithu, hari, sreejith, govindan, unpaidMember];

      // Payments in mixed/chronological order
      final payments = [
        Payment(id: 'P1', contributorId: 'SMB-1001', amount: 500, paymentDate: now.subtract(const Duration(days: 1)), paymentMethod: 'Cash'), // Aug 10
        Payment(id: 'P2', contributorId: 'SMB-1002', amount: 2500, paymentDate: now.subtract(const Duration(hours: 3)), paymentMethod: 'UPI/GPay'), // Aug 11 9 AM
        Payment(id: 'P3', contributorId: 'SMB-1003', amount: 300, paymentDate: now.subtract(const Duration(hours: 2)), paymentMethod: 'UPI/GPay'), // Aug 11 10 AM
        Payment(id: 'P4', contributorId: 'SMB-1004', amount: 150, paymentDate: now, paymentMethod: 'UPI/GPay'), // Aug 11 12 PM (Latest)
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionTable(
              payments: payments,
              contributors: contributors,
            ),
          ),
        ),
      );

      // Verify all 4 actual paying contributors are displayed
      expect(find.text('Govindan'), findsOneWidget);
      expect(find.text('Sreejith'), findsOneWidget);
      expect(find.text('Hari'), findsOneWidget);
      expect(find.text('Jithu'), findsOneWidget);

      // Verify registered member with NO payments is NOT displayed in table
      expect(find.text('Unpaid Member'), findsNothing);

      // Verify descending order of appearance (Govindan first, Jithu last)
      final textWidgets = tester.widgetList<Text>(find.byType(Text)).map((t) => t.data).where((t) => t != null).toList();
      final govindanIndex = textWidgets.indexOf('Govindan');
      final sreejithIndex = textWidgets.indexOf('Sreejith');
      final hariIndex = textWidgets.indexOf('Hari');
      final jithuIndex = textWidgets.indexOf('Jithu');

      expect(govindanIndex < sreejithIndex, true, reason: 'Govindan (newest) should appear before Sreejith');
      expect(sreejithIndex < hariIndex, true, reason: 'Sreejith should appear before Hari');
      expect(hariIndex < jithuIndex, true, reason: 'Hari should appear before Jithu (oldest)');
    });

    test('Same date payments are sorted strictly by actual payment timestamp (most recent first)', () {
      final baseDate = DateTime(2026, 8, 11, 0, 0, 0);

      // Same date (Aug 11, 2026) with different timestamps
      final p1 = Payment(id: 'P-Jithu', contributorId: 'SMB-1001', amount: 5000, paymentDate: DateTime(2026, 8, 10, 10, 0), paymentMethod: 'Cash'); // Aug 10
      final p2 = Payment(id: 'P-Hari', contributorId: 'SMB-1002', amount: 2500, paymentDate: baseDate.add(const Duration(hours: 8)), paymentMethod: 'UPI'); // Aug 11 8:00 AM
      final p3 = Payment(id: 'P-Sreejith', contributorId: 'SMB-1003', amount: 300, paymentDate: baseDate.add(const Duration(hours: 10)), paymentMethod: 'UPI'); // Aug 11 10:00 AM
      final p4 = Payment(id: 'P-Govindan', contributorId: 'SMB-1004', amount: 150, paymentDate: baseDate.add(const Duration(hours: 14)), paymentMethod: 'UPI'); // Aug 11 2:00 PM

      final provider = ContributorProvider();
      provider.setMockPayments([p1, p2, p3, p4]);

      final recent = provider.recentPayments;

      expect(recent.length, 4);
      expect(recent[0].id, 'P-Govindan', reason: 'Govindan (2:00 PM) is most recent');
      expect(recent[1].id, 'P-Sreejith', reason: 'Sreejith (10:00 AM) is 2nd most recent');
      expect(recent[2].id, 'P-Hari', reason: 'Hari (8:00 AM) is 3rd most recent');
      expect(recent[3].id, 'P-Jithu', reason: 'Jithu (Aug 10) is oldest');
    });

    test('Sorting ignores contributor name, member ID, and payment amount', () {
      final now = DateTime(2026, 8, 11, 12, 0);

      // Amounts are reversed, member IDs are inverted, names are non-chronological
      final p1 = Payment(id: 'P1', contributorId: 'SMB-1099', memberName: 'Zebra', amount: 10000, paymentDate: now.subtract(const Duration(days: 5)), paymentMethod: 'Cash');
      final p2 = Payment(id: 'P2', contributorId: 'SMB-1001', memberName: 'Alpha', amount: 100, paymentDate: now.subtract(const Duration(hours: 1)), paymentMethod: 'UPI');

      final provider = ContributorProvider();
      provider.setMockPayments([p1, p2]);

      final recent = provider.recentPayments;

      expect(recent[0].id, 'P2', reason: 'P2 is 1 hour ago vs P1 5 days ago, ignoring amount (100 vs 10000), ID (1001 vs 1099), and name (Alpha vs Zebra)');
      expect(recent[1].id, 'P1');
    });

    test('Uses actual payment/transaction date, not member creation date', () {
      final now = DateTime.now();

      final oldMember = Contributor(id: 'SMB-1001', name: 'Old Member', address: 'A', phone: '1', amountDue: 5000, createdAt: DateTime(2020, 1, 1));
      final newMember = Contributor(id: 'SMB-1002', name: 'New Member', address: 'B', phone: '2', amountDue: 5000, createdAt: DateTime(2026, 8, 1));

      // Old member made a payment today, new member made a payment 5 days ago
      final pOld = Payment(id: 'P-OLD', contributorId: oldMember.id, amount: 5000, paymentDate: now, paymentMethod: 'UPI');
      final pNew = Payment(id: 'P-NEW', contributorId: newMember.id, amount: 5000, paymentDate: now.subtract(const Duration(days: 5)), paymentMethod: 'UPI');

      final provider = ContributorProvider();
      provider.setMockContributors([oldMember, newMember]);
      provider.setMockPayments([pNew, pOld]);

      final recent = provider.recentPayments;

      expect(recent[0].id, 'P-OLD', reason: 'Old member payment date is newer (today vs 5 days ago)');
      expect(recent[1].id, 'P-NEW');
    });

    test('List automatically reorders when a new payment is recorded', () async {
      final now = DateTime.now();
      final p1 = Payment(id: 'P1', contributorId: 'SMB-1001', amount: 500, paymentDate: now.subtract(const Duration(hours: 5)), paymentMethod: 'Cash');
      final p2 = Payment(id: 'P2', contributorId: 'SMB-1002', amount: 1000, paymentDate: now.subtract(const Duration(hours: 2)), paymentMethod: 'UPI');

      final provider = ContributorProvider();
      provider.setMockPayments([p1, p2]);

      expect(provider.recentPayments[0].id, 'P2');

      // Record a new, even newer payment
      final newPayment = Payment(id: 'P-NEWEST', contributorId: 'SMB-1003', amount: 1500, paymentDate: now, paymentMethod: 'GPay');
      await provider.addPayment(newPayment);

      // List must immediately reorder with newest payment first
      expect(provider.recentPayments[0].id, 'P-NEWEST');
      expect(provider.recentPayments[1].id, 'P2');
      expect(provider.recentPayments[2].id, 'P1');
    });
  });
}
