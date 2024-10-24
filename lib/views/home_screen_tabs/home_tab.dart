import 'package:flutter/material.dart';
import 'package:riverpod/src/common.dart';

class HomeTab extends StatelessWidget {
  final dynamic userModel;

  const HomeTab({
    super.key,
    required this.userModel,
      });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
                  child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Preferences",
                                style: TextStyle(
                                    fontWeight: FontWeight.w900, fontSize: 14),
                              ),
                              TextButton(
                                key: const Key("Edit_Proffesion_Key"),
                                onPressed: () {},
                                child: const Text(
                                  "Edit",
                                  style: TextStyle(
                                      color: Color.fromRGBO(0, 111, 253, 1)),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 30,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: userModel.preferredServices.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6),
                                      child: ElevatedButton(
                                          key: Key("Proffesion_button_$index "),
                                          style: const ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll<Color>(
                                                    Color.fromRGBO(
                                                        234, 242, 255, 1)),
                                          ),
                                          onPressed: () {},
                                          child: Text(
                                            userModel.preferredServices[index]
                                                .toUpperCase(),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                                color: Color.fromRGBO(
                                                    0, 111, 253, 1)),
                                          )));
                                }),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Just Uploaded",
                                style: TextStyle(
                                    fontWeight: FontWeight.w900, fontSize: 14),
                              ),
                              TextButton(
                                key: const Key("Edit_Proffesion_Key"),
                                onPressed: () {},
                                child: const Text(
                                  "See More",
                                  style: TextStyle(
                                      color: Color.fromRGBO(0, 111, 253, 1)),
                                ),
                              ),
                              
                            ],
                          ),
//                           Column(children: [
// SizedBox(height: 10,),
//                           portfolioData.when(data: (ports) {

//                   return SizedBox(height: 245,  child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     shrinkWrap: true, 
//                     itemCount: ports.length,
//                     itemBuilder: (context, index) {
//                       final portfolio = ports[index];
//                           final String firstImageUrl = portfolio['portfolio'].downloadUrls.isNotEmpty ? portfolio['portfolio'].downloadUrls[0] : '';

//                       return  Padding(padding: const EdgeInsets.only(right: 8), child: Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: SizedBox(
//         width: 250,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ClipRRect(
//               borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
//               child: firstImageUrl.isNotEmpty 
//                   ? Image.network(
//                       firstImageUrl,
//                       height: 165,
//                       width: double.infinity,
//                       fit: BoxFit.cover,
//                     )
//                   : Container(
//                       height: 165,
//                       width: double.infinity,
//                       color: const Color.fromRGBO(234, 242, 255, 1),
//                       child: const Icon(Icons.image, size: 60, color:  Color.fromRGBO(180, 219, 255, 1)),
//                     ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     portfolio['user'].fullName ?? portfolio['user'].username,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     portfolio['portfolio'].service,
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey[600],
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 8),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),);
                      
//                     },
//                   ));
                  
                  
//                 }, error: (s, e) => const Center(child: Text('data'),),
//                 loading: () => const Center(child: Text('daa'),))
//                           ],),
                          
                        ],
                      ),
                      
                    ],
                  ),
                ),
              ));
  }
}