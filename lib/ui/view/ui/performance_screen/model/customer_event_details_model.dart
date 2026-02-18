import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class CustomerEventModel {
  final String customerName;
  final DateTime visitDate;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final String statusText;

  CustomerEventModel({
    required this.customerName,
    required this.visitDate,
    this.checkIn,
    this.checkOut,
    required this.statusText,
  });

  factory CustomerEventModel.fromJson(Map<String, dynamic> json) {
    // Helper to parse dates safely
    DateTime? parseDate(String? dateStr) {
      if (dateStr == null) return null;
      return DateTime.tryParse(dateStr)?.toLocal(); // Convert to local time
    }

    // Logic: If check_in is null, it's "Missed", otherwise "Completed"
    String derivedStatus = json['check_in'] == null ? 'Missed' : 'Completed';

    return CustomerEventModel(
      customerName: json['customer_name'] ?? 'Unknown',
      visitDate: parseDate(json['start']) ?? DateTime.now(),
      checkIn: parseDate(json['check_in']),
      checkOut: parseDate(json['check_out']),
      statusText: derivedStatus,
    );
  }
}