import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/services/gemini_services.dart';
import 'package:folio/views/auth_onboarding_welcome/state_screens.dart';
import 'package:folio/widgets/adding_denied_dialog.dart';
import 'package:folio/widgets/service_selection_widget.dart';
import 'package:folio/widgets/successfully_added_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test/test.dart';

class ChooseService extends ConsumerStatefulWidget {
  final String initialService;
  final Function(String) onServiceSelected;
  final String? title;
  final String? subTitle;

  const ChooseService(
      {super.key,
      required this.onServiceSelected,
      this.initialService = "",
      this.title,
      this.subTitle});

  @override
  ConsumerState<ChooseService> createState() => _ChooseServiceState();
}

class _ChooseServiceState extends ConsumerState<ChooseService> {
  final serviceType = TextEditingController();
  String? selectedService;
  late List<String> allServices = [];
  late List<String> services = [];
  final searchController = TextEditingController();
  bool _isLoading = true;
  Timer? debounce;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    loadServices();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    serviceType.dispose();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _isSearching = searchController.text.isNotEmpty;
    });

    if (debounce?.isActive ?? false) {
      debounce?.cancel();
    }
    debounce = Timer(const Duration(milliseconds: 1300), () async {
      if (searchController.text.isNotEmpty) {
        _filterServices(searchController.text);
      } else {
        setState(() {
          services = allServices;
        });
      }
    });
  }

  Future<void> loadServices() async {
    try {
      final firestoreServices = ref.read(firestoreServicesProvider);
      final fetchedServices = await firestoreServices.getServices();
      setState(() {
        allServices = fetchedServices;
        services = allServices;
      });
    } catch (e) {
      setState(() {
        allServices = [];
        services = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _filterServices(String query) async {
    if (query.isEmpty) {
      setState(() {
        services = allServices;
        _isSearching = false;
      });
      return;
    }
    setState(() {
      _isSearching = true;
    });
    final filtered = allServices
        .where((service) => service.toLowerCase().contains(query))
        .toList();

    if (filtered.isEmpty) {
      final aiSearchResults =
          await ref.read(geminiServicesProvider).aiSearch(query);
      if (aiSearchResults.isNotEmpty) {
        setState(() {
          services = aiSearchResults;
          _isSearching = false;
        });
      } else {
        final createdService =
            await ref.read(geminiServicesProvider).aiEvaluator(query);
        setState(() {
          if (createdService.isNotEmpty) {
            allServices.addAll(createdService);
            services = createdService;
          }
          _isSearching = false;
        });
      }
    } else {
      setState(() {
        services = filtered;
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (allServices.isEmpty) {
      const ErrorView(
        bigText: 'Error',
        smallText: 'Failed to fetch',
      );
    }
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
          widget.title ?? "Let's get your profile ready!",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        Text(
          widget.subTitle ?? 'What is your profession?',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w300),
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
                suffixIcon: _isSearching
                    ? Transform.scale(
                        scale: 0.6,
                        child: const CircularProgressIndicator(
                          strokeWidth: 6,
                          color: Colors.black,
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => searchController.clear(),
                      )),
          ),
        ),
        const SizedBox(height: 30.0),
        Expanded(
            child: ServiceSelectionWidget(
          services: services,
          initialSelectedServices: widget.initialService.isNotEmpty
              ? {widget.initialService: true}
              : {},
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

  String capitalizeEachWord(String text) {
    return text
        .split(' ')
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : '')
        .join(' ');
  }
}
