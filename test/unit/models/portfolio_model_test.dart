

import 'package:folio/models/portfolio_model.dart';
import 'package:test/test.dart';

void main() {
  group('PortfolioModel constructor', () {
    test('creates a valid portfolio', () {
      final portfolio = PortfolioModel(
          service: 'Barber', details: 'Im a barber', years: 3, months: 1);

      expect(portfolio.service, 'Barber');
      expect(portfolio.details, 'Im a barber');
      expect(portfolio.years, 3);
      expect(portfolio.months, 1);
    });

    test('throws an error when service is empty', () {
      expect(
          () => PortfolioModel(
              service: '', details: 'deets', years: 2, months: 2),
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
          images: [
            {'filePath': 'image/path', 'downloadUrl': 'image.url'}
          ]);

      final json = portfolio.toJson();
      expect(json['service'], 'Barber');
      expect(json['details'], 'Im a barber');
      expect(json['years'], 3);
      expect(json['months'], 1);
      expect(json['images'], [{'filePath': 'image/path', 'downloadUrl': 'image.url'}]);
    });
  });

  group('fromJson', () {
    test('should return a valid portfolio model', () {
      final jsonPortfolio = {
        'service': 'Nail Tech',
        'details': 'Nails!',
        'years': 3,
        'months': 1,
        'images': [{'filePath': 'image/path', 'downloadUrl': 'image.url'}]
      };

      final portfolio = PortfolioModel.fromJson(jsonPortfolio);

      expect(portfolio.service, 'Nail Tech');
      expect(portfolio.details, 'Nails!');
      expect(portfolio.years, 3);
      expect(portfolio.months, 1);
      expect(portfolio.images, [{'filePath': 'image/path', 'downloadUrl': 'image.url'}]);
    });

    test('should throw an error when service is missing', () {
      expect(() => PortfolioModel.fromJson({
        'details': 'deets',
        'years': 3,
        'months': 1
      }), throwsArgumentError);
    });
  });

  group('calculateTotalExperience', () {
  test('should calculate total experience without start date', () {
    final portfolio = PortfolioModel(
      service: 'Barber',
      details: 'Professional barber',
      years: 3,
      months: 5,
    );

    final experience = portfolio.calculateTotalExperience();
    expect(experience['years'], 3);
    expect(experience['months'], 5);
  });

  test('should calculate total experience with start date', () {
    // Setting a fixed date for the test
    final startDate = DateTime(2022, 5, 8); // 2.5 years ago
    
    final portfolio = PortfolioModel(
      service: 'Barber',
      details: 'Professional barber',
      years: 1,
      months: 6,
      experienceStartDate: startDate,
    );

    final experience = portfolio.calculateTotalExperience();
    expect(experience['years'], 4); // 1 year prior + 2.5 years since start date
    expect(experience['months'], 0);
  });

  test('should handle month overflow correctly', () {
    final portfolio = PortfolioModel(
      service: 'Barber',
      details: 'Professional barber',
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
    );

    expect(portfolio.getFormattedTotalExperience(), '5 months');
  });

  test('should format experience with both years and months', () {
    final portfolio = PortfolioModel(
      service: 'Barber',
      years: 1,
      months: 1,
    );

    expect(portfolio.getFormattedTotalExperience(), '1 year, 1 month');
  });

  test('should return "Beginner" for zero experience', () {
    final portfolio = PortfolioModel(
      service: 'Barber',
      years: 0,
      months: 0,
    );

    expect(portfolio.getFormattedTotalExperience(), 'Beginner');
  });

  test('should handle singular/plural forms correctly', () {
    final portfolioSingular = PortfolioModel(
      service: 'Barber',
      years: 1,
      months: 1,
    );

    final portfolioPlural = PortfolioModel(
      service: 'Barber',
      years: 2,
      months: 2,
    );

    expect(portfolioSingular.getFormattedTotalExperience(), '1 year, 1 month');
    expect(portfolioPlural.getFormattedTotalExperience(), '2 years, 2 months');
  });
});
}
