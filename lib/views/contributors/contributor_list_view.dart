import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/contributor.dart';
import '../../providers/contributor_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/contributor_tile.dart';
import '../../widgets/search_filter_bar.dart';
import 'add_edit_contributor_view.dart';
import 'contributor_detail_view.dart';
import 'record_payment_dialog.dart';

class ContributorListView extends StatelessWidget {
  const ContributorListView({super.key});

  void _confirmDelete(BuildContext context, Contributor contributor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('Delete Member?'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${contributor.name}" (${contributor.id})?\n\nThis will also delete all payment records for this member.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<ContributorProvider>(context, listen: false);
              provider.deleteContributor(contributor.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Member "${contributor.name}" deleted.'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contributor Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Add Member',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AddEditContributorView(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ContributorProvider>(
        builder: (context, provider, child) {
          final list = provider.filteredContributors;

          return Column(
            children: [
              // Search & Filter Header Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.bgLight,
                  border: Border(
                    bottom: BorderSide(color: AppColors.cardBorder),
                  ),
                ),
                child: Column(
                  children: [
                    SearchFilterBar(
                      searchQuery: provider.searchQuery,
                      selectedStatusFilter: provider.statusFilter,
                      selectedSortBy: provider.sortBy,
                      isSortAscending: provider.sortAscending,
                      onSearchChanged: provider.setSearchQuery,
                      onStatusFilterChanged: provider.setStatusFilter,
                      onSortByChanged: provider.setSortBy,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Showing ${list.length} of ${provider.totalMembers} Members',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (provider.statusFilter != 'All' || provider.searchQuery.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              provider.setSearchQuery('');
                              provider.setStatusFilter('All');
                            },
                            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                            child: const Text(
                              'Clear Filters',
                              style: TextStyle(fontSize: 12, color: AppColors.primaryGreen),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Contributor Cards List
              Expanded(
                child: list.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off, size: 60, color: AppColors.textMuted),
                            const SizedBox(height: 12),
                            const Text(
                              'No members found matching criteria.',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Try adjusting your search query or filter chips.',
                              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                provider.setSearchQuery('');
                                provider.setStatusFilter('All');
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reset Filters'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final contributor = list[index];
                          return ContributorTile(
                            contributor: contributor,
                            payments: provider.payments,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ContributorDetailView(contributorId: contributor.id),
                                ),
                              );
                            },
                            onRecordPayment: () {
                              RecordPaymentDialog.show(context, contributor);
                            },
                            onEdit: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => AddEditContributorView(contributor: contributor),
                                ),
                              );
                            },
                            onDelete: () => _confirmDelete(context, contributor),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddEditContributorView(),
            ),
          );
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Add Member', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
