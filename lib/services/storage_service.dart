import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/contributor.dart';
import '../models/payment.dart';
import 'sample_data.dart';

class StorageService {
  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  static CollectionReference<Map<String, dynamic>> get _contributorsRef =>
      _firestore.collection('contributors');
  static CollectionReference<Map<String, dynamic>> get _paymentsRef =>
      _firestore.collection('payments');

  /// Stream of contributors from Cloud Firestore in real-time
  static Stream<List<Contributor>> getContributorsStream() {
    try {
      return _contributorsRef.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          if (!data.containsKey('id') || data['id'] == null || (data['id'] as String).isEmpty) {
            data['id'] = doc.id;
          }
          return Contributor.fromMap(data);
        }).toList();
      });
    } catch (e) {
      // Fallback for widget/unit test environment where Firebase is uninitialized
      return Stream.value(SampleData.getInitialContributors());
    }
  }

  /// Stream of payments from Cloud Firestore in real-time
  static Stream<List<Payment>> getPaymentsStream() {
    try {
      return _paymentsRef.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          if (!data.containsKey('id') || data['id'] == null || (data['id'] as String).isEmpty) {
            data['id'] = doc.id;
          }
          return Payment.fromMap(data);
        }).toList();
      });
    } catch (e) {
      // Fallback for widget/unit test environment where Firebase is uninitialized
      return Stream.value(SampleData.getInitialPayments());
    }
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

  /// Seed initial sample data into Firestore in parallel using a WriteBatch
  static Future<void> seedSampleData() async {
    final batch = _firestore.batch();
    final sampleContributors = SampleData.getInitialContributors();
    for (final c in sampleContributors) {
      batch.set(_contributorsRef.doc(c.id), c.toMap());
    }

    final samplePayments = SampleData.getInitialPayments();
    for (final p in samplePayments) {
      batch.set(_paymentsRef.doc(p.id), p.toMap());
    }

    await batch.commit();
  }

  /// Save or update a Contributor as an individual Firestore document using its existing ID
  static Future<void> saveContributor(Contributor contributor) async {
    await _contributorsRef.doc(contributor.id).set(contributor.toMap());
  }

  /// Delete a Contributor document and associated payment documents
  static Future<void> deleteContributor(String contributorId) async {
    final batch = _firestore.batch();
    batch.delete(_contributorsRef.doc(contributorId));
    final snapshot = await _paymentsRef.where('contributorId', isEqualTo: contributorId).get();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// Save or update a Payment as an individual Firestore document using its existing ID
  static Future<void> savePayment(Payment payment) async {
    await _paymentsRef.doc(payment.id).set(payment.toMap());
  }

  /// Delete a Payment document by ID
  static Future<void> deletePayment(String paymentId) async {
    await _paymentsRef.doc(paymentId).delete();
  }

  /// Delete all payments for a specific contributor using batch operations
  static Future<void> deletePaymentsForContributor(String contributorId) async {
    final snapshot = await _paymentsRef.where('contributorId', isEqualTo: contributorId).get();
    if (snapshot.docs.isEmpty) return;
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// Reset to sample data: delete existing documents and seed sample data
  static Future<void> resetToSampleData() async {
    await clearAllData();
    await seedSampleData();
  }

  /// Clear all data in contributors and payments collections using batched deletes
  static Future<void> clearAllData() async {
    final contributorsSnap = await _contributorsRef.get();
    final paymentsSnap = await _paymentsRef.get();

    WriteBatch batch = _firestore.batch();
    int count = 0;

    for (final doc in contributorsSnap.docs) {
      batch.delete(doc.reference);
      count++;
      if (count % 450 == 0) {
        await batch.commit();
        batch = _firestore.batch();
      }
    }

    for (final doc in paymentsSnap.docs) {
      batch.delete(doc.reference);
      count++;
      if (count % 450 == 0) {
        await batch.commit();
        batch = _firestore.batch();
      }
    }

    if (count % 450 != 0) {
      await batch.commit();
    }
  }
}
