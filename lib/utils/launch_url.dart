import 'package:url_launcher/url_launcher.dart';

class LaunchUrl
{
  static   launchURL(String url) async {
    print(url);
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault);
    } else {
      throw 'Could not launch $url';
    }
  }


}