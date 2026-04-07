import 'package:crypto_informer/features/market/data/utils/price_chart_sampling.dart';
import 'package:crypto_informer/features/market/domain/entities/price_chart_point_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('samplePriceChartPoints', () {
    test('reduces large input to maxPoints', () {
      final points = List.generate(
        500,
        (i) => PriceChartPointEntity(
          timestamp: DateTime(2024).add(Duration(hours: i)),
          priceUsd: 100.0 + i,
        ),
      );

      const testMax = 100;
      final result = samplePriceChartPoints(points, maxPoints: testMax);

      expect(result.length, 100);
      expect(result.first.timestamp, points.first.timestamp);
      expect(result.last.timestamp, points.last.timestamp);
    });

    test('returns copy if input is shorter than maxPoints', () {
      final points = [
        PriceChartPointEntity(
          timestamp: DateTime(2024),
          priceUsd: 100,
        ),
        PriceChartPointEntity(
          timestamp: DateTime(2024, 1, 2),
          priceUsd: 110,
        ),
      ];

      final result = samplePriceChartPoints(points);

      expect(result.length, 2);
      expect(result, isNot(same(points)));
    });

    test('handles empty input', () {
      final result = samplePriceChartPoints([]);

      expect(result, isEmpty);
    });
  });
}
