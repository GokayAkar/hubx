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
      child: CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        placeholder: (_, _) => placeholder,
        errorWidget: (_, _, _) => placeholder,
      ),
    );
  }
}
