import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/payment.dart';
import '../models/contributor.dart';
import '../theme/app_colors.dart';
import 'status_badge.dart';

class TransactionTable extends StatelessWidget {
  final List<Payment> payments;
  final List<Contributor> contributors;
  final List<Payment>? allPayments;
  final Function(String contributorId)? onSelectContributor;

  const TransactionTable({
    super.key,
    required this.payments,
    required this.contributors,
    this.allPayments,
    this.onSelectContributor,
  });

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long_outlined, size: 40, color: AppColors.textMuted),
              SizedBox(height: 8),
              Text(
                'No payment activity recorded yet.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 650;

        if (isDesktop) {
          return _buildDesktopTable(context);
        } else {
          return _buildMobileCards(context);
        }
      },
    );
  }

  Widget _buildDesktopTable(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final sortedPayments = List<Payment>.from(payments)
      ..sort((a, b) {
        final dateCmp = b.paymentDate.compareTo(a.paymentDate);
        if (dateCmp != 0) return dateCmp;
        return b.id.compareTo(a.id);
      });

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2.2), // Contributor Name
          1: FlexColumnWidth(1.4), // Amount
          2: FlexColumnWidth(1.6), // Date
          3: FlexColumnWidth(1.4), // Payment Method
          4: FlexColumnWidth(1.6), // Status Badge
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          // Table Header
          TableRow(
            decoration: const BoxDecoration(
              color: AppColors.bgLight,
              border: Border(bottom: BorderSide(color: AppColors.cardBorder, width: 1)),
            ),
            children: [
              _buildHeaderCell('Contributor Name'),
              _buildHeaderCell('Amount Paid'),
              _buildHeaderCell('Payment Date'),
              _buildHeaderCell('Method'),
              _buildHeaderCell('Status'),
            ],
          ),

          // Table Rows
          ...sortedPayments.map((payment) {
            final contributorIndex = contributors.indexWhere(
              (c) => c.id == payment.contributorId || Contributor.formatMemberId(c.id) == Contributor.formatMemberId(payment.contributorId),
            );
            final contributor = contributorIndex != -1 ? contributors[contributorIndex] : null;
            final memberName = (contributor != null && contributor.name.trim().isNotEmpty)
                ? contributor.name
                : (payment.memberName != null && payment.memberName!.trim().isNotEmpty)
                    ? payment.memberName!
                    : 'Contributor';
            final effectivePayments = allPayments ?? payments;
            final status = contributor != null
                ? contributor.getStatus(effectivePayments)
                : (payment.amount > 0 ? PaymentStatus.paid : PaymentStatus.unpaid);

            return TableRow(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.cardBorder, width: 0.6)),
              ),
              children: [
                // Contributor Name
                InkWell(
                  onTap: () {
                    if (contributor != null && onSelectContributor != null) {
                      onSelectContributor!(contributor.id);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: AppColors.lightGold,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              memberName.isNotEmpty ? memberName[0].toUpperCase() : 'C',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDarkGreen,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            memberName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Amount
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    currencyFormatter.format(payment.amount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.success,
                    ),
                  ),
                ),

                // Date
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    payment.formattedDate,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),

                // Method
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    payment.paymentMethod,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),

                // Status Badge
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: StatusBadge(
                      status: status,
                      amountPaid: payment.amount,
                      showAmount: false,
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMobileCards(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final sortedPayments = List<Payment>.from(payments)
      ..sort((a, b) {
        final dateCmp = b.paymentDate.compareTo(a.paymentDate);
        if (dateCmp != 0) return dateCmp;
        return b.id.compareTo(a.id);
      });

    return Column(
      children: sortedPayments.map((payment) {
        final contributorIndex = contributors.indexWhere(
          (c) => c.id == payment.contributorId || Contributor.formatMemberId(c.id) == Contributor.formatMemberId(payment.contributorId),
        );
        final contributor = contributorIndex != -1 ? contributors[contributorIndex] : null;
        final memberName = (contributor != null && contributor.name.trim().isNotEmpty)
            ? contributor.name
            : (payment.memberName != null && payment.memberName!.trim().isNotEmpty)
                ? payment.memberName!
                : 'Contributor';
        final effectivePayments = allPayments ?? payments;
        final status = contributor != null
            ? contributor.getStatus(effectivePayments)
            : (payment.amount > 0 ? PaymentStatus.paid : PaymentStatus.unpaid);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder, width: 1),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            leading: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.lightGold,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  memberName.isNotEmpty ? memberName[0].toUpperCase() : 'C',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDarkGreen,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            title: Text(
              memberName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${payment.paymentMethod} • ${payment.formattedDate}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                StatusBadge(
                  status: status,
                  amountPaid: payment.amount,
                  showAmount: false,
                ),
              ],
            ),
            trailing: Text(
              currencyFormatter.format(payment.amount),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppColors.success,
              ),
            ),
            onTap: () {
              if (contributor != null && onSelectContributor != null) {
                onSelectContributor!(contributor.id);
              }
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHeaderCell(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: AppColors.textSecondary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
