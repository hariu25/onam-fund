import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/contributor.dart';
import '../../models/payment.dart';
import '../../providers/contributor_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_text_field.dart';

class RecordPaymentDialog extends StatefulWidget {
  final Contributor contributor;

  const RecordPaymentDialog({
    super.key,
    required this.contributor,
  });

  static Future<bool?> show(BuildContext context, Contributor contributor) {
    return showDialog<bool>(
      context: context,
      builder: (context) => RecordPaymentDialog(contributor: contributor),
    );
  }

  @override
  State<RecordPaymentDialog> createState() => _RecordPaymentDialogState();
}

class _RecordPaymentDialogState extends State<RecordPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _notesController;

  DateTime _selectedDate = DateTime.now();
  String _selectedMethod = 'UPI / GPay';

  final List<String> _paymentMethods = [
    'UPI / GPay',
    'PhonePe / Paytm',
    'Cash',
    'Bank Transfer (NEFT/IMPS)',
    'Cheque',
  ];

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ContributorProvider>(context, listen: false);
    final pending = widget.contributor.getPendingAmount(provider.payments);
    _amountController = TextEditingController(text: pending > 0 ? pending.toStringAsFixed(0) : '');
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2027),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryDarkGreen,
              onPrimary: AppColors.primaryGold,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final now = DateTime.now();
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          now.hour,
          now.minute,
          now.second,
          now.millisecond,
        );
      });
    }
  }

  void _submitPayment() {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
      final payment = Payment(
        id: 'PAY-${DateTime.now().millisecondsSinceEpoch}',
        contributorId: widget.contributor.id,
        amount: amount,
        paymentDate: _selectedDate,
        paymentMethod: _selectedMethod,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );

      final provider = Provider.of<ContributorProvider>(context, listen: false);
      provider.addPayment(payment);

      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment of ₹${amount.toStringAsFixed(0)} recorded for ${widget.contributor.name}'),
          backgroundColor: AppColors.primaryDarkGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ContributorProvider>(context);
    final pending = widget.contributor.getPendingAmount(provider.payments);
    final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.monetization_on_rounded, color: AppColors.primaryGold, size: 24),
              SizedBox(width: 8),
              Text(
                'Record Payment',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDarkGreen,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Member: ${widget.contributor.name} (${widget.contributor.id})',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pending Info Chip
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warmGoldBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Pending Balance:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    Text(
                      currencyFormatter.format(pending),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDarkGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Payment Amount Field
              CustomTextField(
                controller: _amountController,
                label: 'Payment Amount Received (₹)',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.currency_rupee,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter payment amount';
                  final amount = double.tryParse(val.trim());
                  if (amount == null || amount <= 0) return 'Enter a valid amount > 0';
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Quick Fill Button
              if (pending > 0)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      _amountController.text = pending.toStringAsFixed(0);
                    },
                    icon: const Icon(Icons.bolt, size: 14, color: AppColors.primaryGold),
                    label: Text(
                      'Pay Full Balance (₹${pending.toStringAsFixed(0)})',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              // Payment Date Selector
              const Text(
                'Payment Date',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDarkGreen,
                ),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: AppColors.primaryGreen, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            DateFormat('MMMM dd, yyyy').format(_selectedDate),
                            style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Payment Method Choice Chips / Dropdown
              const Text(
                'Payment Method',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDarkGreen,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedMethod,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.payment, color: AppColors.primaryGreen, size: 20),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: _paymentMethods.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(method, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedMethod = val;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              // Payment Notes
              CustomTextField(
                controller: _notesController,
                label: 'Payment Notes / Reference No. (Optional)',
                prefixIcon: Icons.notes,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('CANCEL', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: _submitPayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDarkGreen,
            foregroundColor: AppColors.primaryGold,
          ),
          child: const Text('SAVE PAYMENT'),
        ),
      ],
    );
  }
}
