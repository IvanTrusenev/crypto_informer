import 'package:json_annotation/json_annotation.dart';

part 'coin_image_dto.g.dart';

/// Вложенная сетевая модель изображений монеты.
@JsonSerializable(createToJson: false)
class CoinImageDto {
  const CoinImageDto({this.thumb, this.small, this.large});

  factory CoinImageDto.fromJson(Map<String, dynamic> json) =>
      _$CoinImageDtoFromJson(json);

  final String? thumb;
  final String? small;
  final String? large;
}
