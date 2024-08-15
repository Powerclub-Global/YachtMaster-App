

import 'package:flutter/material.dart';
import '../../search/model/services_model.dart';

class FavouritesVm extends ChangeNotifier {

  List<ServiceModel> favouritesServices = [
  ];
  List<ServiceModel> favouritesHosts = [
  ];
  update()
  {
    notifyListeners();
  }
}
