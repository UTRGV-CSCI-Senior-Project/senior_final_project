import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/service_locator.dart';
import 'package:google_fonts/google_fonts.dart';

Future<Map<String, dynamic>?> showSortFilterSheet(
  BuildContext context,
  String initialSortOption,
  String initialSortDirection,
  double initialRadius,
  List<String> initialSelectedServices,
) {
  return showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      isDismissible: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      routeSettings: const RouteSettings(arguments: null),
      builder: (BuildContext context) => SortFilterSheet(
            initialSortOption: initialSortOption,
            initialSortDirection: initialSortDirection,
            initialRadius: initialRadius,
            initialSelectedServices: initialSelectedServices,
          ));
}

class SortFilterSheet extends ConsumerStatefulWidget {
  final String initialSortOption;
  final String initialSortDirection;
  final double initialRadius;
  final List<String> initialSelectedServices;
  const SortFilterSheet({
    super.key,
    required this.initialSortOption,
    required this.initialSortDirection,
    required this.initialRadius,
    required this.initialSelectedServices,
  });

  @override
  ConsumerState<SortFilterSheet> createState() => _SortFilterSheetState();
}

class _SortFilterSheetState extends ConsumerState<SortFilterSheet> {
  final List<String> sortOptions = ['Distance', 'Name', 'Service'];
  late String selectedSortOption;

  final List<String> sortDirections = ['Ascending', 'Descending'];
  late String selectedSortDirection;

  late double currentRadius;
  late List<String> selectedServices;
  List<String> availableServices = [];
  List<String> filteredServices = [];
  bool showAllServices = false;
  static const int maxVisibleServices = 8;
  bool isExpanded = false;
  TextEditingController searchController = TextEditingController();
  final searchFocusNode = FocusNode();
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    selectedSortOption = widget.initialSortOption;
    selectedSortDirection = widget.initialSortDirection;
    currentRadius = widget.initialRadius;
    selectedServices = List.from(widget.initialSelectedServices);
    getServices();
  }

  @override
  void dispose() {
    searchFocusNode.dispose();
    searchController.dispose();
    super.dispose();
  }

  void getServices() async {
    try {
      final services = await ref.read(servicesStreamProvider.future);
      if (services.isNotEmpty) {
        setState(() {
          availableServices = services;
          filteredServices = services;
        });
      }
    } catch (e) {
      return;
    }
  }

  void filterServices(String query) async {
    setState(() {
      if (query.isNotEmpty) {
        final filtered = availableServices
            .where((service) =>
                service.toLowerCase().contains(query.toLowerCase()))
            .toList();
        setState(() {
          if (filtered.isNotEmpty) {
            filteredServices = filtered;
          } else {
            filteredServices = availableServices;
          }
        });
      } else {
        filteredServices = availableServices;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Sort and Filter',
              style:
                  GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context, {
                'sortBy': widget.initialSortOption,
                'sortDirection': widget.initialSortDirection,
                'radius': widget.initialRadius,
                'services': widget.initialSelectedServices,
              });
            },
          ),
          actions: [
            IconButton(
              key: const Key('apply-filters-button'),
              icon: const Icon(Icons.check),
              onPressed: () {
                Navigator.pop(context, {
                  'sortBy': selectedSortOption,
                  'sortDirection': selectedSortDirection,
                  'radius': currentRadius,
                  'services': selectedServices,
                });
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 20,
                ),
                child: Container(
                  padding: const EdgeInsets.only(top: 4, left: 2, right: 2),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 24),
                              decoration: BoxDecoration(
                                  color: Colors.grey[500]!.withOpacity(0.2)),
                              child: Text('SORTING',
                                  style: GoogleFonts.inter(fontSize: 14)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 24),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Sort By',
                                      style: GoogleFonts.inter(fontSize: 18)),
                                  DropdownButton<String>(
                                    alignment: Alignment.bottomCenter,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .textTheme
                                          .displayLarge
                                          ?.color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    elevation: 0,
                                    value: selectedSortOption,
                                    underline: Container(),
                                    items: sortOptions.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedSortOption = newValue!;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 24),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Sort Direction',
                                      style: GoogleFonts.inter(fontSize: 18)),
                                  ToggleButtons(
                                    fillColor: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.4),
                                    isSelected: [
                                      selectedSortDirection == 'Ascending',
                                      selectedSortDirection == 'Descending'
                                    ],
                                    onPressed: (index) {
                                      setState(() {
                                        selectedSortDirection = index == 0
                                            ? 'Ascending'
                                            : 'Descending';
                                      });
                                    },
                                    children: const [
                                      Icon(Icons.arrow_upward),
                                      Icon(Icons.arrow_downward),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 24),
                              decoration: BoxDecoration(
                                  color: Colors.grey[500]!.withOpacity(0.2)),
                              child: Text('FILTERS',
                                  style: GoogleFonts.inter(fontSize: 14)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 24),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Location Radius',
                                      style: GoogleFonts.inter(fontSize: 18)),
                                  Row(
                                    children: [
                                      IconButton(
                                        key: const Key('remove-radius'),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        icon: const Icon(
                                            Icons.remove_circle_outline),
                                        onPressed: () {
                                          setState(() {
                                            currentRadius =
                                                max(5, currentRadius - 5);
                                          });
                                        },
                                      ),
                                      Container(
                                        width: 60,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${currentRadius.round()} mi',
                                            style:
                                                GoogleFonts.inter(fontSize: 16),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        key: const Key('add-radius'),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        icon: const Icon(
                                            Icons.add_circle_outline),
                                        onPressed: () {
                                          setState(() {
                                            currentRadius =
                                                min(1000, currentRadius + 5);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 24),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Services',
                                      style: GoogleFonts.inter(fontSize: 18)),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isExpanded = !isExpanded;
                                      });
                                      searchFocusNode.requestFocus();
                                    },
                                    child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        alignment: Alignment.center,
                                        curve: Curves.easeInOut,
                                        width: isExpanded ? 200 : 40,
                                        height: 40,
                                        child: isExpanded
                                            ? Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[500]!
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                ),
                                                child: TextField(
                                                  onTap: () => searchFocusNode
                                                      .requestFocus(),
                                                  onChanged: (value) =>
                                                      filterServices(value),
                                                  cursorColor: Theme.of(context)
                                                      .textTheme
                                                      .displayLarge
                                                      ?.color,
                                                  controller: searchController,
                                                  focusNode: searchFocusNode,
                                                  decoration: InputDecoration(
                                                      hintText: 'Search',
                                                      enabledBorder: OutlineInputBorder(
                                                          borderRadius:
                                                              const BorderRadius.all(
                                                                  Radius.circular(
                                                                      50)),
                                                          borderSide: BorderSide(
                                                              width: 2,
                                                              color: Colors
                                                                  .grey[400]!)),
                                                      focusedBorder: OutlineInputBorder(
                                                          borderRadius:
                                                              const BorderRadius.all(
                                                                  Radius.circular(
                                                                      50)),
                                                          borderSide: BorderSide(
                                                              width: 3,
                                                              color: Colors
                                                                  .grey[400]!)),
                                                      hintStyle: GoogleFonts.inter(
                                                          fontWeight: FontWeight.w500,
                                                          color: Theme.of(context).textTheme.displayLarge?.color),
                                                      suffixIcon: IconButton(
                                                        icon: const Icon(
                                                            Icons.clear),
                                                        onPressed: () {
                                                          searchController
                                                              .clear();
                                                          filterServices('');
                                                          isExpanded = false;
                                                        },
                                                      ),
                                                      border: InputBorder.none,
                                                      contentPadding: const EdgeInsets.only(top: 12, left: 14)),
                                                ),
                                              )
                                            : const Center(
                                                child: Icon(Icons.search),
                                              )),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 24),
                              child: Wrap(
                                spacing: 8,
                                children: (showAllServices
                                        ? filteredServices
                                        : filteredServices
                                            .take(maxVisibleServices))
                                    .map((service) {
                                  return FilterChip(
                                    label: Text(service),
                                    selected:
                                        selectedServices.contains(service),
                                    onSelected: (bool value) {
                                      setState(() {
                                        if (value) {
                                          selectedServices.add(service);
                                        } else {
                                          selectedServices.remove(service);
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                            if (filteredServices.length > maxVisibleServices)
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 24, top: 0, right: 32),
                                child: Row(
                                  children: [
                                    const Spacer(),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          showAllServices = !showAllServices;
                                        });
                                      },
                                      child: Text(
                                        showAllServices ? 'less' : 'more',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                          ],
                        ),
                      ),
                    ],
                  ),
                ))));
  }
}
