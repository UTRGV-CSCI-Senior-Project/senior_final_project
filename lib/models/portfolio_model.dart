class PortfolioModel {
  final String _service;
  final String _details;
  final int _years;
  final int _months;
  final List<Map<String, String>> _images;

  PortfolioModel({
    required String service,
    String details = "",
    int years = 0,
    int months = 0,
    List<Map<String, String>> images = const [],
  })  : _service = service,
        _details = details,
        _years = years,
        _months = months,
        _images = images {
    if (service.isEmpty) {
      throw ArgumentError('UID cannot be empty');
    }
  }

  String get service => _service;
  String get details => _details;
  int get years => _years;
  int get months => _months;
  List<Map<String, String>> get images => _images;

  // Convert the model to JSON format
  Map<String, dynamic> toJson() {
    return {
      "service": service,
      "details": details,
      "years": years,
      "months": months,
      "images": images, // No transformation needed since it's a list of maps
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

    return PortfolioModel(
      service: json['service'] as String,
      details: json['details'] as String,
      years: json['years'] as int,
      months: json['months'] as int,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => Map<String, String>.from(e as Map))
              .toList() ??
          [],
    );
  }
}
