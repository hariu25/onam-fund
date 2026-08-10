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
    this.amountPaid = 0.0,
    this.showAmount = true,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    Color dotColor;
    Color bgColor;
    Color textColor;
    IconData? statusIcon;

    switch (status) {
      case PaymentStatus.paid:
        dotColor = AppColors.statusPaidDot;
        bgColor = AppColors.statusPaidBg;
        textColor = AppColors.statusPaidText;
        statusIcon = Icons.check_rounded;
        break;
      case PaymentStatus.unpaid:
        dotColor = AppColors.statusUnpaidDot;
        bgColor = AppColors.statusUnpaidBg;
        textColor = AppColors.statusUnpaidText;
        statusIcon = Icons.close_rounded;
        break;
      case PaymentStatus.partial:
        dotColor = AppColors.statusPartialDot;
        bgColor = AppColors.statusPartialBg;
        textColor = AppColors.statusPartialText;
        statusIcon = null;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dotColor.withValues(alpha: 0.25), width: 1),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            if (statusIcon != null) ...[
              const SizedBox(width: 4),
              Icon(statusIcon, size: 12, color: dotColor),
            ],
            const SizedBox(width: 5),
            Text(
              status.label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
            if (showAmount && amountPaid > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: dotColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  currencyFormatter.format(amountPaid),
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

