import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:senior_final_project/main.dart';

void main(){
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('test', () {
    testWidgets('example', (tester) async {

      await tester.pumpWidget( MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('APP Name'), findsWidgets);

    });
  });
}

