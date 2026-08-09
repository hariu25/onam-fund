import 'package:flutter/material.dart';
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDarkGreen, AppColors.primaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDarkGreen.withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: AppColors.primaryGold, width: 1.5),
      ),
      child: Stack(
        children: [
          // Background Decorative Floral Motifs (Pookkalam circles)
          Positioned(
            right: -20,
            bottom: -30,
            child: Opacity(
              opacity: 0.15,
              child: Icon(
                Icons.local_florist_rounded,
                size: 140,
                color: AppColors.primaryGold,
              ),
            ),
          ),
          Positioned(
            right: 40,
            top: -20,
            child: Opacity(
              opacity: 0.10,
              child: Icon(
                Icons.brightness_7,
                size: 80,
                color: AppColors.primaryGold,
              ),
            ),
          ),

          Row(
            children: [
              // Pookkalam Emblem Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryGold.withValues(alpha: 0.2),
                  border: Border.all(color: AppColors.primaryGold, width: 2),
                ),
                child: const Center(
                  child: Icon(
                    Icons.park_rounded, // Palm / Floral emblem
                    color: AppColors.primaryGold,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'ഓണം',
                            style: TextStyle(
                              color: AppColors.primaryDarkGreen,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
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
