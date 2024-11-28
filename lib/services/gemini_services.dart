import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/service_locator.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

Future<String?> fetchApiKey() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  try {
    DocumentSnapshot doc =
        await firestore.collection('api').doc('gemini').get();
    if (doc.exists) {
      return doc['key'] as String;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

Future<List<String>> getAllServices(WidgetRef ref) async {
  try {
    final firestoreServices = ref.read(firestoreServicesProvider);
    return await firestoreServices.getServices();
  } catch (e) {
    return [];
  }
}

class GeminiServices {
  final String modelId = 'gemini-1.5-flash-latest';

  Future<String?> _generateContent(String prompt, String apiKey) async {
    final model = GenerativeModel(
      model: modelId,
      apiKey: apiKey,
    );

    final content = [Content.text(prompt)];

    try {
      final response = await model.generateContent(content);
      return response.text;
    } catch (e) {
      return null;
    }
  }

  Future<List<String>> aiSearch(WidgetRef ref, String promptUser) async {
    final apiKey = await fetchApiKey();
    if (apiKey == null) {
      return [];
    }

    List<String> allServices = await getAllServices(ref);

    if (promptUser.isEmpty) {
      return allServices;
    }

    final prompt = """
    You are a professional in searching for careers based on a user's description. 
    Here is a list of services that are available. Based on the user's search, filter out the services that are not relevant.

    Available services: ${allServices.join(', ')}.
    User search: $promptUser

    Please respond only with the relevant services, separated by commas.
    """;

    final aiResponse = await _generateContent(prompt, apiKey);
    if (aiResponse != null && aiResponse.isNotEmpty) {
      return aiResponse.split(',').map((service) => service.trim()).toList();
    } else {
      return [];
    }
  }

  Future<String?> aiEvaluator(WidgetRef ref, String userPrompt) async {
    final apiKey = await fetchApiKey();
    if (apiKey == null) {
      return 'No Internet Connection';
    }

    List<String> allServices = await getAllServices(ref);

    final prompt = """
      You are an expert in evaluating service names for a platform that connects professionals with clients.
      Check the Valid Services List if its the service that is going to be evaluate is in the list it should get false. 
      ### Valid Services List: ${allServices.join(', ')}

      Please evaluate the service name input by the user according to the following criteria:

      ### Can be Allowed:
      1. **Common Professional Services**: 
        Certain well-known and professional service names that are **commonly accepted** should **never** be flagged, 
        even if they contain words that might seem suspicious in isolation. These include typical professions like  "Software Developer", "Landscaper", and other established service titles. These terms are widely recognized and understood to be legitimate professions or services.

      ### Should Not Be Allowed:
      1. **Misspellings**: 
        If the service name contains significant misspellings (e.g., "Mechnic" instead of "Mechanic").

      2. **Illegal Services**: 
        Services offering illegal activities, such as fraud, hacking, or prohibited substances.

        *Example:*
        - "Illegal Drugs Dealer" or "Hacking Service"

      3. **Discriminatory or Hate-Focused Services**: 
        Services that promote discrimination or hatred against any group of people based on race, gender, religion, sexual orientation, etc., should be flagged as false.

        *Example:*
        - "Racist Content Moderator"

      4. **Violence or Harmful Activities**: 
        Services promoting or engaging in physical harm, violence, or illegal activities that endanger people should be flagged as false.

        *Example:*
        - "Hitman Service"

      5. **Adult or Sexual Content**: 
        Services that involve explicit adult content or services of a sexual nature should be flagged as false.

        *Example:*
        - "Adult Entertainment"

      6. **Exploitative or Manipulative Practices**: 
        Services that deceive, exploit, or manipulate customers for unfair gain should be flagged as false.

        *Example:*
        - "Fake Investment Schemes"

      7. **Deceptive or Misleading Services**: 
        Services that falsely represent their offerings or capabilities to deceive clients should be flagged as false.

        *Example:*
        - "Miracle Weight Loss Products"

      8. **Political or Religious Extremism**: 
        Services promoting extreme or radical political or religious ideologies should be flagged as false.

        *Example:*
        - "Extremist Religious Services"
      9. **Already Exist**:
        It is already on the Services List.

      ### Service Name to Evaluate: $userPrompt

      Please respond with **"true"** if the service name meets the above criteria and is a valid service name, or if it violates any of the rules listed above respond only with the criteria.

      ##Example Respond:
      1. true
      2. Political or Religious Extremism
      3. true
      4. Exploitative or Manipulative Practices

        """;

    final String? response = await _generateContent(prompt, apiKey);

    return response;
  }
}
