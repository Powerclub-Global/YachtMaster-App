import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../../../../../../resources/resources.dart';

class DisplayImage {
  static Widget showImage(String? link) {
    return FadeInImage.memoryNetwork(
      image: link??"",
      fit: BoxFit.fill,
      imageErrorBuilder: (context, url, error) => Image.asset(
        R.images.selectPicture,
        fit: BoxFit.fill,
      ),
      placeholderErrorBuilder: (context, url, e) =>
          SpinKitPulse(color: R.colors.secondary),
      placeholder: kTransparentImage,
    );
  }
}
