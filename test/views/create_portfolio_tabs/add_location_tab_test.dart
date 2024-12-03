import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/views/create_portfolio_tabs/add_location_tab.dart';
import 'package:google_maps_places_autocomplete_widgets/widgets/address_autocomplete_textfield.dart';

void main(){
   setUpAll(() async {
    // Initialize dotenv before running tests
     dotenv.testLoad(fileInput: 'PLACES_API_KEY=test_key');
  });
  testWidgets('AddLocationTab renders correctly', (WidgetTester tester) async {

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AddLocationTab(
            onAddressChosen: (city, state, lat, lng) {
            },
          ),
        ),
      ),
    );

    // Verify text headers exist
    expect(find.text("Let's get your profile ready!"), findsOneWidget);
    expect(find.text("Enter your business location.\nOthers won't be able to see this."), findsOneWidget);

    // Verify address autocomplete field exists
    expect(find.byType(AddressAutocompleteTextField), findsOneWidget);
  });

  testWidgets('Address selection triggers onAddressChosen', (WidgetTester tester) async {
    bool onAddressChosenCalled = false;
    String? capturedCity;
    String? capturedState;
    double? capturedLat;
    double? capturedLng;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AddLocationTab(
            onAddressChosen: (city, state, lat, lng) {
              onAddressChosenCalled = true;
              capturedCity = city;
              capturedState = state;
              capturedLat = lat;
              capturedLng = lng;
            },
          ),
        ),
      ),
    );

  final AddressAutocompleteTextField autocompleteField = 
      tester.widget(find.byType(AddressAutocompleteTextField));
    
    final mockPlace = Place(
      city: 'New York', 
      state: 'NY', 
      lat: 40.7128, 
      lng: -74.0060
    );

    autocompleteField.onSuggestionClick?.call(mockPlace);
    await tester.pump();

    // Verify callback was triggered with mock location
    expect(onAddressChosenCalled, isTrue);
    expect(capturedCity, 'New York');
    expect(capturedState, 'NY');
    expect(capturedLat, 40.7128);
    expect(capturedLng, -74.0060);
  });
}