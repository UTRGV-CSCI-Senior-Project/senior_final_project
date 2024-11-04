import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/views/auth_onboarding_welcome/state_screens.dart';
import 'package:google_fonts/google_fonts.dart';

class ServiceSelectionWidget extends ConsumerStatefulWidget {
  final Map<String, bool> initialSelectedServices;
  final bool isLoading;
  final List<String> services;
  final Function onServicesSelected;

  const ServiceSelectionWidget({
    super.key,
    required this.services,
    required this.initialSelectedServices,
    required this.onServicesSelected,
    required this.isLoading,
  });

  @override
  ConsumerState<ServiceSelectionWidget> createState() =>
      _ServiceSelectionWidgetState();
}

class _ServiceSelectionWidgetState
    extends ConsumerState<ServiceSelectionWidget> {
  late Map<String, bool> selectedServices;

  @override
  void initState() {
    super.initState();
    selectedServices = Map.from(widget.initialSelectedServices);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const LoadingView();
    }

    if (widget.services.isEmpty) {
      return const ErrorView(
        bigText: 'Error fetching services!',
        smallText: 'Please check your connection, or try again later.',
      );
    }

    return ListView.builder(
      itemCount: widget.services.length,
      itemBuilder: (context, index) {
final service = widget.services[index];
        final isSelected = selectedServices[service] ?? false;
          return GestureDetector(
            key: Key('$service-button'),
            onTap: () {
              setState(() {
                selectedServices[service] = !isSelected;
                widget.onServicesSelected(selectedServices);
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color.fromRGBO(229, 255, 200, 0.4)
                    : Colors
                        .transparent, 
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  width: 2,
                  color: isSelected
                      ? const Color.fromRGBO(9, 195, 54, 1)
                      : Colors.grey,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Text(
                      service,
                      style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    isSelected
                        ? const Icon(
                            Icons.check,
                            color: Color.fromRGBO(9, 195, 54, 1),
                            size: 25,
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
          );
      }
        );
  }
}
