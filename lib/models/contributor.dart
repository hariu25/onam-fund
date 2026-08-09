import 'payment.dart';

enum PaymentStatus {
  paid,
  unpaid,
  partial,
}

extension PaymentStatusExtension on PaymentStatus {
  String get label {
    switch (this) {
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.unpaid:
        return 'Unpaid';
      case PaymentStatus.partial:
        return 'Partial Payment';
    }
  }
}

class Contributor {
  final String id; // Unique Member ID (e.g. ONAM-1001)
  final String name;
  final String address;
  final String phone;
  final double amountDue;
  final String? notes;
  final DateTime createdAt;

  Contributor({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.amountDue,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'amountDue': amountDue,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Contributor.fromMap(Map<String, dynamic> map) {
    return Contributor(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      amountDue: (map['amountDue'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  // Calculate total amount paid from contributor's payments list (or pre-indexed payments)
  double getAmountPaid(List<Payment> payments) {
    final memberPayments = payments.where((p) => p.contributorId == id);
    return memberPayments.fold(0.0, (sum, p) => sum + p.amount);
  }

  // Calculate pending remaining balance given paid amount or payment list
  double getPendingAmount(List<Payment> payments, [double? precalculatedPaid]) {
    final paid = precalculatedPaid ?? getAmountPaid(payments);
    final remaining = amountDue - paid;
    return remaining > 0 ? remaining : 0.0;
  }

  // Determine Payment Status based on pre-calculated paid amount or payments list
  PaymentStatus getStatus(List<Payment> payments, [double? precalculatedPaid]) {
    final paid = precalculatedPaid ?? getAmountPaid(payments);
    return getStatusFromPaid(paid);
  }

  /// Fast O(1) status calculation using direct paid amount
  PaymentStatus getStatusFromPaid(double paid) {
    if (paid >= amountDue && amountDue > 0) {
      return PaymentStatus.paid;
    } else if (paid == 0 || amountDue <= 0) {
      return PaymentStatus.unpaid;
    } else {
      return PaymentStatus.partial;
    }
  }

  // Retrieve date of latest payment if any
  DateTime? getLastPaymentDate(List<Payment> payments) {
    final memberPayments = payments.where((p) => p.contributorId == id).toList();
    if (memberPayments.isEmpty) return null;
    memberPayments.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
    return memberPayments.first.paymentDate;
  }

  Contributor copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    double? amountDue,
    String? notes,
    DateTime? createdAt,
  }) {
    return Contributor(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      amountDue: amountDue ?? this.amountDue,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
