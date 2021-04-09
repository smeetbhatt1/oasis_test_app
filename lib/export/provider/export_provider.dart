import 'dart:io';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:oasis_test_app/utils/dbhelper/db_helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import '../../model/product_model.dart';
import '../../utils/constants.dart';

class ExportProvider with ChangeNotifier {

  void exportData(BuildContext context, DateTime startDate, DateTime endDate, ExportTo exportTo) async {
    String startDateStr = DateFormat("yyyy-MM-dd").format(startDate);
    String endDateStr = DateFormat("yyyy-MM-dd").format(endDate);

    List<Product> products = await DbHelper.instance.getProducts(startDateStr, endDateStr);
    if (products == null || products.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text("Warning"),
            content: Text('No data found for the given date range'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                }, child: Text("CLOSE"),
              ),
            ],
          );
        },
      );
    }
    else {
        checkStoragePermission(context, products, exportTo);
    }
  }

  void checkStoragePermission(BuildContext context, List<Product> products, ExportTo exportTo) async {
    var status = await Permission.storage.status;
    if (status.isPermanentlyDenied) {
      Fluttertoast.showToast(msg: "Allow this app to access storage from setting");
    }
    else if (status.isGranted) {
      if (exportTo == ExportTo.CSV)
        _storeCSVFile(context, products);
      else if (exportTo == ExportTo.Excel)
        _storeExcelFile(context, products);
    }
    else {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request().then((value) {
        if (value[Permission.storage] == PermissionStatus.granted) {
          if (exportTo == ExportTo.CSV)
            _storeCSVFile(context, products);
          else if (exportTo == ExportTo.Excel)
            _storeExcelFile(context, products);
        }
        return value;
      });
    }
  }

  void _storeCSVFile(BuildContext context, List<Product> products) async {
    List<List<String>> data = [
      ["Name", "Mobile", "Product Type", "Amount", "Amount Type", "Date"],
    ];
    products.forEach((e) {
      List<String> item = [];

      DateTime dt = DateFormat("yyyy-MM-dd HH:mm:ss").parse(e.date);
      item.add(e.name);
      item.add(e.mobile);
      item.add(e.productType);
      item.add(e.amount);
      item.add(e.amountType);
      item.add(DateFormat("dd-MMM-yyyy").format(dt));
      data.add(item);
    });

    var testdir = await Directory('/storage/emulated/0/Smeet Bhatt/').create(recursive: true);

    String fPath = testdir.path;
    File f = new File(fPath + "product.csv");
    String csv = const ListToCsvConverter().convert(data);
    f.writeAsString(csv);

    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text("CSV file generated"),
            content: Text('product.csv file is stored in folder \'Smeet Bhatt\' in your phone storage'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                }, child: Text("CLOSE"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  Uint8List bytes = f.readAsBytesSync();
                  await Share.shareFiles([fPath + "product.csv"]);
                }, child: Text("SHARE"),
              ),
            ],
          );
        },
    );
  }

  void _storeExcelFile(BuildContext context, List<Product> products) async {
    var excel = Excel.createExcel();

    Sheet sheetObject = excel['products'];
    excel.link('products', sheetObject);

    List<String> d = [
      "Name",
      "Mobile",
      "Product Type",
      "Amount",
      "Amount Type",
      "Date",
    ];
    sheetObject.insertRowIterables(d, 0);
    for (int i = 0; i < products.length; i++) {
      String strDate = products[i].date;
      DateTime dt = DateFormat("yyyy-MM-dd HH:mm:ss").parse(strDate);
      List<String> dataList = [
        products[i].name,
        products[i].mobile,
        products[i].productType,
        products[i].amount,
        products[i].amountType,
        DateFormat("dd-MMM-yyyy").format(dt),
      ];

      sheetObject.insertRowIterables(dataList, i+1);
    }
    await excel.setDefaultSheet("products");

    var testdir = await Directory('/storage/emulated/0/Smeet Bhatt/').create(recursive: true);
    String fPath = testdir.path;
    File f = new File(fPath + "product.xlsx");
    excel.encode().then((onValue) {
      f
        ..createSync(recursive: true)
        ..writeAsBytesSync(onValue);

      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text("Excel file generated"),
            content: Text('product.xlsx file is stored in folder \'Smeet Bhatt\' in your phone storage'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                }, child: Text("CLOSE"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  Uint8List bytes = f.readAsBytesSync();
                  await Share.shareFiles([fPath + "product.xlsx"]);
                }, child: Text("SHARE"),
              ),
            ],
          );
        },
      );

    });

  }
}