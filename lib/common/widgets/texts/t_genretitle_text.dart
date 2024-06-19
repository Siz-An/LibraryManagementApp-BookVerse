
import 'package:flutter/material.dart';

import '../../../utils/constants/enums.dart';

class TGenreTitleText extends StatelessWidget {
  const TGenreTitleText({super.key, required this.title, required this.maxLines, this.color, this.textAlign, required this.genreTextSizes});

  final String title;
  final int maxLines;
  final Color?  color;
  final TextAlign? textAlign;
  final TextSizes genreTextSizes;
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: genreTextSizes == TextSizes.small
        ? Theme.of(context).textTheme.labelMedium!.apply(color: color)
          : genreTextSizes == TextSizes.medium
        ? Theme.of(context).textTheme.bodyLarge!.apply(color: color)
          : genreTextSizes == TextSizes.large
    ? Theme.of(context).textTheme.titleLarge!.apply(color: color)
      :Theme.of(context).textTheme.bodyMedium!.apply(color: color),

    );
  }
}
