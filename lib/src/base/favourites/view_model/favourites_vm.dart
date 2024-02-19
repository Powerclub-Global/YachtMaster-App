

import 'package:flutter/material.dart';
import 'package:yacht_master/src/base/search/model/services_model.dart';

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
