import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(title: const Text('Account'),),
      body: const SafeArea(child:  Padding(padding: EdgeInsets.all(20), child: Column(
      children: [
        
      ],
    ),)));
  }
}