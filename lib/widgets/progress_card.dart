import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProgressCard extends StatelessWidget {
  final double totalCollected;
  final double totalExpected;
  final double pendingAmount;

  const ProgressCard({
    super.key,
    required this.totalCollected,
    required this.totalExpected,
    required this.pendingAmount,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    final double progressRatio = totalExpected > 0
        ? (totalCollected / totalExpected).clamp(0.0, 1.0)
        : 0.0;
    final double percentageValue = totalExpected > 0
        ? (totalCollected / totalExpected * 100)
        : 0.0;
    final String percentageText = percentageValue.toStringAsFixed(1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5DFC9), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.pie_chart_rounded,
                      color: Color(0xFF0F6B4F),
                      size: 22,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Fund Collection Target Progress',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF123B32),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: Color(0xFF123B32),
                  size: 22,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 24),

          // RESPONSIVE BODY: Donut Chart + Financial Summary
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 550;

              final Widget donutChartWidget = Center(
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(150, 150),
                        painter: _DonutChartPainter(
                          progress: progressRatio,
                          progressColor: const Color(0xFF0F6B4F),
                          backgroundColor: const Color(0xFFE8E7DF),
                          strokeWidth: 16.0,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$percentageText%',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF123B32),
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Collected',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF16803C),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );

              final Widget summaryAndProgressBar = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Financial Summary Rows
                  _buildSummaryRow(
                    label: 'Collected Amount',
                    value: currencyFormatter.format(totalCollected),
                    valueColor: const Color(0xFF16803C),
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    label: 'Target Amount',
                    value: currencyFormatter.format(totalExpected),
                    valueColor: const Color(0xFF123B32),
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    label: 'Pending Amount',
                    value: currencyFormatter.format(pendingAmount),
                    valueColor: const Color(0xFFD64545),
                  ),

                  const SizedBox(height: 20),

                  // Horizontal Progress Bar
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progressRatio,
                            minHeight: 11,
                            backgroundColor: const Color(0xFFE5E8E2),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF0F6B4F),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$percentageText%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF16803C),
                        ),
                      ),
                    ],
                  ),
                ],
              );

              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    donutChartWidget,
                    const SizedBox(width: 32),
                    Expanded(child: summaryAndProgressBar),
                  ],
                );
              } else {
                return Column(
                  children: [
                    donutChartWidget,
                    const SizedBox(height: 24),
                    summaryAndProgressBar,
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF66736F),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  _DonutChartPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * pi * progress.clamp(0.0, 1.0);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

