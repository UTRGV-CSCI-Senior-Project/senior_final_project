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
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:folio/core/app_exception.dart';
import 'package:folio/services/firestore_services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiServices {
  final String modelId = 'gemini-1.5-flash-latest';
  final String? apiKey = dotenv.env['GEMINI_API_KEY'];
  final FirestoreServices _firestoreServices;

  GeminiServices(this._firestoreServices);

  String? fetchApiKey() {
    try {
      return dotenv.env['GEMINI_API_KEY'];
    } catch (e) {
      throw AppException('no-gemini-key');
    }
  }

  Future<List<String>> getAllServices() async {
    try {
      return await _firestoreServices.getServices();
    } catch (e) {
      throw AppException('get-services-error');
    }
  }

  Future<String?> _generateContent(String prompt, String apiKey) async {
    final model = GenerativeModel(
      model: modelId,
      apiKey: apiKey,
    );

    try {
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      return response.text;
    } catch (e) {
      throw AppException('generate-content-error');
    }
  }

  Future<List<String>> aiSearch(String promptUser) async {
    try {
      final apiKey = fetchApiKey();
      if (apiKey == null) {
        return [];
      }

      List<String> allServices = await getAllServices();

      if (promptUser.isEmpty) {
        return allServices;
      }

      

      final prompt = """
    You are an expert at matching user searches to professional services.

    Available services: ${allServices.join(', ')}.
    User's search: $promptUser

    Your task:
    1. Understand the user's intent.
    2. Match relevant services from the available list.
    3. Include synonyms and closely related terms.
    4. Return a comma-separated list of matched services.

    Rules:
    1. Only return services from the available list.
    2. Ignore vague, ambiguous, or unrelated inputs. Respond with "NO MATCHES" if no valid match exists.

    Examples:
    - Input: "someone to cut my hair" → Output: Hair Stylist, Barber
    - Input: "fix my computer" → Output: IT Technician, Computer Repair Specialist
    - Input: "random text" → Output: NO MATCHES
    """;

      final aiResponse = await _generateContent(prompt, apiKey);
      if (aiResponse != null && aiResponse.isNotEmpty) {
        if (aiResponse.trim() == "NO MATCHES") {
          return [];
        }
        try {
          final responseList = aiResponse
              .split(',')
              .map((service) => service.trim())
              .where((service) => service.isNotEmpty)
              .toList();

          final validServices = responseList
              .where((service) => allServices.contains(service))
              .toList();
          return validServices;
        } catch (e) {
          return [];
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> aiEvaluator(String userPrompt) async {
    try {
      final apiKey = fetchApiKey();
      if (apiKey == null) {
        return [];
      }

      List<String> allServices = await getAllServices();

      final prompt = """
      You are an expert evaluator for a professional service platform.
      Evaluate the user-provided service name based on the following rules:

      ### Example Services List: ${allServices.join(', ')}


      ### Criteria:
      1. **Profession Transformation**:
        Always convert fields or general terms to specific professional roles.

        Examples:
        - Input: "accounting" → Output: Accountant
        - Input: "translating" → Output: Translator
        - Input: "law" → Output: Lawyer
        - Input: "programming" → Output: Software Developer

      2. **Misspellings**:
        If the service name contains significant misspellings, return the corrected version.

        Example:
        - Input: "Mechnic"
        - Response: Mechanic

      3. **Illegal or Inappropriate Services**:
        If the service name includes illegal, inappropriate, or explicit content, return nothing.

        Example:
        - Input: "Hitman Services"
        - Response: null

      4. **Vague Services**:
        If the service name is too vague (e.g., "I cut hair"), provide suggestions for more precise terms.
        Use suggestions based on common professional roles in the Valid Services List.

        Example:
        - Input: "I cut hair"
        - Response: Hair Stylist, "Barber

      ### Service Name to Evaluate: "$userPrompt"

      Provide your response in one of the following formats:
      1. Suggestions for misspellings or vague services in a list format: Suggestion1, Suggestion2
      2. Return null if the service is inappropriate or illegal.

    """;

      final response = await _generateContent(prompt, apiKey);
      if (response != null) {
        final trimmedResponse = response.trim();
        if (trimmedResponse.toLowerCase() == 'null' ||
            trimmedResponse.isEmpty) {
          return [];
        }
        final cleanedResponse =
            trimmedResponse.replaceAll(RegExp(r'^.*:\s*'), '');
        try {
          return cleanedResponse
              .split(',')
              .map((service) => service.trim())
              .where((service) => service.isNotEmpty)
              .toList();
        } catch (e) {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
