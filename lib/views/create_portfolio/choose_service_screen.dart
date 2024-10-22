import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/views/create_portfolio/input_experience_screen.dart';
import 'package:folio/widgets/error_widget.dart';
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

  @override
  void initState() {
    super.initState();
    loadServices();
  }

  Future<void> loadServices() async {
    try{
      final firestoreServices = ref.read(firestoreServicesProvider);
      final fetchedServices = await firestoreServices.getServices();
      setState(() {
        services = fetchedServices;
      });
    }catch(e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = selectedService != null;

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
            Expanded(
              child: ListView.builder(
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selectedService == service) {
                          selectedService = null; // Deselect the service
                          serviceType.clear(); // Clear the TextField

                        } else {
                          selectedService = service; // Select the service
                          serviceType.text = service; // Set the TextField
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
          selectedService = isSelected ? null : service; // Toggle selection
          serviceType.text = selectedService ?? ''; // Update TextField
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
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.normal),
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
}
