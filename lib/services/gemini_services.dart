import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/service_locator.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> fetchApiKey() async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('api').doc('gemini').get();
      if (doc.exists) {
        return doc['key'] as String;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching API key: $e');
      return null;
    }
  }

  Future<List<String>> useGemini(WidgetRef ref, String promptUser) async {
    String? apiKey = await fetchApiKey();
    if (apiKey == null) {
      print('API key is null');
      return [];
    }

    List<String> allServices = [];

    try {
      final firestoreServices = ref.read(firestoreServicesProvider);
      allServices = await firestoreServices.getServices();
    } catch (e) {
      print('Error fetching services: $e');
      return [];
    }

    if (promptUser.isEmpty) {
      return allServices;
    }

    final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
    );

    final prompt = """
    You are a professional in searching for careers based on a user's description. 
    Here is a list of services that are available. Based on the user's search, filter out the services that are not relevant.

    Available services: ${allServices.join(', ')}.
    User search: $promptUser

    Please respond only with the relevant services, separated by commas. 
    """;

    final content = [Content.text(prompt)];

    try {
      final response = await model.generateContent(content);

      print('AI Response: ${response.text}');

      if (response.text != null && response.text!.isNotEmpty) {
        List<String> filteredServices =
            response.text!.split(',').map((service) => service.trim()).toList();
        return filteredServices;
      } else {
        print('No relevant services found from AI response.');
        return [];
      }
    } catch (e) {
      print('Error during AI processing: $e');
      return [];
    }
  }
}
