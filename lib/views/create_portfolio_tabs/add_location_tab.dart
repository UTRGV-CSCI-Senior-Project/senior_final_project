import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_places_autocomplete_widgets/address_autocomplete_widgets.dart';

class AddLocationTab extends StatefulWidget {
  final Function(String?, double?, double?) onAddressChosen;
  String? title;
  String? subtitle;
   AddLocationTab({super.key, required this.onAddressChosen, this.title, this.subtitle});

  @override
  State<AddLocationTab> createState() => _AddLocationTabState();
}

class _AddLocationTabState extends State<AddLocationTab> {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        widget.title ?? "Let's get your profile ready!",
        style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w500),
      ), 
      const SizedBox(height: 8.0),
      Text(
        widget.subtitle ?? "Enter your business location.\nOthers won't be able to see this.",
        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w300),
      ),
      const SizedBox(height: 16.0),
      AddressAutocompleteTextField(
        mapsApiKey: dotenv.env['PLACES_API_KEY'] ?? '',
        decoration: InputDecoration(
          hintText: 'Enter your address',
          hintStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.displayLarge!.color),
          prefixIcon: Icon(Icons.location_on,
              color: Theme.of(context).colorScheme.primary),

          // Use the input decoration theme from the current context
          border: Theme.of(context).inputDecorationTheme.border,
          enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
          focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
        ),

        // Customize suggestions overlay to match theme
        suggestionsOverlayDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: null),

        // Custom suggestion item builder
        buildItem: (suggestion, index) {
          return ListTile(
              tileColor: Theme.of(context).colorScheme.surface,
              title: Text(
                suggestion.description.split(',')[0],
                style: GoogleFonts.inter(
                    color: Theme.of(context).textTheme.displayLarge!.color),
              ),
              subtitle: Text(
                suggestion.description.split(',').sublist(1).join(','),
                style: GoogleFonts.inter(
                    color: Theme.of(context)
                        .textTheme
                        .displayLarge!
                        .color
                        ?.withOpacity(0.7)),
              ),
              hoverColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.1));
        },
        // Theme-based colors
        hoverColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        selectionColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        
        elevation: 0,
        overlayOffset: 4,
        onSuggestionClick: (place) {
          widget.onAddressChosen(place.formattedAddress, place.lat, place.lng);
        },
        showGoogleTradeMark: false,
      )
    ]);
  }
}
