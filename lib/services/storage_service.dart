import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/contributor.dart';
import '../models/payment.dart';
import 'sample_data.dart';

class StorageService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference<Map<String, dynamic>> _contributorsRef =
      _firestore.collection('contributors');
  static final CollectionReference<Map<String, dynamic>> _paymentsRef =
      _firestore.collection('payments');

  /// Stream of contributors from Cloud Firestore in real-time
  static Stream<List<Contributor>> getContributorsStream() {
    return _contributorsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        if (!data.containsKey('id') || data['id'] == null || (data['id'] as String).isEmpty) {
          data['id'] = doc.id;
        }
        return Contributor.fromMap(data);
      }).toList();
    });
  }

  /// Stream of payments from Cloud Firestore in real-time
  static Stream<List<Payment>> getPaymentsStream() {
    return _paymentsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        if (!data.containsKey('id') || data['id'] == null || (data['id'] as String).isEmpty) {
          data['id'] = doc.id;
        }
        return Payment.fromMap(data);
      }).toList();
    });
  }

  /// Check if contributors collection is empty and seed initial sample data once
  static Future<void> checkAndSeedInitialData() async {
    try {
      final snapshot = await _contributorsRef.limit(1).get();
      if (snapshot.docs.isEmpty) {
        await seedSampleData();
      }
    } catch (e) {
      // Ignore if unauthenticated or error
    }
  }

  /// Seed initial sample data into Firestore as individual documents
  static Future<void> seedSampleData() async {
    final sampleContributors = SampleData.getInitialContributors();
    for (final c in sampleContributors) {
      await saveContributor(c);
    }

    final samplePayments = SampleData.getInitialPayments();
    for (final p in samplePayments) {
      await savePayment(p);
    }
  }

  /// Save or update a Contributor as an individual Firestore document using its existing ID
  static Future<void> saveContributor(Contributor contributor) async {
    await _contributorsRef.doc(contributor.id).set(contributor.toMap());
  }

  /// Delete a Contributor document and associated payment documents
  static Future<void> deleteContributor(String contributorId) async {
    await _contributorsRef.doc(contributorId).delete();
    await deletePaymentsForContributor(contributorId);
  }

  /// Save or update a Payment as an individual Firestore document using its existing ID
  static Future<void> savePayment(Payment payment) async {
    await _paymentsRef.doc(payment.id).set(payment.toMap());
  }

  /// Delete a Payment document by ID
  static Future<void> deletePayment(String paymentId) async {
    await _paymentsRef.doc(paymentId).delete();
  }

  /// Delete all payments for a specific contributor
  static Future<void> deletePaymentsForContributor(String contributorId) async {
    final snapshot = await _paymentsRef.where('contributorId', isEqualTo: contributorId).get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// Reset to sample data: delete existing documents and seed sample data
  static Future<void> resetToSampleData() async {
    await clearAllData();
    await seedSampleData();
  }

  /// Clear all data in contributors and payments collections
  static Future<void> clearAllData() async {
    final contributorsSnap = await _contributorsRef.get();
    for (final doc in contributorsSnap.docs) {
      await doc.reference.delete();
    }

    final paymentsSnap = await _paymentsRef.get();
    for (final doc in paymentsSnap.docs) {
      await doc.reference.delete();
    }
  }
}
