import 'package:intl/intl.dart';

class Payment {
  final String id;
  final String contributorId;
  final String? memberName;
  final double amount;
  final DateTime paymentDate;
  final String paymentMethod; // Cash, UPI, Bank Transfer, Cheque, GPay, etc.
  final String? notes;

  Payment({
    required this.id,
    required this.contributorId,
    this.memberName,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contributorId': contributorId,
      'memberName': memberName,
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
      'paymentMethod': paymentMethod,
      'notes': notes,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] ?? '',
      contributorId: map['contributorId'] ?? '',
      memberName: map['memberName'] ?? map['contributorName'] ?? map['name'],
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      paymentDate: map['paymentDate'] != null
          ? DateTime.parse(map['paymentDate'])
          : DateTime.now(),
      paymentMethod: map['paymentMethod'] ?? 'Cash',
      notes: map['notes'],
    );
  }

  String get formattedDate {
    return DateFormat('MMM dd, yyyy').format(paymentDate);
  }

  String get formattedTime {
    return DateFormat('hh:mm a').format(paymentDate);
  }

  Payment copyWith({
    String? id,
    String? contributorId,
    String? memberName,
    double? amount,
    DateTime? paymentDate,
    String? paymentMethod,
    String? notes,
  }) {
    return Payment(
      id: id ?? this.id,
      contributorId: contributorId ?? this.contributorId,
      memberName: memberName ?? this.memberName,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
    );
  }
}
