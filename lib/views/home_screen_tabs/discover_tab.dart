import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/service_locator.dart';

class DiscoverTab extends ConsumerStatefulWidget {
  const DiscoverTab({super.key});

  @override
  // ignore: library_private_types_in_public_api
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

    final geminiServices = ref.watch(geminiServicesProvider);

    try {
      List<String> services = await geminiServices.aiSearch(_promptUser);
      if(services.isNotEmpty){
      }else{
      }
      setState(() {
        _filteredServices = services;
        _isLoading = false;
      });
    } catch (e) {
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
                  ..._filteredServices.map((service) => Text(service)),
                ],
              ),
            if (!_isLoading &&
                _filteredServices.isEmpty &&
                _promptUser.isNotEmpty)
              const Center(child: Text('No relevant services found')),
            // Expanded(
            //   child: portfolios.when(
            //     data: (ports) {
            //       return ListView.separated(
            //         itemCount: ports.length,
            //         separatorBuilder: (context, index) => const Divider(
            //           color: Colors.grey,
            //           height: 1,
            //           thickness: 0.5,
            //         ),
            //         itemBuilder: (context, index) {
            //           final portfolio = ports[index];
            //           final String firstImageUrl = portfolio['portfolio'].downloadUrls.isNotEmpty
            //             ? portfolio['portfolio'].downloadUrls[0]
            //             : '';

            //           return Padding(
            //             padding: const EdgeInsets.symmetric(vertical: 12.0),
            //             child: InkWell(
            //               onTap: () {
            //                 // : Implement view portfolio action
            //               },
            //               child: Row(
            //                 crossAxisAlignment: CrossAxisAlignment.center,
            //                 children: [
            //                   // Image
            //                   ClipRRect(
            //                     borderRadius: BorderRadius.circular(8),
            //                     child: firstImageUrl.isNotEmpty
            //                       ? Image.network(
            //                           firstImageUrl,
            //                           width: 80,
            //                           height: 80,
            //                           fit: BoxFit.cover,
            //                         )
            //                       : Container(
            //                           width: 80,
            //                           height: 80,
            //                           color: Colors.grey[300],
            //                           child: const Icon(Icons.image, size: 40, color: Colors.grey),
            //                         ),
            //                   ),
            //                   const SizedBox(width: 16),
            //                   // Name and Service
            //                   Expanded(
            //                     child: Column(
            //                       mainAxisAlignment: MainAxisAlignment.center,
            //                       crossAxisAlignment: CrossAxisAlignment.start,
            //                       children: [
            //                         Text(
            //                           portfolio['user']?.fullName ?? portfolio['user'].username,
            //                           style: const TextStyle(
            //                             fontWeight: FontWeight.bold,
            //                             fontSize: 16,
            //                           ),
            //                         ),
            //                         Text(
            //                           portfolio['portfolio']?.service,
            //                           style: TextStyle(
            //                             color: Colors.grey[600],
            //                             fontSize: 14,
            //                           ),
            //                         ),
            //                       ],
            //                     ),
            //                   ),
            //                   IconButton(onPressed: (){}, icon: Icon(Icons.arrow_forward_ios),)
            //                 ],
            //               ),
            //             ),
            //           );
            //         },
            //       );
            //     },
            //     error: (_, __) => const Center(child: Text('Error loading data')),
            //     loading: () => const Center(child: CircularProgressIndicator()),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
