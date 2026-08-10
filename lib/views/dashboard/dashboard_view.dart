import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/contributor_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/pookkalam_header.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/progress_card.dart';
import '../../widgets/transaction_table.dart';
import '../contributors/add_edit_contributor_view.dart';
import '../contributors/contributor_detail_view.dart';

class DashboardView extends StatelessWidget {
  final VoidCallback onNavigateToContributors;

  const DashboardView({
    super.key,
    required this.onNavigateToContributors,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Consumer2<ContributorProvider, AuthProvider>(
        builder: (context, provider, auth, child) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primaryDarkGreen),
                  SizedBox(height: 16),
                  Text('Loading dashboard summary...', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off_rounded, size: 56, color: AppColors.error),
                    const SizedBox(height: 12),
                    const Text(
                      'Failed to Load Dashboard Data',
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
                      label: const Text('Retry Loading Data'),
                    ),
                  ],
                ),
              ),
            );
          }

          final collectionPercentage = provider.totalExpected > 0
              ? (provider.totalCollected / provider.totalExpected).clamp(0.0, 1.0)
              : 0.0;

          final recentPayments = provider.recentPayments;

          return RefreshIndicator(
            color: AppColors.primaryDarkGreen,
            onRefresh: () async {
              provider.retryFetch();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PookkalamHeader(
                        title: 'സംഭാവന',
                        subtitle: 'Welcome back, ${auth.adminName}! Track and manage member contributions.',
                      ),

                      const SizedBox(height: 24),

                      // Metrics Grid Section
                      const Text(
                        'Financial Summary Overview',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isDesktop = constraints.maxWidth > 700;
                          final crossAxisCount = isDesktop ? 4 : 2;
                          final childAspectRatio = isDesktop
                              ? 1.35
                              : (constraints.maxWidth > 350 ? 1.05 : 0.98);
                          return GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: childAspectRatio,
                            children: [
                              SummaryCard(
                                title: 'Total Members',
                                value: '${provider.totalMembers}',
                                icon: Icons.groups_rounded,
                                iconColor: AppColors.primaryDarkGreen,
                                subtitle: 'Registered',
                                onTap: onNavigateToContributors,
                              ),
                              SummaryCard(
                                title: 'Total Amount Expected',
                                value: currencyFormatter.format(provider.totalExpected),
                                icon: Icons.account_balance_wallet_rounded,
                                iconColor: AppColors.secondaryGreen,
                                subtitle: 'Target',
                              ),
                              SummaryCard(
                                title: 'Total Collected',
                                value: currencyFormatter.format(provider.totalCollected),
                                icon: Icons.payments_rounded,
                                iconColor: AppColors.success,
                                subtitle: '${(collectionPercentage * 100).toStringAsFixed(0)}% Received',
                              ),
                              SummaryCard(
                                title: 'Pending Balance',
                                value: currencyFormatter.format(provider.pendingAmount),
                                icon: Icons.pending_actions_rounded,
                                iconColor: AppColors.warningPending,
                                subtitle: 'To Collect',
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // Fund Collection Progress Section
                      ProgressCard(
                        totalCollected: provider.totalCollected,
                        totalExpected: provider.totalExpected,
                        pendingAmount: provider.pendingAmount,
                      ),

                      const SizedBox(height: 24),

                      // Member Status Breakdown Section
                      const Text(
                        'Member Status Breakdown',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _statusBreakdownCard(
                              label: 'Paid Members',
                              count: provider.paidCount,
                              total: provider.totalMembers,
                              color: AppColors.statusPaidDot,
                              bgColor: AppColors.statusPaidBg,
                              icon: Icons.check_circle_rounded,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _statusBreakdownCard(
                              label: 'Partial Paid',
                              count: provider.partialCount,
                              total: provider.totalMembers,
                              color: AppColors.statusPartialDot,
                              bgColor: AppColors.statusPartialBg,
                              icon: Icons.pie_chart_rounded,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _statusBreakdownCard(
                              label: 'Unpaid',
                              count: provider.unpaidCount,
                              total: provider.totalMembers,
                              color: AppColors.statusUnpaidDot,
                              bgColor: AppColors.statusUnpaidBg,
                              icon: Icons.cancel_rounded,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Quick Action Buttons & Recent Activity Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Recent Payment Activity',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AddEditContributorView(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryDarkGreen,
                              foregroundColor: AppColors.primaryGold,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              visualDensity: VisualDensity.compact,
                            ),
                            icon: const Icon(Icons.person_add_rounded, size: 16),
                            label: const Text('Add Member', style: TextStyle(fontSize: 13)),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Recent Activity Stream / Table
                      TransactionTable(
                        payments: recentPayments,
                        contributors: provider.contributors,
                        allPayments: provider.payments,
                        onSelectContributor: (contributorId) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ContributorDetailView(contributorId: contributorId),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _statusBreakdownCard({
    required String label,
    required int count,
    required int total,
    required Color color,
    required Color bgColor,
    required IconData icon,
  }) {
    final pct = total > 0 ? ((count / total) * 100).toStringAsFixed(0) : '0';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            '$pct% of total',
            style: TextStyle(
              fontSize: 10,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

