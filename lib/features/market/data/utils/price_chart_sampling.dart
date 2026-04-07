import 'package:crypto_informer/features/market/domain/entities/price_chart_point_entity.dart';

/// Упрощает ряд для отрисовки, если точек слишком много.
List<PriceChartPointEntity> samplePriceChartPoints(
  List<PriceChartPointEntity> points, {
  int maxPoints = 240,
}) {
  if (points.length <= maxPoints) {
    return List<PriceChartPointEntity>.from(points);
  }
  final out = <PriceChartPointEntity>[];
  final last = points.length - 1;
  final step = last / (maxPoints - 1);
  for (var i = 0; i < maxPoints; i++) {
    final idx = (i * step).round().clamp(0, last);
    out.add(points[idx]);
  }
  return out;
}
