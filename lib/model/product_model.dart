
import 'package:flutter/foundation.dart';

class Product {
  final String name;
  final String mobile;
  final String productType;
  final String amount;
  final String amountType;
  final String date;
  String imageBase64;

  Product({
    @required this.name,
    @required this.mobile,
    @required this.productType,
    @required this.amount,
    @required this.amountType,
    @required this.date,
    @required this.imageBase64,
});
}