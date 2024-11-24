// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/services/gemini_services.dart';
import 'package:folio/views/state_screens.dart'; // For error handling
import 'package:google_fonts/google_fonts.dart';

class ChooseService extends ConsumerStatefulWidget {
  final Function(String) onServiceSelected;

  const ChooseService({super.key, required this.onServiceSelected});

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

  @override
  void initState() {
    super.initState();
    loadServices();
    searchController.addListener(_filterServices);
  }

  @override
  void dispose() {
    serviceType.dispose();
    searchController.removeListener(_filterServices);
    searchController.dispose();
    super.dispose();
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

  void _filterServices() {
    final query = searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        services = allServices;
      } else {
        services = allServices
            .where((service) => service.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.blue,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 20.0),
        Text(
          "Let's get your profile ready!",
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8.0),
        Text(
          'What service do you offer?',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w300),
        ),
        const SizedBox(height: 30.0),
        Container(
          decoration: BoxDecoration(
            color: const Color.fromRGBO(248, 249, 254, 1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: TextField(
            cursorColor: Colors.black,
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Services',
              prefixIcon: Icon(Icons.search, color: Colors.black),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
        const SizedBox(height: 30.0),
        if (services.isEmpty && searchController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ErrorView(
                  bigText: 'No services found!',
                  smallText: 'Try a different search term.',
                ),
                const SizedBox(height: 20.0),
                Text(
                  'It looks like you may have entered a new service name.',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w300),
                ),
                const SizedBox(height: 8.0),
                ElevatedButton(
                  onPressed: () async {
                    final serviceName =
                        capitalizeEachWord(searchController.text.trim());

                    try {
                      final isValidService =
                          await GeminiServices().aiEvaluator(ref, serviceName);
                      if (isValidService) {
                        try {
                          final firestoreServices =
                              ref.read(firestoreServicesProvider);
                          await firestoreServices.addService(serviceName);
                          setState(() {
                            services.add(serviceName);
                            allServices.add(serviceName);
                            searchController.clear();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Service added successfully!')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error adding service: $e')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Invalid service name! Please check the name and try again.')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Error evaluating service name: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                  ),
                  child: const Text('Add this service'),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (selectedService == service) {
                      selectedService = null;
                      serviceType.clear();
                    } else {
                      selectedService = service;
                      serviceType.text = service;
                    }
                    widget.onServiceSelected(selectedService!);
                  });
                },
                child: serviceTemplate(service, service == selectedService),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget serviceTemplate(String service, bool isSelected) {
    return GestureDetector(
      key: Key('$service-button'),
      onTap: () {
        setState(() {
          selectedService = isSelected ? null : service;
          serviceType.text = selectedService ?? '';
          widget.onServiceSelected(selectedService ?? '');
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromRGBO(229, 255, 200, 100)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color.fromRGBO(9, 195, 54, 100)
                : Colors.grey,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                service,
                style: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.normal),
              ),
              const Spacer(),
              if (isSelected)
                const Icon(
                  Icons.check,
                  color: Color.fromRGBO(9, 195, 19, 100),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
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
