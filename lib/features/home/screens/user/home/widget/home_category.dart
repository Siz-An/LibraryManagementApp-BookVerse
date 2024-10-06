import 'package:flutter/cupertino.dart';

import '../../../../../../common/widgets/image_text_widgets/vertical_image_text.dart';
import '../../../../../../utils/constants/image_strings.dart';

class THomeCategory extends StatelessWidget {
  const THomeCategory({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 85,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: 5,
          scrollDirection: Axis.horizontal,
          itemBuilder: (_, index){
            return  TVerticalImageText(image: TImages.user, title: 'Horror', onTap: (){},);
          }),
    );
  }
}