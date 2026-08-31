import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hubx/core/theme/app_dimensions.dart';
import 'package:hubx/core/theme/app_text_styles.dart';
import 'package:hubx/features/home/api/home_api.dart';
import 'package:hubx/features/home/ui/widgets/remote_image.dart';

/// The promoted articles, as a row the user pushes sideways.
class QuestionCards extends StatelessWidget {
  const QuestionCards({
    required this.questions,
    required this.onOpen,
    this.withHeroes = true,
    super.key,
  });

  final List<Question> questions;
  final ValueChanged<Question> onOpen;

  /// False for a row standing in for a real one. A skeleton must not fly:
  /// its cards repeat, and heroes sharing a tag are an error as soon as any
  /// route transition begins.
  final bool withHeroes;

  static const _cardWidth = 240.0;
  static const _cardHeight = 164.0;

  static double get height => _cardHeight.w;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.s24),
        itemCount: questions.length,
        separatorBuilder: (_, _) => SizedBox(width: AppSpacing.s12),
        itemBuilder: (context, index) => _Card(
          question: questions[index],
          withHero: withHeroes,
          onTap: () => onOpen(questions[index]),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.question,
    required this.withHero,
    required this.onTap,
  });

  final Question question;
  final bool withHero;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: QuestionCards._cardWidth.w,
      child: Material(
        borderRadius: BorderRadius.circular(AppRadius.r12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // The tag ties this picture to the one on the detail screen, so
              // the two are the same object moving rather than one screen
              // replacing another.
              if (withHero)
                Hero(
                  tag: heroTagFor(question),
                  child: RemoteImage(url: question.imageUrl),
                )
              else
                RemoteImage(url: question.imageUrl),
              const _Scrim(),
              Padding(
                padding: EdgeInsets.all(AppSpacing.s12),
                child: Align(
                  alignment: AlignmentDirectional.bottomStart,
                  child: Text(
                    question.title,
                    style: AppTextStyles.medium15.copyWith(color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Darkens the foot of the picture so white text can sit on it whatever the
/// photograph happens to be doing there.
class _Scrim extends StatelessWidget {
  const _Scrim();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.center,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Color(0xCC000000)],
        ),
      ),
    );
  }
}

/// The tag both ends of the transition agree on.
String heroTagFor(Object item) => switch (item) {
  Question() => 'question-${item.id}',
  PlantCategory() => 'category-${item.id}',
  _ => throw ArgumentError.value(item, 'item', 'has no hero tag'),
};
