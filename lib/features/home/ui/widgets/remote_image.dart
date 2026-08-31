import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hubx/core/extensions/build_context_x.dart';

/// A picture from the network, with somewhere for the eye to rest while it
/// arrives and something that is not a broken glyph if it never does.
///
/// Cached rather than plain [Image.network]: the grid scrolls these in and out
/// of view constantly, and re-downloading a picture the moment it comes back
/// on screen is both slow and rude to whoever is paying for the data.
class RemoteImage extends StatelessWidget {
  const RemoteImage({required this.url, this.fit = BoxFit.cover, super.key});

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(color: context.palette.surfaceRaised);

    // The name of the thing is written next to it in every place this is
    // used, so a screen reader announcing the picture too would say it twice.
    return ExcludeSemantics(
      // Decoded at the size it is drawn at, not the size it was uploaded at.
      // A category tile is 132pt wide and the file behind it is often over a
      // thousand pixels; decoded whole, one tile costs several megabytes of
      // memory and the grid holds a screenful of them at a time.
      //
      // Measured rather than passed in: the caller already decided the size by
      // laying this out, and a number repeated at the call site is one that
      // can disagree with the box it is describing.
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          return CachedNetworkImage(
            imageUrl: url,
            fit: fit,
            memCacheWidth: width.isFinite && width > 0
                ? (width * MediaQuery.devicePixelRatioOf(context)).round()
                : null,
            placeholder: (_, _) => placeholder,
            errorWidget: (_, _, _) => placeholder,
          );
        },
      ),
    );
  }
}
