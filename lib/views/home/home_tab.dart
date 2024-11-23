import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/models/portfolio_model.dart';
import 'package:folio/models/user_model.dart';
import 'package:folio/views/home/update_services_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeTab extends ConsumerStatefulWidget {
  final UserModel? userModel;

  const HomeTab({
    super.key,
    required this.userModel,
  });

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  @override
  void initState() {
    super.initState();
  }

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
                    Text(
                      "Preferences",
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                    GestureDetector(
                      key: const Key("edit-services-button"),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UpdateServicesScreen(
                                      selectedServices:
                                          widget.userModel!.preferredServices,
                                    )));
                      },
                      child: Text(
                        "Edit",
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.tertiary),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount:
                          widget.userModel?.preferredServices.length ?? 0,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            onPressed: () {},
                            label: Text(
                              widget.userModel!.preferredServices[index]
                                  .toUpperCase(),
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.tertiary),
                            ),
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.5),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            side: BorderSide.none,
                            shape: const RoundedRectangleBorder(
                                side: BorderSide.none,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50))),
                          ),
                        );
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
                    Text(
                      "Near You",
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                    GestureDetector(
                      key: const Key("Edit_Proffesion_Key"),
                      onTap: () {},
                      child: Text(
                        "See More",
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.tertiary),
                      ),
                    ),
                  ],
                ),
                ref.watch(nearbyPortfoliosProvider).when(
                    data: (portfolios) {
                      if (portfolios.isEmpty) {
                        return const Center(
                            child: Text("No portfolios found nearby."));
                      }
                      return SizedBox(
                        height: 250,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: portfolios.length,
                          itemBuilder: (context, index) {
                            final portfolio = portfolios[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: _buildPortfolio(portfolio),
                            );
                          },
                        ),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                        child: Text("Failed to load portfolios: $error")))
              ],
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildPortfolio(PortfolioModel portfolio) {
    return Container(
      height: 250,
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
                Text(
                  portfolio.professionalsName ?? "Professional's Name",
                  style: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Text(portfolio.service,
                        style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w500)),
                    const Spacer(),
                    Text(
                      portfolio.getFormattedTotalExperience(),
                      style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w500),
                    )
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
                style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                        borderRadius: const BorderRadius.all(Radius.circular(50)))),
                onPressed: () {},
                child: Text(
                  'View Portfolio',
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
