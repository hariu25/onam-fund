import 'package:flutter_test/flutter_test.dart';
import 'package:onam/models/contributor.dart';
import 'package:onam/providers/contributor_provider.dart';
import 'package:onam/services/export_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Member ID Centralized Generation & Formatting Tests', () {
    late ContributorProvider provider;

    setUp(() {
      provider = ContributorProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    test('Generates SMB-1001 by default when contributor list is empty', () {
      provider.setMockContributors([]);
      final newId = provider.generateMemberId();
      expect(newId, equals('SMB-1001'));
      expect(RegExp(r'^SMB-\d{4}$').hasMatch(newId), isTrue);
    });

    test('Automatically assigns next sequential SMB ID after highest existing ID', () {
      final member1 = Contributor(
        id: 'SMB-1001',
        name: 'Test Member 1',
        address: 'Test Address 1',
        phone: '1234567890',
        amountDue: 5000,
      );
      final member2 = Contributor(
        id: 'SMB-1002',
        name: 'Test Member 2',
        address: 'Test Address 2',
        phone: '0987654321',
        amountDue: 5000,
      );

      provider.setMockContributors([member1, member2]);

      final nextId = provider.generateMemberId();
      expect(nextId, equals('SMB-1003'));
      expect(RegExp(r'^SMB-\d{4}$').hasMatch(nextId), isTrue);
    });

    test('Formatted strictly as SMB-{4-digit number} with left padding if needed', () {
      final member = Contributor(
        id: 'SMB-0005',
        name: 'Small Number Member',
        address: 'Address',
        phone: '1111111111',
        amountDue: 1000,
      );
      provider.setMockContributors([member]);

      final nextId = provider.generateMemberId();
      // Should generate SMB-1001 because min base is 1000
      expect(nextId, equals('SMB-1001'));
      expect(RegExp(r'^SMB-\d{4}$').hasMatch(nextId), isTrue);

      // Testing numbers greater than 1000
      final member1015 = Contributor(
        id: 'SMB-1015',
        name: 'Member 1015',
        address: 'Address',
        phone: '1111111111',
        amountDue: 1000,
      );
      provider.setMockContributors([member1015]);

      final nextId1016 = provider.generateMemberId();
      expect(nextId1016, equals('SMB-1016'));
      expect(RegExp(r'^SMB-\d{4}$').hasMatch(nextId1016), isTrue);
    });

    test('Prevents duplicate member IDs if candidate ID already exists', () {
      final existingMember = Contributor(
        id: 'SMB-1001',
        name: 'Existing Member',
        address: 'Address',
        phone: '2222222222',
        amountDue: 2000,
      );
      provider.setMockContributors([existingMember]);

      final nextGeneratedId = provider.generateMemberId();
      expect(nextGeneratedId, isNot(equals('SMB-1001')));
      expect(nextGeneratedId, equals('SMB-1002'));
    });

    test('Search and filter matching logic handles SMB prefix correctly', () {
      final member = Contributor(
        id: 'SMB-1050',
        name: 'Sambhavana User',
        address: 'Address 50',
        phone: '9900990099',
        amountDue: 3000,
      );
      provider.setMockContributors([member]);

      // Search by SMB prefix
      provider.setSearchQuery('SMB-1050', immediate: true);
      final results = provider.filteredContributors;
      expect(results.any((c) => c.id == 'SMB-1050'), isTrue);

      // Search by numeric portion
      provider.setSearchQuery('1050', immediate: true);
      final numericResults = provider.filteredContributors;
      expect(numericResults.any((c) => c.id == 'SMB-1050'), isTrue);
    });

    test('Centralized formatMemberId converts legacy ONAM- prefix and numeric IDs to SMB format', () {
      expect(Contributor.formatMemberId('ONAM-1001'), equals('SMB-1001'));
      expect(Contributor.formatMemberId('ONAM-1002'), equals('SMB-1002'));
      expect(Contributor.formatMemberId('onam-1003'), equals('SMB-1003'));
      expect(Contributor.formatMemberId('1004'), equals('SMB-1004'));
      expect(Contributor.formatMemberId('SMB-1005'), equals('SMB-1005'));
    });

    test('Contributor.fromMap normalizes legacy ONAM- prefix to SMB- prefix', () {
      final legacyMap = {
        'id': 'ONAM-1001',
        'name': 'Legacy Member',
        'address': 'Kochi',
        'phone': '9847012345',
        'amountDue': 5000,
      };
      final contributor = Contributor.fromMap(legacyMap);
      expect(contributor.id, equals('SMB-1001'));
      expect(contributor.formattedId, equals('SMB-1001'));
    });
  });

  group('Excel Export Member ID Prefix Tests', () {
    test('ExportService.generateCsv outputs SMB-1001, SMB-1002... and zero ONAM- prefixes', () {
      final contributors = [
        Contributor(
          id: 'ONAM-1001', // Legacy ID format in data
          name: 'Member One',
          address: 'Kochi',
          phone: '9847012345',
          amountDue: 5000,
        ),
        Contributor(
          id: 'SMB-1002',
          name: 'Member Two',
          address: 'Trivandrum',
          phone: '9447154321',
          amountDue: 5000,
        ),
        Contributor(
          id: '1003',
          name: 'Member Three',
          address: 'Thrissur',
          phone: '9745889911',
          amountDue: 3000,
        ),
        Contributor(
          id: 'SMB-1004',
          name: 'Member Four',
          address: 'Calicut',
          phone: '9895011223',
          amountDue: 10000,
        ),
        Contributor(
          id: 'SMB-1005',
          name: 'Member Five',
          address: 'Kottayam',
          phone: '9496332211',
          amountDue: 3500,
        ),
      ];

      // Import ExportService package dynamically in test
      final csvOutput = ExportService.generateCsv(contributors, []);

      // Verify header and row content
      expect(csvOutput, contains('"Member ID"'));
      expect(csvOutput, contains('"SMB-1001"'));
      expect(csvOutput, contains('"SMB-1002"'));
      expect(csvOutput, contains('"SMB-1003"'));
      expect(csvOutput, contains('"SMB-1004"'));
      expect(csvOutput, contains('"SMB-1005"'));

      // Ensure zero ONAM- prefixes remain in output
      expect(csvOutput.contains('ONAM-'), isFalse);
    });
  });
}
