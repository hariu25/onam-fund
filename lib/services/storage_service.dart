import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/contributor.dart';
import '../models/payment.dart';
import 'sample_data.dart';

class StorageService {
  static const String _keyContributors = 'onam_contributors_v1';
  static const String _keyPayments = 'onam_payments_v1';
  static const String _keyInitialLoaded = 'onam_initial_loaded_v1';

  static Future<List<Contributor>> getContributors() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoaded = prefs.getBool(_keyInitialLoaded) ?? false;

    if (!isLoaded) {
      // First run: pre-populate sample data
      final samples = SampleData.getInitialContributors();
      await saveContributors(samples);
      final samplePayments = SampleData.getInitialPayments();
      await savePayments(samplePayments);
      await prefs.setBool(_keyInitialLoaded, true);
      return samples;
    }

    final String? jsonStr = prefs.getString(_keyContributors);
    if (jsonStr == null || jsonStr.isEmpty) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      return jsonList.map((item) => Contributor.fromMap(item)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveContributors(List<Contributor> list) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList =
        list.map((c) => c.toMap()).toList();
    await prefs.setString(_keyContributors, jsonEncode(jsonList));
  }

  static Future<List<Payment>> getPayments() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString(_keyPayments);
    if (jsonStr == null || jsonStr.isEmpty) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      return jsonList.map((item) => Payment.fromMap(item)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> savePayments(List<Payment> list) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList =
        list.map((p) => p.toMap()).toList();
    await prefs.setString(_keyPayments, jsonEncode(jsonList));
  }

  static Future<void> resetToSampleData() async {
    final samples = SampleData.getInitialContributors();
    final samplePayments = SampleData.getInitialPayments();
    await saveContributors(samples);
    await savePayments(samplePayments);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyInitialLoaded, true);
  }

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyContributors);
    await prefs.remove(_keyPayments);
  }
}
