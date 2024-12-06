import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/models/portfolio_model.dart';
import 'package:folio/models/user_model.dart';
import 'package:folio/views/view_account/view_profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class PortfolioListItem extends ConsumerWidget {
  final PortfolioModel portfolio;
  final UserModel currentUser;
  const PortfolioListItem({super.key, required this.currentUser, required this.portfolio});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPosition = ref.watch(currentPositionProvider);
    final locationService = ref.watch(locationServiceProvider);
    // Calculate distance if position is available
    int? distance;
    if (currentPosition != null &&
        portfolio.latAndLong?['longitude'] != null &&
        portfolio.latAndLong?['latitude'] != null) {
      distance = locationService.distanceInMiles(
          currentPosition,
          portfolio.latAndLong!['latitude']!,
          portfolio.latAndLong!['longitude']!);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ViewProfileScreen(
                      uid: portfolio.uid,
                      portfolioModel: portfolio,
                      currentUser: currentUser,
                    )));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            // Image on the left
            SizedBox(
              width: 110,
              height: 110,
              child: portfolio.images.isNotEmpty
                  ? PageView.builder(
                      itemCount: portfolio.images.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(12)),
                          child: Image.network(
                            portfolio.images[index]['downloadUrl'] ?? '',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[200],
                      child:
                          const Center(child: Icon(Icons.image_not_supported)),
                    ),
            ),

            // Details on the right
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Expanded(
      child: Text(
        portfolio.professionalsName ?? "Professional's Name",
        style: GoogleFonts.inter(
          fontSize: 16, 
          fontWeight: FontWeight.bold
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    ),
    if (distance != null)
      Text(
        '$distance mi away',
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500
        ),
      )
  ],
),
                    Text(
                      portfolio.service,
                      style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}