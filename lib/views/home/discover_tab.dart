import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/controller/user_location_controller.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/models/portfolio_model.dart';
import 'package:folio/models/user_model.dart';
import 'package:folio/views/home/home_screen.dart';
import 'package:folio/widgets/portfolio_list_item.dart';
import 'package:folio/widgets/sort_filter_sheet.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

class DiscoverTab extends ConsumerStatefulWidget {
  final UserModel userModel;
  const DiscoverTab({super.key, required this.userModel});

  @override
  ConsumerState<DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends ConsumerState<DiscoverTab> {
  late LocationService locationService;
  final searchResultsProvider =
      StateProvider<List<PortfolioModel>>((ref) => []);
  final isSearchingProvider = StateProvider<bool>((ref) => false);
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;
  String sortOption = 'Distance';
  String sortDirection = 'Ascending';
  double? radius = 30.0;
  List<String> selectedServices = [];
  List<PortfolioModel> filteredPortfolios = [];

  @override
  void initState() {
    super.initState();
    locationService = ref.read(locationServiceProvider);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void filterPortfolios(
      List<PortfolioModel> portfolios, Position? currentLocation) {
    final filteredServices = portfolios.where((portfolio) {
      if (selectedServices.isEmpty) return true;
      return selectedServices.contains(portfolio.service);
    }).toList();
    List<PortfolioModel> filteredRadius = filteredServices;
    if (currentLocation != null && radius != null) {
      filteredRadius = filteredServices.where((portfolio) {
        if (portfolio.latAndLong?['longitude'] != null &&
            portfolio.latAndLong?['latitude'] != null) {
          final distance = locationService.distanceInMiles(
              currentLocation,
              portfolio.latAndLong!['latitude']!,
              portfolio.latAndLong!['longitude']!);
          return distance <= radius!;
        }
        return false;
      }).toList();
    }
    filteredPortfolios = List.from(filteredRadius);
    filteredPortfolios.sort((a, b) {
      int comparison = 0;

      if (sortOption == 'Distance' && currentLocation != null) {
        final distanceA = a.latAndLong?['longitude'] != null &&
                a.latAndLong?['latitude'] != null
            ? locationService.distanceInMiles(
                currentLocation,
                a.latAndLong!['latitude']!,
                a.latAndLong!['longitude']!,
              )
            : double.infinity;
        final distanceB = b.latAndLong?['longitude'] != null &&
                b.latAndLong?['latitude'] != null
            ? locationService.distanceInMiles(
                currentLocation,
                b.latAndLong!['latitude']!,
                b.latAndLong!['longitude']!,
              )
            : double.infinity;
        comparison = distanceA.compareTo(distanceB);
      } else if (sortOption == 'Name') {
        if (a.professionalsName != null && b.professionalsName != null) {
          comparison =
              (a.professionalsName ?? '').compareTo(b.professionalsName ?? '');
        }
      } else if (sortOption == 'Service') {
        comparison = a.service.compareTo(b.service);
      }
      return sortDirection == 'Ascending' ? comparison : -comparison;
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);
    final isSearching = ref.watch(isSearchingProvider);
    final currentLocation = ref.watch(currentPositionProvider);
    

    void discover(String query) async {
      ref.read(isSearchingProvider.notifier).state = true;
      final fetchedServices = await ref.read(servicesStreamProvider.future);
      final filtered = fetchedServices
          .where(
              (service) => service.toLowerCase().contains(query.toLowerCase()))
          .toList();
      if (filtered.isNotEmpty) {
        try{
        final results = await ref
            .watch(portfolioRepositoryProvider)
            .getDiscoverPortfolios(filtered);
        if (results.isNotEmpty) {
          ref.read(searchResultsProvider.notifier).state =
              results; // Update the provider
          filterPortfolios(results, currentLocation);
        }
        }catch (e) {
          ref.read(searchResultsProvider.notifier).state = [];
        }finally {
          ref.read(isSearchingProvider.notifier).state = false;
        }
      } else {
        try {
          final geminiDiscover =
              await ref.watch(geminiServicesProvider).aiDiscover(query);
          if (geminiDiscover.isNotEmpty) {
            final results = await ref
                .watch(portfolioRepositoryProvider)
                .getDiscoverPortfolios(geminiDiscover);
            if (results.isNotEmpty) {
              ref.read(searchResultsProvider.notifier).state =
                  results; // Update the provider
              filterPortfolios(results, currentLocation);
            }
          }
        } catch (e) {
          ref.read(searchResultsProvider.notifier).state = [];
        } finally {
          ref.read(isSearchingProvider.notifier).state = false;
        }
      }
    }

  ref.listen(discoverSearchProvider, (previous, next) {
    if (next != null) {
      searchController.text = next;
      discover(next);
      ref.read(discoverSearchProvider.notifier).state = null;
    }
  });

    void onSearchChanged(String text) {
      if (_debounce?.isActive ?? false) {
        _debounce?.cancel();
      }
      _debounce = Timer(const Duration(milliseconds: 900), () {
        if (text.isEmpty) {
          ref.read(searchResultsProvider.notifier).state = [];
          return;
        }
        discover(text);
      });
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[500]!.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      key: const Key('discover-field'),
                      onChanged: (value) => onSearchChanged(value),
                      cursorColor:
                          Theme.of(context).textTheme.displayLarge?.color,
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search a service or question',
                        enabledBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(50)),
                            borderSide:
                                BorderSide(width: 2, color: Colors.grey[400]!)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(50)),
                            borderSide:
                                BorderSide(width: 3, color: Colors.grey[400]!)),
                        hintStyle: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.color),
                        suffixIcon: isSearching
                            ? Transform.scale(
                                scale: 0.5,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 6,
                                  color: Colors.black,
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  searchController.clear();
                                  ref
                                      .read(searchResultsProvider.notifier)
                                      .state = [];
                                },
                              ),
                        prefixIcon: Icon(Icons.search,
                            color: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.color),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  key: const Key('filter-button'),
                  icon: const Icon(Icons.filter_list),
                  onPressed: () async {
                    final result = await showSortFilterSheet(context,
                        sortOption, sortDirection, radius, selectedServices);
                    setState(() {
                      if (result?['sortBy'] != null) {
                        sortOption = result?['sortBy'];
                      }
                      if (result?['sortDirection'] != null) {
                        sortDirection = result?['sortDirection'];
                      }
                        radius = result?['radius'];

                      if (result?['services'] != null) {
                        selectedServices = result?['services'];
                      }
                    });
                  },
                )
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            if (searchResults.isNotEmpty && filteredPortfolios.isEmpty)
              Expanded(
                  child: Center(
                      child: Text(
                'No portfolios matched your selected filters.',
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              )))
            else if (searchResults.isNotEmpty && filteredPortfolios.isNotEmpty)
              _buildSearchPortfolios(filteredPortfolios)
            else if (searchResults.isEmpty)
              _buildNearbyPortfolios()
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyPortfolios() {
    return ref.watch(allPortfoliosProvider).when(
        data: (portfolios) {
          final currentLocation = ref.watch(currentPositionProvider);
          if (portfolios.isEmpty) {
            return Expanded(
                child: Center(
                    child: Text(
              'No portfolios were found.',
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            )));
          }
          filterPortfolios(portfolios, currentLocation);
          if (filteredPortfolios.isEmpty) {
            return Expanded(
                child: Center(
                    child: Text(
              'No portfolios matched your selected filters.',
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            )));
          }
          return Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: filteredPortfolios.length,
              itemBuilder: (context, index) {
                final portfolio = filteredPortfolios[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PortfolioListItem(
                      currentUser: widget.userModel, portfolio: portfolio),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
            child: Text("Failed to load portfolios: $error",
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center)));
  }

  Widget _buildSearchPortfolios(List<PortfolioModel> portfolios) {
    return Expanded(
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: portfolios.length,
        itemBuilder: (context, index) {
          final portfolio = portfolios[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PortfolioListItem(
                currentUser: widget.userModel, portfolio: portfolio),
          );
        },
      ),
    );
  }
}
