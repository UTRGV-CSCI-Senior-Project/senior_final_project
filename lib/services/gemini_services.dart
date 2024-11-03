import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/service_locator.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:folio/services/firestore_services.dart';

class GeminiServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late GenerativeModel _model;

  @override
  Future<String?> fetchApiKey() async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('api').doc('gemini').get();
      if (doc.exists) {
        return doc['key'] as String;
      } else {
        return "Error";
      }
    } catch (e) {
      return "Error";
    }
  }

  Future<List<String>> useGemini(WidgetRef ref, String promptUser) async {
    String? apiKey = await fetchApiKey();
    List<String> allServices = [];

    try {
      final firestoreServices = ref.read(firestoreServicesProvider);
      final fetchedServices = await firestoreServices.getServices();
      allServices = fetchedServices; // Fetch all services
    } catch (e) {
      allServices = []; // Handle error by assigning an empty list
    }

    final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey ?? '',
    );

    final prompt =
        """You are a professional in searching for recommended careers from the list I am going to give to you. 
      Only give me the parts of the list that are relevant to the search. 
      ##List: ${allServices.join(', ')}. 
      ##Search: $promptUser
      """;

    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);

    List<String> filteredServices =
        response.text!.split(',').map((service) => service.trim()).toList();

    return filteredServices;
  }
}
