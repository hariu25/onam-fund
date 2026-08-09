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
          final fullList = provider.filteredContributors;
          final paginatedList = provider.paginatedFilteredContributors;

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
                          'Showing ${paginatedList.length} of ${fullList.length} (${provider.totalMembers} total)',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (provider.statusFilter != 'All' || provider.searchQuery.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              provider.setSearchQuery('', immediate: true);
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

              // Loading State
              if (provider.isLoading)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppColors.primaryDarkGreen),
                        SizedBox(height: 16),
                        Text(
                          'Loading contributor records...',
                          style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                )
              // Error State
              else if (provider.errorMessage != null)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 56, color: Colors.redAccent),
                          const SizedBox(height: 12),
                          const Text(
                            'Unable to Load Data',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            provider.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: provider.retryFetch,
                            icon: const Icon(Icons.refresh),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryDarkGreen,
                              foregroundColor: AppColors.primaryGold,
                            ),
                            label: const Text('Retry Connection'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              // Empty State
              else if (fullList.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          provider.searchQuery.isNotEmpty || provider.statusFilter != 'All'
                              ? Icons.search_off
                              : Icons.groups_outlined,
                          size: 60,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          provider.searchQuery.isNotEmpty || provider.statusFilter != 'All'
                              ? 'No members found matching criteria.'
                              : 'No members added yet.',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          provider.searchQuery.isNotEmpty || provider.statusFilter != 'All'
                              ? 'Try adjusting your search query or status filters.'
                              : 'Tap "Add Member" below to get started.',
                          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 16),
                        if (provider.searchQuery.isNotEmpty || provider.statusFilter != 'All')
                          ElevatedButton.icon(
                            onPressed: () {
                              provider.setSearchQuery('', immediate: true);
                              provider.setStatusFilter('All');
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reset Filters'),
                          )
                        else
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AddEditContributorView(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.person_add),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryDarkGreen,
                              foregroundColor: AppColors.primaryGold,
                            ),
                            label: const Text('Add First Member'),
                          ),
                      ],
                    ),
                  ),
                )
              // Paginated Lazy Loading Contributor Cards List
              else
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (scrollInfo) {
                      if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                        provider.loadMoreItems();
                      }
                      return false;
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: paginatedList.length + (provider.hasMoreItems ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == paginatedList.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(
                              child: TextButton.icon(
                                onPressed: provider.loadMoreItems,
                                icon: const Icon(Icons.arrow_downward, size: 16),
                                label: const Text('Load More Members'),
                              ),
                            ),
                          );
                        }

                        final contributor = paginatedList[index];
                        final paidAmount = provider.getAmountPaidForContributor(contributor.id);

                        return ContributorTile(
                          contributor: contributor,
                          payments: provider.payments,
                          precalculatedPaid: paidAmount,
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
