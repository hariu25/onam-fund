import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class PookkalamHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const PookkalamHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final currentSubtitle = subtitle;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.primaryDarkGreen,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3), width: 1),
      ),
      child: Stack(
        children: [
          // Background Decorative Subtle Motifs
          Positioned(
            right: -15,
            bottom: -20,
            child: Opacity(
              opacity: 0.08,
              child: const Icon(
                Icons.account_balance_rounded,
                size: 130,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            right: 80,
            top: -25,
            child: Opacity(
              opacity: 0.05,
              child: const Icon(
                Icons.monetization_on_rounded,
                size: 90,
                color: AppColors.primaryGold,
              ),
            ),
          ),

          Row(
            children: [
              // Fund Emblem Container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondaryGreen,
                  border: Border.all(color: AppColors.primaryGold, width: 1.5),
                ),
                child: const Center(
                  child: Icon(
                    Icons.payments_rounded,
                    color: AppColors.primaryGold,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title & Subtitle Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: GoogleFonts.notoSansMalayalam(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.primaryGold, width: 0.8),
                          ),
                          child: Text(
                            'സംഭാവന',
                            style: GoogleFonts.notoSansMalayalam(
                              color: AppColors.primaryGold,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (currentSubtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        currentSubtitle,
                        style: GoogleFonts.notoSansMalayalam(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              ?trailing,
            ],
          ),
        ],
      ),
    );
  }
}


