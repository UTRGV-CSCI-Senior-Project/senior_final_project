import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/controller/user_location_controller.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/models/user_model.dart';
import 'package:folio/views/home/home_screen.dart';
import 'package:folio/views/home/update_services_screen.dart';
import 'package:folio/widgets/portfolio_card.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeTab extends ConsumerStatefulWidget {
  final UserModel userModel;

  const HomeTab({
    super.key,
    required this.userModel,
  });

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  late LocationService locationService;

  @override
  void initState() {
    super.initState();
    locationService = ref.read(locationServiceProvider);
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
                                          widget.userModel.preferredServices,
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
                      itemCount: widget.userModel.preferredServices.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            onPressed: () {
                              // Update the global search provider with the selected service
                              ref.read(discoverSearchProvider.notifier).state =
                                  widget.userModel.preferredServices[index];

                              // Change the tab to Discover
                              ref.read(selectedIndexProvider.notifier).state =
                                  1;
                            },
                            label: Text(
                              widget.userModel.preferredServices[index]
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
                    // GestureDetector(
                    //   key: const Key("Edit_Proffesion_Key"),
                    //   onTap: () {},
                    //   child: Text(
                    //     "See More",
                    //     style: GoogleFonts.inter(
                    //         fontSize: 14,
                    //         fontWeight: FontWeight.w600,
                    //         color: Theme.of(context).colorScheme.tertiary),
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                ref.watch(nearbyPortfoliosProvider).when(
                    data: (portfolios) {
                      if (portfolios.isEmpty) {
                        return const Center(
                            child: Text("No portfolios found nearby."));
                      }
                      portfolios.sort((a, b) {
                        bool aIsPreferred = widget.userModel.preferredServices
                            .contains(a.service);
                        bool bIsPreferred = widget.userModel.preferredServices
                            .contains(b.service);

                        if (aIsPreferred && !bIsPreferred) return -1;
                        if (!aIsPreferred && bIsPreferred) return 1;
                        return 0;
                      });
                      return SizedBox(
                        height: 275,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: portfolios.length,
                          itemBuilder: (context, index) {
                            final portfolio = portfolios[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: PortfolioCard(
                                  currentUser: widget.userModel,
                                  portfolio: portfolio),
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
}
