import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/services/gemini_services.dart';

class DiscoverTab extends ConsumerStatefulWidget {
  const DiscoverTab({super.key});

  @override
  _DiscoverTabState createState() => _DiscoverTabState();
}

class _DiscoverTabState extends ConsumerState<DiscoverTab> {
  String _promptUser = '';
  List<String> _filteredServices = [];
  bool _isLoading = false;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchServices() async {
    setState(() {
      _isLoading = true;
    });

    final geminiServices = GeminiServices();

    try {
      List<String> services = await geminiServices.useGemini(ref, _promptUser);

      setState(() {
        _filteredServices = services;
        _isLoading = false;
      });
    } catch (e) {
      print("Error occurred: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _promptUser = value;
                  });
                },
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  hintText: 'Search Folio',
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _searchServices,
              child: const Text('Search Services'),
            ),
            const SizedBox(height: 20),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (!_isLoading && _filteredServices.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Filtered Services:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ..._filteredServices.map((service) => Text(service)).toList(),
                ],
              ),
            if (!_isLoading &&
                _filteredServices.isEmpty &&
                _promptUser.isNotEmpty)
              const Center(child: Text('No relevant services found')),
          ],
        ),
      ),
    );
  }
}
