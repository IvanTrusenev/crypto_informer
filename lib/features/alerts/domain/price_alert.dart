import 'dart:convert';

class PriceAlert {
  const PriceAlert({
    required this.coinId,
    required this.coinName,
    required this.thresholdPrice,
    required this.isAbove,
  });

  factory PriceAlert.fromJson(Map<String, dynamic> json) => PriceAlert(
    coinId: json['coinId'] as String,
    coinName: json['coinName'] as String,
    thresholdPrice: (json['thresholdPrice'] as num).toDouble(),
    isAbove: json['isAbove'] as bool,
  );

  final String coinId;
  final String coinName;
  final double thresholdPrice;

  /// `true` — alert fires when price goes **above** threshold.
  /// `false` — alert fires when price drops **below** threshold.
  final bool isAbove;

  Map<String, dynamic> toJson() => {
    'coinId': coinId,
    'coinName': coinName,
    'thresholdPrice': thresholdPrice,
    'isAbove': isAbove,
  };

  static List<PriceAlert> decodeList(String raw) =>
      (jsonDecode(raw) as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(PriceAlert.fromJson)
          .toList();

  static String encodeList(List<PriceAlert> alerts) =>
      jsonEncode(alerts.map((a) => a.toJson()).toList());
}
