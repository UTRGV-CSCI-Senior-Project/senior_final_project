class PortfolioModel {
  final String _service;
  final String _details;
  final String _years;
  final String _months;
  final List<String> _downloadUrls;

  PortfolioModel({
    required String service,
    required String details,
    required String years,
    required String months,
    List<String> downloadUrls = const [],
  })  : _service = service,
        _details = details,
        _years = years,
        _months = months,
        _downloadUrls = downloadUrls;

  String get service => _service;
  String get details => _details;
  String get years => _years;
  String get months => _months;
  List<String> get downloadUrls => _downloadUrls;

  toJson() {
    return {
      "service": service,
      "details": details,
      "years": years,
      "months": months,
      "downloadUrls": downloadUrls,
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
        years: json['years'] as String,
        months: json['months'] as String,
        downloadUrls: (json['downloadUrls'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
);
  }
}
