

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
}
