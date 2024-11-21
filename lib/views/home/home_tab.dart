import 'package:flutter/material.dart';
import 'package:folio/controller/user_location_controller.dart';
import 'package:folio/models/user_model.dart';
import 'package:folio/views/home/update_services_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeTab extends StatefulWidget {
  final UserModel? userModel;

  HomeTab({
    super.key,
    required this.userModel,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late Future<String> currentCityFuture;
  @override
  void initState() {
    super.initState();
    currentCityFuture = getCurrentCity();
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
                  children: [
                    FutureBuilder(
                      future: currentCityFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text(
                            "Fetching current city...",
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w900, fontSize: 16),
                          );
                        } else if (snapshot.hasError) {
                          return Text(
                            "Error fetching city",
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w900, fontSize: 16),
                          );
                        } else {
                          return Text(
                            "Current city: ${snapshot.data}",
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w900, fontSize: 16),
                          );
                        }
                      },
                    )
                  ],
                ),
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
                      itemCount: widget.userModel!.preferredServices.length,
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
                      "Just Uploaded",
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
              ],
            ),
          ],
        ),
      ),
    ));
  }
}
