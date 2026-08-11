import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/contributor.dart';
import '../models/payment.dart';
import '../services/storage_service.dart';

class ContributorProvider extends ChangeNotifier {
  List<Contributor> _contributors = [];
  List<Payment> _payments = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Performance benchmark logs
  final Map<String, int> _lastPerformanceMetricsMs = {};

  // Indexed payment lookups for O(1) time complexity
  final Map<String, List<Payment>> _paymentsByContributor = {};
  final Map<String, double> _paidAmountByContributor = {};

  // Cached summary metrics
  double _totalExpectedCache = 0.0;
  double _totalCollectedCache = 0.0;
  int _paidCountCache = 0;
  int _unpaidCountCache = 0;
  int _partialCountCache = 0;
  bool _metricsDirty = true;

  // Cached filtered list
  List<Contributor>? _filteredContributorsCache;
  bool _filteredListDirty = true;

  // Debounce timer for search queries
  Timer? _searchDebounceTimer;

  // Pagination & Lazy Loading state
  static const int _pageSize = 20;
  int _displayedItemCount = _pageSize;

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

  /// Returns the latest 5 payment transactions sorted by paymentDate in descending order.
  /// Only actual payment transactions (amount > 0) are included.
  List<Payment> get recentPayments {
    final validPayments = _payments.where((p) => p.amount > 0).toList();
    validPayments.sort((a, b) {
      final dateCmp = b.paymentDate.compareTo(a.paymentDate);
      if (dateCmp != 0) return dateCmp;
      return b.id.compareTo(a.id);
    });
    return validPayments.take(5).toList();
  }

  /// Testing helper method to set contributors directly without Firebase
  void setMockContributors(List<Contributor> list) {
    _contributorsSubscription?.cancel();
    _contributors = List.from(list);
    _invalidateCaches();
    notifyListeners();
  }

  /// Testing helper method to set payments directly without Firebase
  void setMockPayments(List<Payment> list) {
    _paymentsSubscription?.cancel();
    _payments = List.from(list);
    _reindexPayments();
    _invalidateCaches();
    notifyListeners();
  }
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;
  int get displayedItemCount => _displayedItemCount;
  int get pageSize => _pageSize;
  Map<String, int> get performanceMetricsMs => _lastPerformanceMetricsMs;

  /// Fast O(1) lookups using pre-indexed payment mappings
  double getAmountPaidForContributor(String contributorId) {
    return _paidAmountByContributor[contributorId] ?? 0.0;
  }

  /// Initialize Firestore real-time snapshot listeners with timing profiling
  bool _hasInitializedDataStream = false;

  void initDataStream() async {
    if (_hasInitializedDataStream && _contributorsSubscription != null && _paymentsSubscription != null) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _contributorsSubscription?.cancel();
    _paymentsSubscription?.cancel();

    final stopwatch = Stopwatch()..start();

    try {
      if (!_hasInitializedDataStream) {
        _hasInitializedDataStream = true;
      }

      _contributorsSubscription = StorageService.getContributorsStream().listen(
        (contributorsList) {
          final parseTime = stopwatch.elapsedMilliseconds;
          _contributors = contributorsList;
          _invalidateCaches();
          _isLoading = false;
          _lastPerformanceMetricsMs['contributorsStreamMs'] = parseTime;
          notifyListeners();
        },
        onError: (error) {
          _isLoading = false;
          _errorMessage = 'Failed to load member data: $error';
          notifyListeners();
        },
      );

      _paymentsSubscription = StorageService.getPaymentsStream().listen(
        (paymentsList) {
          final parseTime = stopwatch.elapsedMilliseconds;
          _payments = paymentsList;
          _reindexPayments();
          _invalidateCaches();
          _isLoading = false;
          _lastPerformanceMetricsMs['paymentsStreamMs'] = parseTime;
          notifyListeners();
        },
        onError: (error) {
          _isLoading = false;
          _errorMessage = 'Failed to load payment records: $error';
          notifyListeners();
        },
      );
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Database initialization error: $error';
      notifyListeners();
    }
  }

  /// Re-index payments into O(1) lookup maps
  void _reindexPayments() {
    final sw = Stopwatch()..start();
    _paymentsByContributor.clear();
    _paidAmountByContributor.clear();

    for (final payment in _payments) {
      _paymentsByContributor.putIfAbsent(payment.contributorId, () => []).add(payment);
      _paidAmountByContributor[payment.contributorId] =
          (_paidAmountByContributor[payment.contributorId] ?? 0.0) + payment.amount;
    }

    // Sort payment lists by date descending once during indexing
    for (final list in _paymentsByContributor.values) {
      list.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
    }
    sw.stop();
    _lastPerformanceMetricsMs['indexingMs'] = sw.elapsedMilliseconds;
  }

  /// Invalidate memoized caches when underlying state changes
  void _invalidateCaches() {
    _metricsDirty = true;
    _filteredListDirty = true;
  }

  /// Clear data on logout so unauthenticated users don't access cached data
  void clearDataOnLogout() {
    _contributorsSubscription?.cancel();
    _paymentsSubscription?.cancel();
    _contributorsSubscription = null;
    _paymentsSubscription = null;
    _contributors = [];
    _payments = [];
    _paymentsByContributor.clear();
    _paidAmountByContributor.clear();
    _invalidateCaches();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  }

  // Load data method for backwards compatibility
  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    initDataStream();
  }

  /// Retry data fetch on error
  void retryFetch() {
    _contributorsSubscription?.cancel();
    _paymentsSubscription?.cancel();
    _contributorsSubscription = null;
    _paymentsSubscription = null;
    _hasInitializedDataStream = false;
    initDataStream();
  }

  // Summary Metrics Getters (Memoized)
  int get totalMembers => _contributors.length;

  void _recomputeMetricsIfNeeded() {
    if (!_metricsDirty) return;
    final sw = Stopwatch()..start();

    _totalExpectedCache = _contributors.fold(0.0, (acc, c) => acc + c.amountDue);
    _totalCollectedCache = _payments.fold(0.0, (acc, p) => acc + p.amount);

    int paid = 0;
    int unpaid = 0;
    int partial = 0;

    for (final c in _contributors) {
      final amountPaid = _paidAmountByContributor[c.id] ?? 0.0;
      final status = c.getStatusFromPaid(amountPaid);
      if (status == PaymentStatus.paid) {
        paid++;
      } else if (status == PaymentStatus.unpaid) {
        unpaid++;
      } else {
        partial++;
      }
    }

    _paidCountCache = paid;
    _unpaidCountCache = unpaid;
    _partialCountCache = partial;
    _metricsDirty = false;

    sw.stop();
    _lastPerformanceMetricsMs['metricsComputeMs'] = sw.elapsedMilliseconds;
  }

  double get totalExpected {
    _recomputeMetricsIfNeeded();
    return _totalExpectedCache;
  }

  double get totalCollected {
    _recomputeMetricsIfNeeded();
    return _totalCollectedCache;
  }

  double get pendingAmount {
    final pending = totalExpected - totalCollected;
    return pending > 0 ? pending : 0.0;
  }

  int get paidCount {
    _recomputeMetricsIfNeeded();
    return _paidCountCache;
  }

  int get unpaidCount {
    _recomputeMetricsIfNeeded();
    return _unpaidCountCache;
  }

  int get partialCount {
    _recomputeMetricsIfNeeded();
    return _partialCountCache;
  }

  // Payments for specific contributor using O(1) indexed lookup map
  List<Payment> getPaymentsForContributor(String contributorId) {
    return _paymentsByContributor[contributorId] ?? const [];
  }

  // Filtered and Sorted Contributors List (Memoized with O(1) payment lookups)
  List<Contributor> get filteredContributors {
    if (!_filteredListDirty && _filteredContributorsCache != null) {
      return _filteredContributorsCache!;
    }

    final sw = Stopwatch()..start();
    final q = _searchQuery.trim().toLowerCase();

    final filtered = _contributors.where((c) {
      // 1. Search Query filter (matches Name, Member ID, or Phone)
      final matchesSearch = q.isEmpty ||
          c.name.toLowerCase().contains(q) ||
          c.id.toLowerCase().contains(q) ||
          c.phone.toLowerCase().contains(q);

      if (!matchesSearch) return false;

      // 2. Status Filter using fast indexed paid amount
      final paid = _paidAmountByContributor[c.id] ?? 0.0;
      final status = c.getStatusFromPaid(paid);
      if (_statusFilter == 'Paid' && status != PaymentStatus.paid) return false;
      if (_statusFilter == 'Unpaid' && status != PaymentStatus.unpaid) return false;
      if (_statusFilter == 'Partial' && status != PaymentStatus.partial) return false;

      return true;
    }).toList();

    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'name':
          comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          break;
        case 'amountDue':
          comparison = a.amountDue.compareTo(b.amountDue);
          break;
        case 'amountPaid':
          final paidA = _paidAmountByContributor[a.id] ?? 0.0;
          final paidB = _paidAmountByContributor[b.id] ?? 0.0;
          comparison = paidA.compareTo(paidB);
          break;
        case 'status':
          final paidA = _paidAmountByContributor[a.id] ?? 0.0;
          final paidB = _paidAmountByContributor[b.id] ?? 0.0;
          comparison = a.getStatusFromPaid(paidA).index.compareTo(b.getStatusFromPaid(paidB).index);
          break;
        default:
          comparison = a.name.compareTo(b.name);
      }
      return _sortAscending ? comparison : -comparison;
    });

    _filteredContributorsCache = filtered;
    _filteredListDirty = false;

    sw.stop();
    _lastPerformanceMetricsMs['filterSortMs'] = sw.elapsedMilliseconds;
    return _filteredContributorsCache!;
  }

  /// Paginated items subset for virtualized lazy loading
  List<Contributor> get paginatedFilteredContributors {
    final fullList = filteredContributors;
    if (_displayedItemCount >= fullList.length) {
      return fullList;
    }
    return fullList.take(_displayedItemCount).toList();
  }

  bool get hasMoreItems {
    return _displayedItemCount < filteredContributors.length;
  }

  void loadMoreItems() {
    if (hasMoreItems) {
      _displayedItemCount += _pageSize;
      notifyListeners();
    }
  }

  void resetPagination() {
    _displayedItemCount = _pageSize;
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

    // Save contribution entry to 'fund_entries' collection in Cloud Firestore
    try {
      await FirebaseFirestore.instance.collection('fund_entries').add({
        'contributorId': contributor.id,
        'contributorName': contributor.name,
        'name': contributor.name,
        'address': contributor.address,
        'phone': contributor.phone,
        'amount': contributor.amountDue,
        'amountDue': contributor.amountDue,
        'date': contributor.createdAt.toIso8601String(),
        'notes': contributor.notes,
        'initialPaymentAmount': initialPaymentAmount,
        'initialPaymentMethod': initialPaymentMethod,
        'initialPaymentNotes': initialPaymentNotes,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  // Edit Contributor details & amount due
  Future<void> editContributor(Contributor updatedContributor) async {
    await StorageService.saveContributor(updatedContributor);

    // Save update record to 'fund_entries' collection in Cloud Firestore
    try {
      await FirebaseFirestore.instance.collection('fund_entries').add({
        'contributorId': updatedContributor.id,
        'contributorName': updatedContributor.name,
        'name': updatedContributor.name,
        'address': updatedContributor.address,
        'phone': updatedContributor.phone,
        'amount': updatedContributor.amountDue,
        'amountDue': updatedContributor.amountDue,
        'date': DateTime.now().toIso8601String(),
        'notes': updatedContributor.notes,
        'isUpdate': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  // Delete Contributor and associated payments
  Future<void> deleteContributor(String contributorId) async {
    await StorageService.deleteContributor(contributorId);
  }

  // Record Payment
  Future<void> addPayment(Payment payment) async {
    try {
      await StorageService.savePayment(payment);
    } catch (_) {}
    final existingIndex = _payments.indexWhere((p) => p.id == payment.id);
    if (existingIndex != -1) {
      _payments[existingIndex] = payment;
    } else {
      _payments.add(payment);
    }
    _reindexPayments();
    _invalidateCaches();
    notifyListeners();
  }

  // Delete Payment
  Future<void> deletePayment(String paymentId) async {
    try {
      await StorageService.deletePayment(paymentId);
    } catch (_) {}
    _payments.removeWhere((p) => p.id == paymentId);
    _reindexPayments();
    _invalidateCaches();
    notifyListeners();
  }

  // Search & Filter Setters with Debouncing
  void setSearchQuery(String query, {bool immediate = false}) {
    if (_searchQuery == query) return;

    if (immediate || query.isEmpty) {
      _searchDebounceTimer?.cancel();
      _searchQuery = query;
      resetPagination();
      _filteredListDirty = true;
      notifyListeners();
      return;
    }

    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 250), () {
      _searchQuery = query;
      resetPagination();
      _filteredListDirty = true;
      notifyListeners();
    });
  }

  void setStatusFilter(String filter) {
    if (_statusFilter == filter) return;
    _statusFilter = filter;
    resetPagination();
    _filteredListDirty = true;
    notifyListeners();
  }

  void setSortBy(String field) {
    if (_sortBy == field) {
      _sortAscending = !_sortAscending;
    } else {
      _sortBy = field;
      _sortAscending = true;
    }
    resetPagination();
    _filteredListDirty = true;
    notifyListeners();
  }

  // Clear All Data in Firestore
  Future<void> clearAllData() async {
    try {
      await StorageService.clearAllData();
    } catch (e) {
      _errorMessage = 'Failed to clear data: $e';
      notifyListeners();
    }
  }

  // Generate Unique Member ID with SMB prefix and 4-digit formatting
  String generateMemberId() {
    int maxIdNum = 1000;
    final existingIds = _contributors.map((c) => c.id.toUpperCase()).toSet();

    for (final c in _contributors) {
      final parts = c.id.split('-');
      if (parts.length == 2) {
        final num = int.tryParse(parts[1]);
        if (num != null && num > maxIdNum) {
          maxIdNum = num;
        }
      }
    }

    int nextNum = maxIdNum + 1;
    String candidateId = 'SMB-${nextNum.toString().padLeft(4, '0')}';
    while (existingIds.contains(candidateId.toUpperCase())) {
      nextNum++;
      candidateId = 'SMB-${nextNum.toString().padLeft(4, '0')}';
    }
    return candidateId;
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _contributorsSubscription?.cancel();
    _paymentsSubscription?.cancel();
    super.dispose();
  }
}
