import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/widgets/input_field_widget.dart';

class DiscoverTab extends ConsumerWidget {
  
  const DiscoverTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final portfolios = ref.watch(portfoliosProvider);
    final searchController = TextEditingController();

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
                cursorColor: Colors.black,
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search Folio',
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            SizedBox(height: 16),
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
            //                 // TODO: Implement view portfolio action
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