import 'package:cloud_firestore/cloud_firestore.dart';

class PortfolioModel {
  final String _service;
  final String _details;
  final int _years;
  final int _months;
  final List<Map<String, String>> _images;
  final DateTime? _experienceStartDate;
  final String? _address;
  final Map<String, double?>? _latAndLong;
  final String? _professionalsName;
  final String _uid;
  final List<String>? _nameArray;


  PortfolioModel({
    required String service,
    required String uid,
    String details = "",
    int years = 0,
    int months = 0,
    List<Map<String, String>> images = const [],
    DateTime? experienceStartDate,
     String? address,
     Map<String, double?>? latAndLong,
    String? professionalsName,
    List<String>? nameArray
  })  : _service = service,
        _uid = uid,
        _details = details,
        _years = years,
        _months = months,
        _images = images ,
        _experienceStartDate = experienceStartDate,
        _address = address,
        _latAndLong = latAndLong,
        _professionalsName = professionalsName,
        _nameArray = nameArray
        {
    if (service.isEmpty) {
      throw ArgumentError('service cannot be empty');
    }
    if (uid.isEmpty) {
      throw ArgumentError('UID cannot be empty');
    }
  }

  String get service => _service;
  String get details => _details;
  int get years => _years;
  int get months => _months;
  List<Map<String, String>> get images => _images;
  DateTime? get experienceStartDate => _experienceStartDate;
  String? get address => _address;
   Map<String, double?>? get latAndLong => _latAndLong;
   String? get professionalsName => _professionalsName;
   String get uid => _uid;
   List<String>? get nameArray => _nameArray;


  // Convert the model to JSON format
  Map<String, dynamic> toJson() {
    return {
      "service": service,
      "details": details,
      "years": years,
      "months": months,
      "images": images,
      "experienceStartDate": experienceStartDate,
      "address": address,
      "latAndLong": latAndLong,
      "professionalsName": professionalsName,
      "uid": uid,
      "nameArray": nameArray
    };
  }

  factory PortfolioModel.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('service')) {
      throw ArgumentError('empty-service');
    }
    if (!json.containsKey('details')) {
      throw ArgumentError('empty-details');
    }
    if (!json.containsKey('years')) {
      throw ArgumentError('empty-years');
    }
    if(!json.containsKey('uid')){
      throw ArgumentError('empty-uid');
    }


    final experienceStartDateTimestamp = json['experienceStartDate'];
    final experienceStartDate = experienceStartDateTimestamp is Timestamp
      ? experienceStartDateTimestamp.toDate()
      : null;

    return PortfolioModel(
      service: json['service'] as String,
      details: json['details'] as String,
      years: json['years'] as int,
      months: json['months'] as int,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => Map<String, String>.from(e as Map))
              .toList() ??
          [],
      experienceStartDate: experienceStartDate,
      address: json['address'] as String?,
      latAndLong: json['latAndLong'] != null
          ? Map<String, double?>.from(json['latAndLong'] as Map)
          : null,
      professionalsName: json['professionalsName'] as String?,
      uid: json['uid'] as String,
      nameArray: (json['nameArray'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    );
  }

 Map<String, int> calculateTotalExperience() {
    int totalYears = _years;
    int totalMonths = _months;

    
    if (_experienceStartDate != null) {
      final now = DateTime.now();
      final difference = now.difference(_experienceStartDate);
      
      // Convert difference to years and months
      int additionalMonths = (difference.inDays / 30.44).floor(); // Average days per month
      int additionalYears = additionalMonths ~/ 12;
      int remainingMonths = additionalMonths % 12;
      
      // Add the additional time to prior experience
      totalMonths += remainingMonths;
      totalYears += additionalYears;
      
     
    }

     // Handle month overflow
      if (totalMonths >= 12) {
        totalYears += totalMonths ~/ 12;
        totalMonths = totalMonths % 12;
      }

    return {
      'years': totalYears,
      'months': totalMonths,
    };
  }

  // Format total experience as string
  String getFormattedTotalExperience() {
    final experience = calculateTotalExperience();
    final years = experience['years'] ?? 0;
    final months = experience['months'] ?? 0;
    
    if (years == 0 && months == 0) {
      return "Beginner";
    }
    
    final yearText = years == 1 ? "year" : "years";
    final monthText = months == 1 ? "month" : "months";
    
    if (years == 0) {
      return "$months $monthText";
    }
    if (months == 0) {
      return "$years $yearText";
    }
    return "$years $yearText, $months $monthText";
  }
}
