import 'package:flutter_test/flutter_test.dart';
import 'package:onam/models/contributor.dart';
import 'package:onam/models/payment.dart';
import 'package:onam/providers/contributor_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ContributorProvider Performance & Optimization Unit Tests', () {
    late ContributorProvider provider;

    setUp(() {
      provider = ContributorProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    test('Pagination slices items according to pageSize (20 items)', () {
      expect(provider.pageSize, equals(20));
      expect(provider.displayedItemCount, equals(20));

      final initialPaginatedCount = provider.paginatedFilteredContributors.length;
      expect(initialPaginatedCount, lessThanOrEqualTo(20));
    });

    test('Search debouncing delays query update until timer fires', () async {
      provider.setSearchQuery('Rahul');
      // Query should be empty immediately before 250ms debounce
      expect(provider.searchQuery, equals(''));

      // Wait for debounce timer (250ms)
      await Future.delayed(const Duration(milliseconds: 300));
      expect(provider.searchQuery, equals('Rahul'));

      // Immediate clear search
      provider.setSearchQuery('', immediate: true);
      expect(provider.searchQuery, equals(''));
    });
  });
}
