import 'package:flutter/material.dart';
import 'package:oasis_test_app/model/product_model.dart';
import 'package:oasis_test_app/utils/dbhelper/db_helper.dart';

class AddProductProvider with ChangeNotifier {

  String profile;

  void setProfile(String s) {
    profile = s;
    notifyListeners();
  }

  void insertProduct(BuildContext context, Product product) async {
    product.imageBase64 = profile ?? '';
    int insertedID = await DbHelper.instance.insertLoanTypeRow(product: product);
    if (insertedID > 0) {
      profile = null;
      //Navigator.of(context).pop(true);
    }
  }
}