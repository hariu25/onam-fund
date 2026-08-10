import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/contributor_provider.dart';
import '../../services/export_service.dart';
import '../../theme/app_colors.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  void _showCsvDialog(BuildContext context, ContributorProvider provider) {
    final csvData = ExportService.generateCsv(
      provider.contributors,
      provider.payments,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.table_chart, color: AppColors.primaryDarkGreen),
            SizedBox(width: 8),
            Text('Export CSV Data'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Copy the generated CSV data below or export to file:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  csvData,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: csvData));
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('CSV data copied to clipboard!'),
                  backgroundColor: AppColors.primaryDarkGreen,
                ),
              );
            },
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('COPY TO CLIPBOARD'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  void _confirmResetData(BuildContext context, ContributorProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.refresh, color: AppColors.primaryGold, size: 28),
            SizedBox(width: 8),
            Text('Reload Sample Data?'),
          ],
        ),
        content: const Text(
          'This will restore default sample members and payment history.\n\nAny custom members you added will be overwritten.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.resetToSampleData();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sample data reloaded successfully.'),
                  backgroundColor: AppColors.primaryDarkGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDarkGreen,
              foregroundColor: AppColors.primaryGold,
            ),
            child: const Text('RELOAD SAMPLES'),
          ),
        ],
      ),
    );
  }

  void _confirmClearData(BuildContext context, ContributorProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_forever, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('Clear All Data?'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete ALL members and payment records?\n\nThis action is permanent and cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.clearAllData();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All data has been cleared.'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('CLEAR ALL'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final provider = Provider.of<ContributorProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Admin Controls')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Admin User Profile Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryDarkGreen,
                            border: Border.all(
                              color: AppColors.primaryGold,
                              width: 2,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.admin_panel_settings,
                              color: AppColors.primaryGold,
                              size: 32,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                auth.adminName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                auth.adminEmail,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGold.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'ORGANIZER / ADMIN',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryDarkGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            auth.logout();
                          },
                          icon: const Icon(Icons.logout, size: 16),
                          label: const Text('Logout'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Reports & Export Section
                const Text(
                  'Data Export & Reports',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDarkGreen,
                  ),
                ),
                const SizedBox(height: 12),

                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.warmGoldBg,
                          child: Icon(
                            Icons.picture_as_pdf,
                            color: AppColors.primaryDarkGreen,
                          ),
                        ),
                        title: const Text(
                          'Export Official PDF Report',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                          'Generate printable PDF report with headers & summary table.',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          ExportService.generateAndPrintPdf(
                            contributors: provider.contributors,
                            payments: provider.payments,
                            totalExpected: provider.totalExpected,
                            totalCollected: provider.totalCollected,
                            pendingAmount: provider.pendingAmount,
                          );
                        },
                      ),
                      const Divider(height: 1, color: AppColors.cardBorder),
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.warmGoldBg,
                          child: Icon(
                            Icons.table_chart,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        title: const Text(
                          'Export CSV Table',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                          'Copy or download spreadsheet data in CSV format.',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => _showCsvDialog(context, provider),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Data Maintenance Section
                const Text(
                  'Database Maintenance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDarkGreen,
                  ),
                ),
                const SizedBox(height: 12),

                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.warmGoldBg,
                          child: Icon(
                            Icons.restart_alt,
                            color: AppColors.primaryDarkGreen,
                          ),
                        ),
                        title: const Text(
                          'Reload Sample  Data',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                          'Reset Cloud Firestore storage with pre-filled test members.',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _confirmResetData(context, provider),
                      ),
                      const Divider(height: 1, color: AppColors.cardBorder),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red.shade50,
                          child: const Icon(
                            Icons.delete_forever,
                            color: Colors.red,
                          ),
                        ),
                        title: const Text(
                          'Clear All Members & Payments',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        subtitle: const Text(
                          'Wipe all Cloud Firestore data clean.',
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.red,
                        ),
                        onTap: () => _confirmClearData(context, provider),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Cultural Greeting & Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.primaryDarkGreen,
                        AppColors.primaryGreen,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryGold,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.payments_rounded,
                        color: AppColors.primaryGold,
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'സംഭാവന - Fund Collection & Contribution Manager',
                        style: GoogleFonts.notoSansMalayalam(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'സംഭാവന പോർട്ടൽ • System v1.0',
                        style: GoogleFonts.notoSansMalayalam(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
