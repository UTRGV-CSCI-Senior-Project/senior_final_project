import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';


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
                color: Colors.grey[500]!.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                cursorColor: Theme.of(context).textTheme.displayLarge?.color,
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search Folio',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                    borderSide: BorderSide(
                      width: 2,
                      color: Colors.grey[400]!
                    )
                    ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                    borderSide: BorderSide(
                      width: 3,
                      color: Colors.grey[400]!
                    )
                    ),
                  hintStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.displayLarge?.color),
                  prefixIcon: Icon(Icons.search, color: Theme.of(context).textTheme.displayLarge?.color),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}