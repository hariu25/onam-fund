import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/contributor.dart';
import '../../providers/contributor_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_text_field.dart';

class AddEditContributorView extends StatefulWidget {
  final Contributor? contributor;

  const AddEditContributorView({super.key, this.contributor});

  @override
  State<AddEditContributorView> createState() => _AddEditContributorViewState();
}

class _AddEditContributorViewState extends State<AddEditContributorView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _amountDueController;
  late TextEditingController _notesController;

  // Immediate payment option during creation
  bool _recordInitialPayment = false;
  late TextEditingController _initialPaymentAmountController;
  String _initialPaymentMethod = 'UPI / GPay';
  late TextEditingController _initialPaymentNotesController;

  bool _isSaving = false;

  bool get isEditing => widget.contributor != null;

  @override
  void initState() {
    super.initState();
    final c = widget.contributor;
    _nameController = TextEditingController(text: c?.name ?? '');
    _addressController = TextEditingController(text: c?.address ?? '');
    _phoneController = TextEditingController(text: c?.phone ?? '');
    _amountDueController = TextEditingController(
      text: c != null ? c.amountDue.toStringAsFixed(0) : '',
    );
    _notesController = TextEditingController(text: c?.notes ?? '');

    _initialPaymentAmountController = TextEditingController();
    _initialPaymentNotesController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _amountDueController.dispose();
    _notesController.dispose();
    _initialPaymentAmountController.dispose();
    _initialPaymentNotesController.dispose();
    super.dispose();
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      final provider = Provider.of<ContributorProvider>(context, listen: false);

      final name = _nameController.text.trim();
      final address = _addressController.text.trim();
      final phone = _phoneController.text.trim();
      final amountDue = double.parse(_amountDueController.text.trim());
      final notes = _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null;

      try {
        if (isEditing) {
          final updated = widget.contributor!.copyWith(
            name: name,
            address: address,
            phone: phone,
            amountDue: amountDue,
            notes: notes,
          );
          await provider.editContributor(updated);
          if (!mounted) return;
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Member "${updated.name}" updated successfully.'),
              backgroundColor: AppColors.primaryDarkGreen,
            ),
          );
        } else {
          final memberId = provider.generateMemberId();
          final newContributor = Contributor(
            id: memberId,
            name: name,
            address: address,
            phone: phone,
            amountDue: amountDue,
            notes: notes,
          );

          double? initialAmount;
          if (_recordInitialPayment) {
            initialAmount = double.tryParse(
              _initialPaymentAmountController.text.trim(),
            );
          }

          await provider.addContributor(
            newContributor,
            initialPaymentAmount: initialAmount,
            initialPaymentMethod: _initialPaymentMethod,
            initialPaymentNotes:
                _initialPaymentNotesController.text.trim().isNotEmpty
                ? _initialPaymentNotesController.text.trim()
                : null,
          );

          if (!mounted) return;
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Contribution for "$name" ($memberId) saved successfully!',
              ),
              backgroundColor: AppColors.primaryDarkGreen,
            ),
          );
        }
      } catch (error) {
        if (!mounted) return;
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save contribution: $error'),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Member Details' : 'Add New Contributor'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.warmGoldBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primaryGold),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isEditing ? Icons.edit_note : Icons.person_add_alt_1,
                          color: AppColors.primaryDarkGreen,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEditing
                                    ? 'Update ${widget.contributor!.name} (${widget.contributor!.id})'
                                    : 'Register New Onam Contributor',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.primaryDarkGreen,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isEditing
                                    ? 'Modify member information or target contribution amount.'
                                    : 'Enter details below to add member to the directory.',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Personal Details Section
                  const Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 12),

                  CustomTextField(
                    controller: _nameController,
                    label: 'Full Name *',
                    // hint: 'e.g. Unnikrishnan Nair',
                    prefixIcon: Icons.person,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter contributor name';
                      }
                      if (val.trim().length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _addressController,
                    label: 'Address / House Name *',
                    // hint: 'e.g. House #12, MG Road, Kochi',
                    prefixIcon: Icons.home,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter address';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _phoneController,
                    label: 'Phone Number (Recommended)',
                    // hint: 'e.g. 9847012345',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    maxLength: 10,
                    validator: (val) {
                      if (val != null && val.trim().isNotEmpty) {
                        if (val.trim().length != 10) {
                          return 'Enter a valid 10-digit phone number';
                        }
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Financial Section
                  const Text(
                    'Contribution Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 12),

                  CustomTextField(
                    controller: _amountDueController,
                    label: 'Target Contribution Amount (₹) *',
                    // hint: 'e.g. 5000',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    prefixIcon: Icons.currency_rupee,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Enter target amount due';
                      }
                      final amount = double.tryParse(val.trim());
                      if (amount == null || amount <= 0) {
                        return 'Enter a valid amount > 0';
                      }
                      return null;
                    },
                    onChanged: (val) {
                      if (_recordInitialPayment) {
                        _initialPaymentAmountController.text = val;
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _notesController,
                    label: 'Additional Notes (Optional)',
                    // hint: 'e.g. Executive member / Feast sponsor',
                    prefixIcon: Icons.notes,
                    maxLines: 2,
                  ),

                  // Immediate Payment Received Section (Only when creating new member)
                  if (!isEditing) ...[
                    const SizedBox(height: 24),
                    const Divider(color: AppColors.cardBorder),
                    const SizedBox(height: 12),

                    SwitchListTile(
                      value: _recordInitialPayment,
                      activeThumbColor: AppColors.primaryGold,
                      activeTrackColor: AppColors.primaryDarkGreen,
                      title: const Text(
                        'Mark Payment Received Immediately',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.primaryDarkGreen,
                        ),
                      ),
                      subtitle: const Text(
                        'Record full or partial payment right now during registration.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _recordInitialPayment = val;
                          if (val) {
                            _initialPaymentAmountController.text =
                                _amountDueController.text;
                          }
                        });
                      },
                    ),

                    if (_recordInitialPayment) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.statusPaidBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.statusPaidDot.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextField(
                              controller: _initialPaymentAmountController,
                              label: 'Initial Payment Amount (₹)',
                              // hint: 'e.g. 5000',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              prefixIcon: Icons.attach_money,
                              validator: (val) {
                                if (_recordInitialPayment) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Enter payment amount';
                                  }
                                  final amt = double.tryParse(val.trim());
                                  if (amt == null || amt <= 0) {
                                    return 'Enter a valid amount > 0';
                                  }
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
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
                              initialValue: _initialPaymentMethod,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(
                                  Icons.payment,
                                  color: AppColors.primaryGreen,
                                  size: 20,
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'UPI / GPay',
                                  child: Text('UPI / GPay'),
                                ),
                                DropdownMenuItem(
                                  value: 'PhonePe / Paytm',
                                  child: Text('PhonePe / Paytm'),
                                ),
                                DropdownMenuItem(
                                  value: 'Cash',
                                  child: Text('Cash'),
                                ),
                                DropdownMenuItem(
                                  value: 'Bank Transfer (NEFT/IMPS)',
                                  child: Text('Bank Transfer'),
                                ),
                                DropdownMenuItem(
                                  value: 'Cheque',
                                  child: Text('Cheque'),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _initialPaymentMethod = val);
                                }
                              },
                            ),
                            const SizedBox(height: 12),
                            CustomTextField(
                              controller: _initialPaymentNotesController,
                              label: 'Payment Note / Ref (Optional)',
                              // hint: 'e.g. Cash received by Treasurer',
                              prefixIcon: Icons.receipt_long,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],

                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDarkGreen,
                        foregroundColor: AppColors.primaryGold,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: AppColors.primaryGold,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              isEditing
                                  ? 'UPDATE MEMBER DETAILS'
                                  : 'REGISTER MEMBER',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
