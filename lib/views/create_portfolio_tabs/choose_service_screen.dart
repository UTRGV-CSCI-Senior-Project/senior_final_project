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

  Future<void> _evaluateAndAddService() async {
    final serviceName = searchController.text;

    if (serviceName.isNotEmpty) {
      GeminiServices geminiServices = GeminiServices();
      String? evaluationResult =
          await geminiServices.aiEvaluator(ref, serviceName);

      if (evaluationResult?.trim() == 'true') {
        setState(() {
          final firestoreServices = ref.read(firestoreServicesProvider);
          allServices.add(serviceName);
          services = List.from(allServices);
          firestoreServices.addCareer(serviceName);
        });
        widget.onServiceSelected(serviceName);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const SuccessDialog();
          },
        );
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return InvalidServiceDialog(evaluationResult: evaluationResult);
            });
      }
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

    if (services.isEmpty && !_isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title ?? "Let's get your profile ready!",
            style:
                GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          Text(
            widget.subTitle ?? 'What service do you offer?',
            style:
                GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w300),
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
          const SizedBox(height: 10.0),
          Text(
            'No services found matching your search.',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
          ),
          ElevatedButton(
              onPressed: _evaluateAndAddService,
              child: const Text('Add to Career List'))
        ],
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
          widget.subTitle ?? 'What service do you offer?',
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
        if (services.isEmpty)
          const ErrorView(
            bigText: 'Failed to fetch',
            smallText: 'Service list is empty',
          ),
        Expanded(
            child: ServiceSelectionWidget(
          services: services,
          initialSelectedServices: widget.initialService.isNotEmpty
              ? {widget.initialService: true}
              : {},
          onServicesSelected: (service) {
            setState(() {
              if (selectedService == service) {
                selectedService = null;
              } else {
                selectedService = service;
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
