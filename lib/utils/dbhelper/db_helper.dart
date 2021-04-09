
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:oasis_test_app/model/product_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class DbHelper {
  static final _databaseName = "oasis.db";
  static final _databaseVersion = 30;

  static const _TABLE_PRODUCT = 'PRODUCT';
  static const _COL_ID = 'ID';
  static const _COL_NAME = 'NAME';
  static const _COL_MOBILE = 'MOBILE';
  static const _COL_PRODUCT_TYPE = 'PRODUCT_TYPE';
  static const _COL_AMOUNT = 'AMOUNT';
  static const _COL_AMOUNT_TYPE = 'AMOUNT_TYPE';
  static const _COL_DATE = 'DATE';
  static const _COL_PHOTO_BASE64 = 'PHOTO_BASE64';
  static const _COL_CREATED_DATE = 'CREATED_DATE';

  DbHelper._privateConstructor();
  static final DbHelper instance = DbHelper._privateConstructor();

  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    String documentsDirectory = await getDatabasesPath();
    String path = join(documentsDirectory, _databaseName);
    print(path);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $_TABLE_PRODUCT (
            $_COL_ID INTEGER PRIMARY KEY AUTOINCREMENT,
            $_COL_NAME TEXT,
            $_COL_MOBILE TEXT,
            $_COL_PRODUCT_TYPE TEXT,
            $_COL_AMOUNT TEXT,
            $_COL_AMOUNT_TYPE TEXT,
            $_COL_DATE DATETIME,
            $_COL_PHOTO_BASE64 TEXT,
            $_COL_CREATED_DATE DATETIME DEFAULT (datetime('now','localtime'))
          )
          ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute("DROP TABLE IF EXISTS $_TABLE_PRODUCT");
    _onCreate(db, newVersion);
  }

  Future<int> insertLoanTypeRow({@required Product product}) async {

    Database db = await instance.database;
    Map<String, dynamic> contentValues = {
      _COL_NAME: product.name,
      _COL_MOBILE: product.mobile,
      _COL_PRODUCT_TYPE: product.productType,
      _COL_AMOUNT: product.amount,
      _COL_AMOUNT_TYPE: product.amountType,
      _COL_DATE: product.date,
      _COL_PHOTO_BASE64: product.imageBase64,
    };

    return await db.insert(_TABLE_PRODUCT, contentValues,);
  }

  Future<List<Product>> getAllProducts() async {
    Database db = await instance.database;
    try {
      final list = await db.query(
        _TABLE_PRODUCT,
        orderBy: '$_COL_CREATED_DATE DESC',
      );
      List<Product> loans = list.map((e) {
        DateTime dt = DateFormat("yyyy-MM-dd HH:mm:ss").parse(e[_COL_DATE]);
        return Product(
          name: e[_COL_NAME],
          mobile: e[_COL_MOBILE],
          productType: e[_COL_PRODUCT_TYPE],
          amount: e[_COL_AMOUNT],
          amountType: e[_COL_AMOUNT_TYPE],
          date: DateFormat("dd-MMM-yyyy").format(dt),
          imageBase64: e[_COL_PHOTO_BASE64],
        );
      }).toList();
      return loans;
    }
    catch (e) {
    }
    return [];
  }

  Future<List<Product>> getProducts(String startDate, String endDate) async {
    Database db = await instance.database;
    try {
      String query = "";
        query = '''
        SELECT * FROM $_TABLE_PRODUCT WHERE 
        date($_COL_DATE) >= '$startDate' AND 
        date($_COL_DATE) <= '$endDate' 
        ORDER BY $_COL_ID
        ''';
      final list = await db.rawQuery(
        query
      );
      List<Product> loans = [];
      loans = list.map((e) =>
          Product(
            name: e[_COL_NAME],
            mobile: e[_COL_MOBILE],
            productType: e[_COL_PRODUCT_TYPE],
            amount: e[_COL_AMOUNT],
            amountType: e[_COL_AMOUNT_TYPE],
            date: e[_COL_DATE],
            imageBase64: e[_COL_PHOTO_BASE64],
          )).toList();
      return loans;
    }
    catch (e) {
    }
    return [];
  }

}