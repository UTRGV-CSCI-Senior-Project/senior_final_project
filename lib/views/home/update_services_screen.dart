import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/app_exception.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/views/auth_onboarding_welcome/state_screens.dart';
import 'package:folio/widgets/error_widget.dart';
import 'package:folio/widgets/service_selection_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class UpdateServicesScreen extends ConsumerStatefulWidget {
  final List<String> selectedServices;
  const UpdateServicesScreen({super.key, required this.selectedServices});

  @override
  ConsumerState<UpdateServicesScreen> createState() =>
      _UpdateServicesScreenState();
}

class _UpdateServicesScreenState extends ConsumerState<UpdateServicesScreen> {
  bool isLoading = true;
  bool isSaving = false;
  List<String> services = [];
  List<String> filteredServices = [];
  Map<String, bool> selectedServices = {};
  final searchController = TextEditingController();
  String errorMessage = "";
  Timer? debounce;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadCurrentInterests();
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (debounce?.isActive ?? false) {
      debounce?.cancel();
    }
    debounce = Timer(const Duration(seconds: 1), () async {
      final query = searchController.text.trim();
      if (query.isNotEmpty) {
        filterServices(query);
      } else {
        setState(() {
          filteredServices = services;
        });
      }
    });
  }

  Future<void> loadCurrentInterests() async {
    try {
      final firestoreServices = ref.read(firestoreServicesProvider);

      final fetchedServices = await firestoreServices.getServices();
      setState(() {
        services = fetchedServices;
        selectedServices = {
          for (var service in services)
            service: widget.selectedServices.contains(service)
        };

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load services. Please try again.";
        isLoading = false;
      });
    }
  }

  void filterServices(String query) async {
    final filtered = services
        .where((service) => service.toLowerCase().contains(query.toLowerCase()))
        .toList();
    if (filtered.isNotEmpty) {
      setState(() {
        filteredServices = filtered;
      });
    } else {
      final aiSearchResults =
          await ref.read(geminiServicesProvider).aiSearch(query);
          if(aiSearchResults.isNotEmpty){
      setState(() {
        filteredServices = aiSearchResults;
      });
          }
    }
  }

  Future<void> updateServices() async {
    if (!selectedServices.values.any((selected) => selected)) {
      setState(() {
        errorMessage = "Please select at least one.";
      });
      return;
    }
    setState(() {
      isSaving = true;
      errorMessage = "";
    });
    try {
      final selectedServicesList = selectedServices.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      await ref
          .read(userRepositoryProvider)
          .updateProfile(fields: {'preferredServices': selectedServicesList});

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        errorMessage = e is AppException
            ? e.message
            : "Failed to update interests. Please try again.";
      });
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LoadingView();
    }

    if (services.isEmpty) {
      return const ErrorView(
        bigText: 'Error fetching services!',
        smallText: 'Please check your connection, or try again later.',
      );
    }

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.close,
                size: 30,
              )),
        ),
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Update Your Interests!",
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.w500),
              ),
              Text(
                'Select the services you\'re interested in',
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w300),
              ),
              Container(
                margin: const EdgeInsets.only(top: 14),
                decoration: BoxDecoration(
                  color: Colors.grey[500]!.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: searchController,
                  cursorColor: Theme.of(context).textTheme.displayLarge?.color,
                  decoration: InputDecoration(
                    hintText: 'Search for a service',
                    enabledBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(50)),
                        borderSide:
                            BorderSide(width: 2, color: Colors.grey[400]!)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(50)),
                        borderSide:
                            BorderSide(width: 3, color: Colors.grey[400]!)),
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
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: ServiceSelectionWidget(
                    services:
                        filteredServices.isEmpty ? services : filteredServices,
                    initialSelectedServices: selectedServices,
                    onServicesSelected: (newService) {
                      setState(() {
                        selectedServices.addAll(newService);
                      });
                    },
                    isLoading: isLoading),
              ),
              const Padding(padding: EdgeInsets.all(5)),
              errorMessage.isNotEmpty
                  ? ErrorBox(
                      errorMessage: errorMessage,
                      onDismiss: () {
                        setState(() {
                          errorMessage = "";
                        });
                      })
                  : Container(),
              TextButton(
                  key: const Key('update-services-button'),
                  onPressed: updateServices,
                  style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      backgroundColor: const Color.fromARGB(255, 0, 111, 253),
                      padding: const EdgeInsets.symmetric(vertical: 12)),
                  child: isSaving
                      ? SizedBox(
                          height: 30,
                          width: 30,
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.onPrimary,
                            strokeWidth: 5,
                          ),
                        )
                      : Text('Update!',
                          style: GoogleFonts.poppins(
                              fontSize: 20, fontWeight: FontWeight.bold))),
            ],
          ),
        )));
  }
}
