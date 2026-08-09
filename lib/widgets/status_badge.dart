import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/contributor.dart';
import '../theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final PaymentStatus status;
  final double amountPaid;
  final bool showAmount;

  const StatusBadge({
    super.key,
    required this.status,
    required this.amountPaid,
    this.showAmount = true,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    Color dotColor;
    Color bgColor;
    Color textColor;
    IconData statusIcon;

    switch (status) {
      case PaymentStatus.paid:
        dotColor = AppColors.statusPaidDot;
        bgColor = AppColors.statusPaidBg;
        textColor = AppColors.statusPaidText;
        statusIcon = Icons.check_circle;
        break;
      case PaymentStatus.unpaid:
        dotColor = AppColors.statusUnpaidDot;
        bgColor = AppColors.statusUnpaidBg;
        textColor = AppColors.statusUnpaidText;
        statusIcon = Icons.cancel;
        break;
      case PaymentStatus.partial:
        dotColor = AppColors.statusPartialDot;
        bgColor = AppColors.statusPartialBg;
        textColor = AppColors.statusPartialText;
        statusIcon = Icons.pie_chart;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dotColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dot Indicator with pulse glow effect
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Icon(statusIcon, size: 14, color: dotColor),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          if (showAmount && amountPaid > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: dotColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                currencyFormatter.format(amountPaid),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
