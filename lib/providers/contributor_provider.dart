import 'dart:async';
import 'package:flutter/material.dart';
import '../models/contributor.dart';
import '../models/payment.dart';
import '../services/storage_service.dart';

class ContributorProvider extends ChangeNotifier {
  List<Contributor> _contributors = [];
  List<Payment> _payments = [];
  bool _isLoading = true;

  StreamSubscription<List<Contributor>>? _contributorsSubscription;
  StreamSubscription<List<Payment>>? _paymentsSubscription;

  // Search, Filter, Sort States
  String _searchQuery = '';
  String _statusFilter = 'All'; // 'All', 'Paid', 'Unpaid', 'Partial'
  String _sortBy = 'name'; // 'name', 'amountDue', 'amountPaid', 'status'
  bool _sortAscending = true;

  ContributorProvider() {
    initDataStream();
  }

  // Getters
  List<Contributor> get contributors => _contributors;
  List<Payment> get payments => _payments;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;

  /// Initialize Firestore real-time snapshot listeners
  void initDataStream() {
    _isLoading = true;
    notifyListeners();

    _contributorsSubscription?.cancel();
    _paymentsSubscription?.cancel();

    StorageService.checkAndSeedInitialData().then((_) {
      _contributorsSubscription = StorageService.getContributorsStream().listen(
        (contributorsList) {
          _contributors = contributorsList;
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          _isLoading = false;
          notifyListeners();
        },
      );

      _paymentsSubscription = StorageService.getPaymentsStream().listen(
        (paymentsList) {
          _payments = paymentsList;
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          _isLoading = false;
          notifyListeners();
        },
      );
    });
  }

  /// Clear data on logout so unauthenticated users don't access cached data
  void clearDataOnLogout() {
    _contributorsSubscription?.cancel();
    _paymentsSubscription?.cancel();
    _contributors = [];
    _payments = [];
    _isLoading = true;
    notifyListeners();
  }

  // Load data method for backwards compatibility
  Future<void> loadData() async {
    initDataStream();
  }

  // Summary Metrics Getters
  int get totalMembers => _contributors.length;

  double get totalExpected {
    return _contributors.fold(0.0, (sum, c) => sum + c.amountDue);
  }

  double get totalCollected {
    return _payments.fold(0.0, (sum, p) => sum + p.amount);
  }

  double get pendingAmount {
    final pending = totalExpected - totalCollected;
    return pending > 0 ? pending : 0.0;
  }

  int get paidCount {
    return _contributors.where((c) => c.getStatus(_payments) == PaymentStatus.paid).length;
  }

  int get unpaidCount {
    return _contributors.where((c) => c.getStatus(_payments) == PaymentStatus.unpaid).length;
  }

  int get partialCount {
    return _contributors.where((c) => c.getStatus(_payments) == PaymentStatus.partial).length;
  }

  // Payments for specific contributor
  List<Payment> getPaymentsForContributor(String contributorId) {
    final list = _payments.where((p) => p.contributorId == contributorId).toList();
    list.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
    return list;
  }

  // Filtered and Sorted Contributors List
  List<Contributor> get filteredContributors {
    return _contributors.where((c) {
      // 1. Search Query filter (matches Name, Member ID, or Phone)
      final q = _searchQuery.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          c.name.toLowerCase().contains(q) ||
          c.id.toLowerCase().contains(q) ||
          c.phone.toLowerCase().contains(q);

      if (!matchesSearch) return false;

      // 2. Status Filter
      final status = c.getStatus(_payments);
      if (_statusFilter == 'Paid' && status != PaymentStatus.paid) return false;
      if (_statusFilter == 'Unpaid' && status != PaymentStatus.unpaid) return false;
      if (_statusFilter == 'Partial' && status != PaymentStatus.partial) return false;

      return true;
    }).toList()
      ..sort((a, b) {
        int comparison = 0;
        switch (_sortBy) {
          case 'name':
            comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
            break;
          case 'amountDue':
            comparison = a.amountDue.compareTo(b.amountDue);
            break;
          case 'amountPaid':
            comparison = a.getAmountPaid(_payments).compareTo(b.getAmountPaid(_payments));
            break;
          case 'status':
            comparison = a.getStatus(_payments).index.compareTo(b.getStatus(_payments).index);
            break;
          default:
            comparison = a.name.compareTo(b.name);
        }
        return _sortAscending ? comparison : -comparison;
      });
  }

  // Add Contributor (with optional immediate initial payment)
  Future<void> addContributor(
    Contributor contributor, {
    double? initialPaymentAmount,
    String? initialPaymentMethod,
    String? initialPaymentNotes,
  }) async {
    await StorageService.saveContributor(contributor);

    if (initialPaymentAmount != null && initialPaymentAmount > 0) {
      final payment = Payment(
        id: 'PAY-${DateTime.now().millisecondsSinceEpoch}',
        contributorId: contributor.id,
        amount: initialPaymentAmount,
        paymentDate: DateTime.now(),
        paymentMethod: initialPaymentMethod ?? 'Cash',
        notes: initialPaymentNotes ?? 'Initial payment on registration',
      );
      await StorageService.savePayment(payment);
    }
  }

  // Edit Contributor details & amount due
  Future<void> editContributor(Contributor updatedContributor) async {
    await StorageService.saveContributor(updatedContributor);
  }

  // Delete Contributor and associated payments
  Future<void> deleteContributor(String contributorId) async {
    await StorageService.deleteContributor(contributorId);
  }

  // Record Payment
  Future<void> addPayment(Payment payment) async {
    await StorageService.savePayment(payment);
  }

  // Delete Payment
  Future<void> deletePayment(String paymentId) async {
    await StorageService.deletePayment(paymentId);
  }

  // Search & Filter Setters
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  void setSortBy(String field) {
    if (_sortBy == field) {
      _sortAscending = !_sortAscending;
    } else {
      _sortBy = field;
      _sortAscending = true;
    }
    notifyListeners();
  }

  // Reset to Sample Data in Firestore
  Future<void> resetToSampleData() async {
    _isLoading = true;
    notifyListeners();

    await StorageService.resetToSampleData();
  }

  // Clear All Data in Firestore
  Future<void> clearAllData() async {
    await StorageService.clearAllData();
  }

  // Generate Unique Member ID
  String generateMemberId() {
    int maxIdNum = 1000;
    for (final c in _contributors) {
      final parts = c.id.split('-');
      if (parts.length == 2) {
        final num = int.tryParse(parts[1]);
        if (num != null && num > maxIdNum) {
          maxIdNum = num;
        }
      }
    }
    return 'ONAM-${maxIdNum + 1}';
  }

  @override
  void dispose() {
    _contributorsSubscription?.cancel();
    _paymentsSubscription?.cancel();
    super.dispose();
  }
}
