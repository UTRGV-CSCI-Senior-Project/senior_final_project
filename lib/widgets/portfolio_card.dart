import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/models/portfolio_model.dart';
import 'package:folio/models/user_model.dart';
import 'package:folio/views/view_account/view_profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class PortfolioCard extends ConsumerWidget {
  final PortfolioModel portfolio;
  final UserModel currentUser;
  const PortfolioCard({super.key, required this.currentUser, required this.portfolio});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPosition = ref.watch(currentPositionProvider);
    final locationService =  ref.watch(locationServiceProvider);
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

    return Container(
      width: 255,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 110,
            child: portfolio.images.isNotEmpty
                ? PageView.builder(
                    itemCount: portfolio.images.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12)),
                        child: Image.network(
                          portfolio.images[index]['downloadUrl'] ?? '',
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      );
                    },
                  )
                : Container(
                    color: Colors.grey[200],
                    child: const Center(child: Icon(Icons.image_not_supported)),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize
                  .min, // This ensures the column takes minimum space

              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                          portfolio.professionalsName ?? "Professional's Name",
                          style: GoogleFonts.inter(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1),
                    ),
                    const SizedBox(width: 8), // Add spacing between columns
                    Flexible(
                      child: distance != null
                          ? Text(
                              '$distance mi away',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: GoogleFonts.inter(
                                  fontSize: 13, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.end,
                            )
                          : Text(
                              portfolio.location?['city'] ?? '',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: GoogleFonts.inter(
                                  fontSize: 13, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.end,
                            ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        portfolio.service,
                        style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(width: 8), // Add spacing between columns
                    Flexible(
                      child: Text(portfolio.getFormattedTotalExperience(),
                          style: GoogleFonts.inter(
                              fontSize: 13, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                key: const Key('view-portfolio-button'),
                style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(50)))),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ViewProfileScreen(
                                uid: portfolio.uid,
                                portfolioModel: portfolio,
                                currentUser: currentUser
                              )));
                },
                child: Text(
                  'View',
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.displayLarge!.color),
                ),
              ),
            ),
          ),
          // Add more portfolio details as needed
        ],
      ),
    );
  }
}