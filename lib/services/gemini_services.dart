import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/app_exception.dart';
import 'package:folio/core/service_locator.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiServices {
  final String modelId = 'gemini-1.5-flash-latest';
  final String? apiKey = dotenv.env['GEMINI_API_KEY'];
  final Ref _ref;

  GeminiServices(this._ref);

  String? fetchApiKey() {
    try {
      return dotenv.env['GEMINI_API_KEY'];
    } catch (e) {
      throw AppException('no-gemini-key');
    }
  }

  // Future<List<String>> getAllServices() async {
  //   try {
  //     return await _firestoreServices.getServices();
  //   } catch (e) {
  //     throw AppException('get-services-error');
  //   }
  // }

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

final servicesAsyncValue = await _ref.read(servicesStreamProvider.future);
    
    List<String> allServices = servicesAsyncValue;
    
    if (allServices.isEmpty) {
      return []; // Return empty list if no services available
    }
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


      final servicesAsyncValue = await _ref.read(servicesStreamProvider.future);
    
    List<String> allServices = servicesAsyncValue;
    
    if (allServices.isEmpty) {
      return []; // Return empty list if no services available
    }

      if(userPrompt.isEmpty){
        return allServices;
      }
      
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

  Future<List<String>> aiDiscover(String promptUser) async {
    try {
      final apiKey = fetchApiKey();
      if (apiKey == null) {
        return [];
      }

final servicesAsyncValue = await _ref.read(servicesStreamProvider.future);
    
    List<String> allServices = servicesAsyncValue;
    
    if (allServices.isEmpty) {
      return []; // Return empty list if no services available
    }      if (promptUser.isEmpty) {
        return allServices;
      }

      final prompt = """
    You are an expert at understanding user's intent when searching a professional discovery app.

    Available services: ${allServices.join(', ')}.
    User's search: $promptUser

    Your task:
    1. Determine if the input is:
       a) A person's name (First name, Last name, or Full name)
       b) A service search
    2. For service searches:
       - Match relevant services from the available list
       - Include synonyms and closely related terms
    3. Return the appropriate output based on the input type

    Rules:
    1. For person names: 
       - Return the name exactly as entered if it appears to be a name
       - Capitalize correctly
       - Accept first names, last names, or full names
    2. For service searches:
       - Only return services from the available list
       - Ignore vague, ambiguous, or unrelated inputs
       - Respond with "NO MATCHES" if no valid match exists
    3. Return a concise response
      - If returning a name, just return the name
      - If returning a service or services, return them in a comma separated list

    Examples:
    - Input: "John" → Output: John
    - Input: "Doe" → Output: Doe
    - Input: "John Doe" → Output: John Doe
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

          if (responseList.length == 1 &&
              !allServices.contains(responseList[0])) {
            // Assume it's a name and return directly
            return responseList;
          }

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
}
