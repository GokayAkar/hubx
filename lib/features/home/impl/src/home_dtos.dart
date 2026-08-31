part of '../home_impl.dart';

/// The shapes the two endpoints actually send, and nothing else.
///
/// They live here rather than in `api/` on purpose: the wire format is this
/// layer's problem, so a rename at the far end is a change to one file instead
/// of a change to every screen that reads a model. Each DTO carries a
/// [toDomain] that hands back the type the rest of the app knows.
///
/// Parsing is generated rather than written: `fromJson` is the kind of code
/// that is tedious to write, easy to get subtly wrong, and silently wrong when
/// a field is added. Only `fromJson` is generated — the app never sends these
/// back, and a `toJson` nobody calls is dead code that still has to be read.

/// One entry of `/getQuestions`.
@JsonSerializable(createToJson: false)
class _QuestionDto {
  const _QuestionDto({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUri,
    required this.uri,
    required this.order,
  });

  factory _QuestionDto.fromJson(Map<String, dynamic> json) =>
      _$QuestionDtoFromJson(json);

  final int id;
  final String title;
  final String subtitle;

  @JsonKey(name: 'image_uri')
  final String imageUri;

  final String uri;

  /// Where the server wants this shown. Trusting it beats trusting the order
  /// the list happened to arrive in.
  final int order;

  Question toDomain() => Question(
    id: id,
    title: title,
    subtitle: subtitle,
    imageUrl: imageUri,
    articleUrl: uri,
  );
}

/// The body of `/getCategories`: one slice, plus where it sits in the whole.
@JsonSerializable(createToJson: false)
class _CategoryPageDto {
  const _CategoryPageDto({required this.data, required this.meta});

  factory _CategoryPageDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryPageDtoFromJson(json);

  final List<_CategoryDto> data;
  final _MetaDto meta;

  ResultPage<PlantCategory> toDomain() => ResultPage(
    items: [for (final category in data) category.toDomain()],
    // The server's own count, not the length of what arrived: a client that
    // guesses "a full page means there may be another" always asks once more
    // and gets nothing back.
    hasMore: meta.pagination.page < meta.pagination.pageCount,
  );
}

@JsonSerializable(createToJson: false)
class _CategoryDto {
  const _CategoryDto({
    required this.id,
    required this.title,
    required this.image,
  });

  factory _CategoryDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryDtoFromJson(json);

  final int id;
  final String title;
  final _ImageDto image;

  PlantCategory toDomain() =>
      PlantCategory(id: id, title: title, imageUrl: image.url);
}

/// The uploaded file behind a category. It carries a dozen fields the app has
/// no use for, and the generator ignores every one it is not told about.
@JsonSerializable(createToJson: false)
class _ImageDto {
  const _ImageDto({required this.url});

  factory _ImageDto.fromJson(Map<String, dynamic> json) =>
      _$ImageDtoFromJson(json);

  final String url;
}

@JsonSerializable(createToJson: false)
class _MetaDto {
  const _MetaDto({required this.pagination});

  factory _MetaDto.fromJson(Map<String, dynamic> json) =>
      _$MetaDtoFromJson(json);

  final _PaginationDto pagination;
}

@JsonSerializable(createToJson: false)
class _PaginationDto {
  const _PaginationDto({required this.page, required this.pageCount});

  factory _PaginationDto.fromJson(Map<String, dynamic> json) =>
      _$PaginationDtoFromJson(json);

  final int page;
  final int pageCount;
}
