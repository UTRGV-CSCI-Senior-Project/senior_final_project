import 'package:flutter/material.dart';

void main() {
  runApp(TypeOfService());
}

class TypeOfService extends StatefulWidget {
  const TypeOfService({super.key});

  @override
  State<TypeOfService> createState() => _TypeOfServiceState();
}

class _TypeOfServiceState extends State<TypeOfService> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Type of Service',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(),
          Text('Username:'),
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
