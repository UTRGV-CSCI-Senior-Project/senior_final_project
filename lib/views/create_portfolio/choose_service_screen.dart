import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:senior_final_project/views/create_portfolio/input_experience_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChooseService extends StatefulWidget {
  const ChooseService({super.key});

  @override
  State<ChooseService> createState() => _ChooseServiceState();
}

class _ChooseServiceState extends State<ChooseService> {
  User? user;
  final serviceType = TextEditingController();
  String? selectedService; // Track the selected service

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    print('#################Here is the user id:${user?.uid}');
  }

  List<String> services = [
    'Nail Tech',
    'Tattoo Artist',
    'Landscaper',
    'Car Detailer',
    'Photographer',
    'Barber',
    'Pet Groomer'
  ];

  @override
  Widget build(BuildContext context) {
    final isDisabled = selectedService != null;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            SafeArea(
              child: LinearProgressIndicator(
                value: 0.25,
                backgroundColor: Colors.grey,
                minHeight: 10.0,
                color: const Color.fromARGB(255, 0, 140, 255),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20.0),
            const Text(
              "Let's get your profile ready!",
              style: TextStyle(
                fontSize: 20.0,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'What service do you offer?',
              style: TextStyle(
                fontSize: 15.0,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10.0),
            AbsorbPointer(
              absorbing: isDisabled,
              child: TextField(
                controller: serviceType,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.edit),
                  hintText: 'Enter here',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: const TextStyle(
                  fontSize: 15.0,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            const Row(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 0, 0, 0),
                  child: Text(
                    'Type of services:',
                    style: TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ],
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
                          selectedService = null; // Deselect the service
                          serviceType.clear(); // Clear the TextField
                        } else {
                          selectedService = service; // Select the service
                          serviceType.text = service; // Set the TextField
                        }
                      });
                    },
                    child: serviceTemplate(service, service == selectedService),
                  );
                },
              ),
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        shadowColor: Colors.white,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            OutlinedButton(
              onPressed: selectedService == null
                  ? null
                  : () {
                      Navigator.pop(context);
                    },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.blue,
                fixedSize: const Size(150, 50),
              ),
              child: const Text(
                'Back',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            OutlinedButton(
              onPressed: selectedService == null || serviceType.text.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              InputExperience(serviceText: serviceType.text),
                        ),
                      );
                    },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.blue,
                fixedSize: const Size(150, 50),
              ),
              child: const Text(
                'Next',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget serviceTemplate(String service, bool isSelected) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
      color: isSelected ? Colors.blue[100] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              service,
              style: const TextStyle(
                fontSize: 15.0,
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check,
                color: Colors.green,
              ),
          ],
        ),
      ),
    );
  }
}
