import 'package:flutter/foundation.dart';
import 'package:oasis_test_app/model/product_model.dart';
import 'package:oasis_test_app/utils/dbhelper/db_helper.dart';

class HomeProvider with ChangeNotifier {
  List<Product> products = [];
  bool showLoader = false;

  void fetchProducts() async {
    showLoader = true;
    notifyListeners();
    try {
      products = await DbHelper.instance.getAllProducts();
      if (products == null)
        products = [];
    }
    catch (e) {

    }
    showLoader = false;
    notifyListeners();
  }
}