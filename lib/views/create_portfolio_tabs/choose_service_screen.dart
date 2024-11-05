import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/views/auth_onboarding_welcome/state_screens.dart';
import 'package:folio/widgets/service_selection_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class ChooseService extends ConsumerStatefulWidget {
  final Function(String) onServiceSelected;

  const ChooseService({super.key, required this.onServiceSelected});

  @override
  ConsumerState<ChooseService> createState() => _ChooseServiceState();
}

class _ChooseServiceState extends ConsumerState<ChooseService> {
  final serviceType = TextEditingController();
  String? selectedService; // Track the selected service
  late List<String> services = [];
  final searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadServices();
  }

  @override
  void dispose() {
    serviceType.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadServices() async {
    try {
      final firestoreServices = ref.read(firestoreServicesProvider);
      final fetchedServices = await firestoreServices.getServices();
      setState(() {
        services = fetchedServices;
      });
    } catch (e) {
      setState(() {
        services = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    if (services.isEmpty) {
      return const ErrorView(
        bigText: 'Error fetching services!',
        smallText: 'Please check your connection, or try again later.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Let's get your profile ready!",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        Text(
          'What service do you offer?',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w300),
        ),
        Container(
          margin: const EdgeInsets.only(top: 14),
          decoration: BoxDecoration(
            color: Colors.grey[500]!.withOpacity(0.2),
            borderRadius: BorderRadius.circular(25),
          ),
          child: TextField(
            cursorColor: Theme.of(context).textTheme.displayLarge?.color,
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search Folio',
              enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(50)),
                  borderSide: BorderSide(width: 2, color: Colors.grey[400]!)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(50)),
                  borderSide: BorderSide(width: 3, color: Colors.grey[400]!)),
              hintStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.displayLarge?.color),
              prefixIcon: Icon(Icons.search,
                  color: Theme.of(context).textTheme.displayLarge?.color),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
        const SizedBox(height: 30.0),
        Expanded(
            child: ServiceSelectionWidget(
          services: services,
          initialSelectedServices: const {},
          onServicesSelected: (service) {
            // Find the selected service (there should only be one)
            setState(() {
              if (selectedService == service) {
                selectedService = null; // Deselect the service
              } else {
                selectedService = service; // Select the service
              }
              widget.onServiceSelected(selectedService ?? '');
            });
          },
          isLoading: _isLoading,
          singleSelectionMode: true,
        )),
      ],
    );
  }
}
