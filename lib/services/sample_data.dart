import '../models/contributor.dart';
import '../models/payment.dart';

class SampleData {
  static List<Contributor> getInitialContributors() {
    final now = DateTime.now();
    return [
      Contributor(
        id: 'ONAM-1001',
        name: 'Unnikrishnan Nair',
        address: 'House #42, Rose Villa, MG Road, Kochi',
        phone: '9847012345',
        amountDue: 5000.0,
        notes: 'Executive Committee Member. Prompt payer.',
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      Contributor(
        id: 'ONAM-1002',
        name: 'Lakshmi Devi',
        address: 'Flat 3B, Skyine Apartments, Trivandrum',
        phone: '9447154321',
        amountDue: 5000.0,
        notes: 'Pookkalam competition sponsor.',
        createdAt: now.subtract(const Duration(days: 14)),
      ),
      Contributor(
        id: 'ONAM-1003',
        name: 'Rahul Menon',
        address: 'Plot 18, Coconut Grove, Thrissur',
        phone: '9745889911',
        amountDue: 3000.0,
        notes: 'Cultural event coordinator.',
        createdAt: now.subtract(const Duration(days: 12)),
      ),
      Contributor(
        id: 'ONAM-1004',
        name: 'Dr. K.V. Thomas',
        address: 'Lotus Haven, Beach Road, Calicut',
        phone: '9895011223',
        amountDue: 10000.0,
        notes: 'Grand Feast (Sadhya) Lead Sponsor.',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      Contributor(
        id: 'ONAM-1005',
        name: 'Ananya Pillai',
        address: 'No. 7, Palm Avenue, Kottayam',
        phone: '9496332211',
        amountDue: 3500.0,
        notes: 'Onam games and prize volunteer.',
        createdAt: now.subtract(const Duration(days: 8)),
      ),
      Contributor(
        id: 'ONAM-1006',
        name: 'Vijayakumar P.',
        address: 'Vallam, Alappuzha',
        phone: '9605447788',
        amountDue: 4000.0,
        notes: 'Boat race program team.',
        createdAt: now.subtract(const Duration(days: 6)),
      ),
      Contributor(
        id: 'ONAM-1007',
        name: 'Swapna Suresh',
        address: 'Green Gardens, Palakkad',
        phone: '9123456789',
        amountDue: 2500.0,
        notes: 'Family contribution.',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Contributor(
        id: 'ONAM-1008',
        name: 'Gautham Krishna',
        address: 'Door 15, Lake View, Kollam',
        phone: '9988776655',
        amountDue: 5000.0,
        notes: 'Sound & Lighting setup partner.',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
    ];
  }

  static List<Payment> getInitialPayments() {
    final now = DateTime.now();
    return [
      // Unnikrishnan Nair (Paid in Full - ONAM-1001)
      Payment(
        id: 'PAY-1001-1',
        contributorId: 'ONAM-1001',
        amount: 5000.0,
        paymentDate: now.subtract(const Duration(days: 10)),
        paymentMethod: 'UPI / GPay',
        notes: 'UPI Ref: 42391088219',
      ),
      // Lakshmi Devi (Partial Payment - ONAM-1002)
      Payment(
        id: 'PAY-1002-1',
        contributorId: 'ONAM-1002',
        amount: 2500.0,
        paymentDate: now.subtract(const Duration(days: 7)),
        paymentMethod: 'Cash',
        notes: 'Received by Treasurer at Committee meeting',
      ),
      // Rahul Menon (Unpaid - 0 payments for ONAM-1003)
      
      // Dr. K.V. Thomas (Multiple Payments total 10,000 - ONAM-1004)
      Payment(
        id: 'PAY-1004-1',
        contributorId: 'ONAM-1004',
        amount: 5000.0,
        paymentDate: now.subtract(const Duration(days: 8)),
        paymentMethod: 'Bank Transfer',
        notes: 'NeFT Ref: HDFC9901827',
      ),
      Payment(
        id: 'PAY-1004-2',
        contributorId: 'ONAM-1004',
        amount: 5000.0,
        paymentDate: now.subtract(const Duration(days: 2)),
        paymentMethod: 'UPI / PhonePe',
        notes: 'Final installment paid',
      ),
      // Ananya Pillai (Paid in Full - ONAM-1005)
      Payment(
        id: 'PAY-1005-1',
        contributorId: 'ONAM-1005',
        amount: 3500.0,
        paymentDate: now.subtract(const Duration(days: 4)),
        paymentMethod: 'UPI / Paytm',
        notes: 'Paid online',
      ),
      // Vijayakumar P. (Partial Payment - ONAM-1006)
      Payment(
        id: 'PAY-1006-1',
        contributorId: 'ONAM-1006',
        amount: 1500.0,
        paymentDate: now.subtract(const Duration(days: 3)),
        paymentMethod: 'Cash',
        notes: 'Advance given',
      ),
      // Swapna Suresh (Unpaid - ONAM-1007)
      // Gautham Krishna (Paid in Full - ONAM-1008)
      Payment(
        id: 'PAY-1008-1',
        contributorId: 'ONAM-1008',
        amount: 5000.0,
        paymentDate: now.subtract(const Duration(days: 1)),
        paymentMethod: 'Bank Transfer',
        notes: 'Direct account transfer',
      ),
    ];
  }
}
