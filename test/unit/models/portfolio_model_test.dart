
import 'package:folio/models/portfolio_model.dart';
import 'package:test/test.dart';

void main() {
  group('PortfolioModel constructor', () {
    test('creates a valid portfolio', () {
      final portfolio = PortfolioModel(
          service: 'Barber',
          details: 'Im a barber',
          years: 3,
          months: 1,
          uid: 'test-uid',
          address: '1234s Street',
          latAndLong: {'latitude': 40.7128, 'longitude': -74.0060},
          professionalsName: 'Test User',
          nameArray: ['Test', 'User']
          );

      expect(portfolio.service, 'Barber');
      expect(portfolio.details, 'Im a barber');
      expect(portfolio.years, 3);
      expect(portfolio.months, 1);
      expect(portfolio.uid, 'test-uid');
      expect(portfolio.address, '1234s Street');
      expect(portfolio.latAndLong, {'latitude': 40.7128, 'longitude': -74.0060});
      expect(portfolio.professionalsName, 'Test User');
      expect(portfolio.nameArray, ['Test', 'User']);
    });

    test('throws an error when service is empty', () {
      expect(
          () => PortfolioModel(
              service: '',
              details: 'deets',
              years: 2,
              months: 2,
              uid: 'test-uid'),
          throwsArgumentError);
    });

    test('throws an error when uid is empty', () {
      expect(
          () => PortfolioModel(
              service: 'service',
              details: 'deets',
              years: 2,
              months: 2,
              uid: ''),
          throwsArgumentError);
    });
  });

  group('toJson', () {
    test('should return a valid JSON representation', () {
      final portfolio = PortfolioModel(
          service: 'Barber',
          details: 'Im a barber',
          years: 3,
          months: 1,
          uid: 'test-uid',
          address: '1234s Street',
          latAndLong: {'latitude': 40.7128, 'longitude': -74.0060},
          professionalsName: 'Test User',
          nameArray: ['Test', 'User'],
          images: [
            {'filePath': 'image/path', 'downloadUrl': 'image.url'}]
          );


      final json = portfolio.toJson();
      expect(json['service'], 'Barber');
      expect(json['details'], 'Im a barber');
      expect(json['years'], 3);
      expect(json['months'], 1);
      expect(json['images'], [
        {'filePath': 'image/path', 'downloadUrl': 'image.url'}
      ]);
      expect(json['uid'], 'test-uid');
      expect(json['address'], '1234s Street');
      expect(json['latAndLong'],  {'latitude': 40.7128, 'longitude': -74.0060});
      expect(json['professionalsName'], 'Test User');
      expect(json['nameArray'], ['Test', 'User']);


    });
  });

  group('fromJson', () {
    test('should return a valid portfolio model', () {
      final jsonPortfolio = {
        'service': 'Nail Tech',
        'details': 'Nails!',
        'years': 3,
        'months': 1,
        'uid': 'test-uid',
        'images': [
          {'filePath': 'image/path', 'downloadUrl': 'image.url'}
        ],
        'professionalsName': 'Nail User',
        'nameArray': ['Nail', 'User'], 
        'address': '1234s Street',
        'latAndLong': {'latitude': 40.7128, 'longitude': -74.0060}
      };

      final portfolio = PortfolioModel.fromJson(jsonPortfolio);

      expect(portfolio.service, 'Nail Tech');
      expect(portfolio.details, 'Nails!');
      expect(portfolio.years, 3);
      expect(portfolio.months, 1);
      expect(portfolio.images, [
        {'filePath': 'image/path', 'downloadUrl': 'image.url'}
      ]);
      expect(portfolio.uid, 'test-uid');
      expect(portfolio.professionalsName, 'Nail User');
      expect(portfolio.nameArray, ['Nail', 'User']);
      expect(portfolio.address, '1234s Street');
      expect(portfolio.latAndLong, {'latitude': 40.7128, 'longitude': -74.0060});
    });

    test('should throw an error when service is missing', () {
      expect(
          () => PortfolioModel.fromJson(
              {'details': 'deets', 'years': 3, 'months': 1, 'uid': 'test-uid'}),
          throwsArgumentError);
    });
    test('should throw an error when uid is missing', () {
      expect(
          () => PortfolioModel.fromJson({
                'service': 'service',
                'details': 'deets',
                'years': 3,
                'months': 1
              }),
          throwsArgumentError);
    });
  });

  group('calculateTotalExperience', () {
    test('should calculate total experience without start date', () {
      final portfolio = PortfolioModel(
          service: 'Barber',
          details: 'Professional barber',
          years: 3,
          months: 5,
          uid: 'test-uid');

      final experience = portfolio.calculateTotalExperience();
      expect(experience['years'], 3);
      expect(experience['months'], 5);
    });

    test('should calculate total experience with start date', () {
      // Setting a fixed date for the test
      final startDate = DateTime(2022, 5, 8); 

      final portfolio = PortfolioModel(
        service: 'Barber',
        details: 'Professional barber',
        years: 1,
        months: 6,
        uid: 'test-uid',
        experienceStartDate: startDate,
      );

      final experience = portfolio.calculateTotalExperience();
      expect(
          experience['years'], 4);
      expect(experience['months'], 1);
    });

    test('should handle month overflow correctly', () {
      final portfolio = PortfolioModel(
        service: 'Barber',
        details: 'Professional barber',
        uid: 'test-uid',
        years: 2,
        months: 14, // This should convert to 3 years and 2 months
      );

      final experience = portfolio.calculateTotalExperience();
      expect(experience['years'], 3);
      expect(experience['months'], 2);
    });
  });

  group('getFormattedTotalExperience', () {
    test('should format experience with only years', () {
      final portfolio = PortfolioModel(
        uid: 'test-uid',
        service: 'Barber',
        years: 2,
        months: 0,
      );

      expect(portfolio.getFormattedTotalExperience(), '2 years');
    });

    test('should format experience with only months', () {
      final portfolio = PortfolioModel(
        service: 'Barber',
        years: 0,
        months: 5,
        uid: 'test-uid',
      );

      expect(portfolio.getFormattedTotalExperience(), '5 months');
    });

    test('should format experience with both years and months', () {
      final portfolio = PortfolioModel(
        service: 'Barber',
        years: 1,
        months: 1,
        uid: 'test-uid',
      );

      expect(portfolio.getFormattedTotalExperience(), '1 year, 1 month');
    });

    test('should return "Beginner" for zero experience', () {
      final portfolio = PortfolioModel(
        service: 'Barber',
        years: 0,
        months: 0,
        uid: 'test-uid',
      );

      expect(portfolio.getFormattedTotalExperience(), 'Beginner');
    });

    test('should handle singular/plural forms correctly', () {
      final portfolioSingular = PortfolioModel(
        service: 'Barber',
        years: 1,
        months: 1,
        uid: 'test-uid',
      );

      final portfolioPlural = PortfolioModel(
        service: 'Barber',
        years: 2,
        months: 2,
        uid: 'test-uid',
      );

      expect(
          portfolioSingular.getFormattedTotalExperience(), '1 year, 1 month');
      expect(
          portfolioPlural.getFormattedTotalExperience(), '2 years, 2 months');
    });
  });
}
