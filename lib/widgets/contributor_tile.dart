import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/contributor.dart';
import '../models/payment.dart';
import '../theme/app_colors.dart';
import 'status_badge.dart';

class ContributorTile extends StatelessWidget {
  final Contributor contributor;
  final List<Payment> payments;
  final VoidCallback onTap;
  final VoidCallback onRecordPayment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ContributorTile({
    super.key,
    required this.contributor,
    required this.payments,
    required this.onTap,
    required this.onRecordPayment,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final amountPaid = contributor.getAmountPaid(payments);
    final pendingAmount = contributor.getPendingAmount(payments);
    final status = contributor.getStatus(payments);
    final progress = contributor.amountDue > 0
        ? (amountPaid / contributor.amountDue).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Member ID, Name, Action Popup
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Circle Member Avatar
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primaryDarkGreen,
                    child: Text(
                      contributor.name.isNotEmpty
                          ? contributor.name.substring(0, 1).toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: AppColors.primaryGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name & ID
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              contributor.id,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          contributor.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (contributor.phone.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 12, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                contributor.phone,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Status Badge
                  StatusBadge(
                    status: status,
                    amountPaid: amountPaid,
                  ),

                  // More Options Menu
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'pay') onRecordPayment();
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'pay',
                        child: Row(
                          children: [
                            Icon(Icons.add_card, color: AppColors.primaryDarkGreen, size: 18),
                            SizedBox(width: 8),
                            Text('Record Payment'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: AppColors.primaryDarkGreen, size: 18),
                            SizedBox(width: 8),
                            Text('Edit Member'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red, size: 18),
                            SizedBox(width: 8),
                            Text('Delete Member', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.cardBorder),
              const SizedBox(height: 12),

              // Contribution Metrics Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _metricItem('Amount Due', currencyFormatter.format(contributor.amountDue), AppColors.textPrimary),
                  _metricItem('Paid', currencyFormatter.format(amountPaid), AppColors.statusPaidDot),
                  _metricItem('Pending', currencyFormatter.format(pendingAmount), pendingAmount > 0 ? AppColors.statusUnpaidDot : AppColors.textMuted),
                ],
              ),

              const SizedBox(height: 10),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.progressBackground,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    status == PaymentStatus.paid
                        ? AppColors.statusPaidDot
                        : status == PaymentStatus.partial
                            ? AppColors.statusPartialDot
                            : AppColors.statusUnpaidDot,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Payment Action Quick Button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (status != PaymentStatus.paid)
                    ElevatedButton.icon(
                      onPressed: onRecordPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        foregroundColor: AppColors.primaryDarkGreen,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.payment, size: 16),
                      label: const Text(
                        'Payment Received',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: onTap,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryDarkGreen,
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.arrow_forward, size: 14),
                    label: const Text('Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
