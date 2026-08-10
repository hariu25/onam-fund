import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/contributor.dart';
import '../../models/payment.dart';
import '../../providers/contributor_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/status_badge.dart';
import 'add_edit_contributor_view.dart';
import 'record_payment_dialog.dart';

class ContributorDetailView extends StatelessWidget {
  final String contributorId;

  const ContributorDetailView({
    super.key,
    required this.contributorId,
  });

  void _confirmDeleteContributor(BuildContext context, Contributor contributor) {
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
          'Are you sure you want to delete "${contributor.name}" (${contributor.id})?\n\nThis will also remove all associated payment records. This action cannot be undone.',
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
              Navigator.of(ctx).pop(); // Close dialog
              Navigator.of(context).pop(); // Back to list
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

  void _confirmDeletePayment(BuildContext context, Payment payment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('Delete Payment Record?'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete payment of ₹${payment.amount.toStringAsFixed(0)} recorded on ${payment.formattedDate}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<ContributorProvider>(context, listen: false);
              provider.deletePayment(payment.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment record removed.'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('DELETE PAYMENT'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContributorProvider>(
      builder: (context, provider, child) {
        final contributorIndex = provider.contributors.indexWhere((c) => c.id == contributorId);
        if (contributorIndex == -1) {
          return Scaffold(
            appBar: AppBar(title: const Text('Member Details')),
            body: const Center(child: Text('Member not found.')),
          );
        }

        final contributor = provider.contributors[contributorIndex];
        final payments = provider.getPaymentsForContributor(contributor.id);
        final amountPaid = provider.getAmountPaidForContributor(contributor.id);
        final pendingAmount = contributor.getPendingAmount(payments, amountPaid);
        final status = contributor.getStatus(payments, amountPaid);
        final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

        return Scaffold(
          appBar: AppBar(
            title: Text(contributor.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit Details',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddEditContributorView(contributor: contributor),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                tooltip: 'Delete Member',
                onPressed: () => _confirmDeleteContributor(context, contributor),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Member Profile Header Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: AppColors.primaryDarkGreen,
                                  child: Text(
                                    contributor.name.isNotEmpty
                                        ? contributor.name.substring(0, 1).toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: AppColors.primaryGold,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        contributor.id,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryGreen,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        contributor.name,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                StatusBadge(
                                  status: status,
                                  amountPaid: amountPaid,
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),
                            const Divider(color: AppColors.cardBorder),
                            const SizedBox(height: 12),

                            // Address & Phone Details
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.location_on_outlined, size: 18, color: AppColors.primaryGreen),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    contributor.address,
                                    style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                                  ),
                                ),
                              ],
                            ),
                            if (contributor.phone.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.phone_outlined, size: 18, color: AppColors.primaryGreen),
                                  const SizedBox(width: 8),
                                  Text(
                                    contributor.phone,
                                    style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                                  ),
                                ],
                              ),
                            ],
                            if (contributor.notes != null && contributor.notes!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.note_alt_outlined, size: 18, color: AppColors.primaryGreen),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Notes: ${contributor.notes}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontStyle: FontStyle.italic,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Financial Summary Box
                    Card(
                      color: AppColors.warmGoldBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.primaryGold, width: 1.2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _detailStat('Total Due', currencyFormatter.format(contributor.amountDue), AppColors.primaryDarkGreen),
                                Container(height: 36, width: 1, color: AppColors.cardBorder),
                                _detailStat('Collected', currencyFormatter.format(amountPaid), AppColors.statusPaidDot),
                                Container(height: 36, width: 1, color: AppColors.cardBorder),
                                _detailStat('Pending', currencyFormatter.format(pendingAmount), pendingAmount > 0 ? AppColors.statusUnpaidDot : AppColors.textMuted),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Record Payment Action Button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: () => RecordPaymentDialog.show(context, contributor),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryDarkGreen,
                                  foregroundColor: AppColors.primaryGold,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.add_card, size: 20),
                                label: const Text(
                                  'PAYMENT RECEIVED',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Payment History Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Payment History',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDarkGreen,
                          ),
                        ),
                        Text(
                          '${payments.length} Transaction(s)',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (payments.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.history, size: 40, color: AppColors.textMuted),
                            SizedBox(height: 8),
                            Text(
                              'No payment records found.',
                              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Click "PAYMENT RECEIVED" above to record a contribution.',
                              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: payments.length,
                        itemBuilder: (context, index) {
                          final p = payments[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: AppColors.statusPaidBg,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check, color: AppColors.statusPaidDot, size: 18),
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    currencyFormatter.format(p.amount),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.primaryDarkGreen,
                                    ),
                                  ),
                                  Text(
                                    p.formattedDate,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryGreen.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          p.paymentMethod,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primaryDarkGreen,
                                          ),
                                        ),
                                      ),
                                      if (p.notes != null && p.notes!.isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            p.notes!,
                                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                                onPressed: () => _confirmDeletePayment(context, p),
                              ),
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
    );
  }

  Widget _detailStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
