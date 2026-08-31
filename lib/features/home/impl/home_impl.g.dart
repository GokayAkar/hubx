// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_impl.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_QuestionDto _$QuestionDtoFromJson(Map<String, dynamic> json) => _QuestionDto(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  subtitle: json['subtitle'] as String,
  imageUri: json['image_uri'] as String,
  uri: json['uri'] as String,
  order: (json['order'] as num).toInt(),
);

_CategoryPageDto _$CategoryPageDtoFromJson(Map<String, dynamic> json) =>
    _CategoryPageDto(
      data: (json['data'] as List<dynamic>)
          .map((e) => _CategoryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: _MetaDto.fromJson(json['meta'] as Map<String, dynamic>),
    );

_CategoryDto _$CategoryDtoFromJson(Map<String, dynamic> json) => _CategoryDto(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  image: _ImageDto.fromJson(json['image'] as Map<String, dynamic>),
);

_ImageDto _$ImageDtoFromJson(Map<String, dynamic> json) =>
    _ImageDto(url: json['url'] as String);

_MetaDto _$MetaDtoFromJson(Map<String, dynamic> json) => _MetaDto(
  pagination: _PaginationDto.fromJson(
    json['pagination'] as Map<String, dynamic>,
  ),
);

_PaginationDto _$PaginationDtoFromJson(Map<String, dynamic> json) =>
    _PaginationDto(
      page: (json['page'] as num).toInt(),
      pageCount: (json['pageCount'] as num).toInt(),
    );
