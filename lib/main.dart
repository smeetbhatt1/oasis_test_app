import 'package:flutter/material.dart';
import 'export/provider/export_provider.dart';
import 'export/screen/export_screen.dart';
import 'home/provider/home_provider.dart';
import 'addproduct/screen/add_product_screen.dart';
import 'addproduct/provider/add_product_provider.dart';
import 'home/screen/home_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<HomeProvider>(create: (_) => HomeProvider(),),
        ChangeNotifierProvider<AddProductProvider>(create: (_) => AddProductProvider(),),
        ChangeNotifierProvider<ExportProvider>(create: (_) => ExportProvider(),),
      ],
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: MaterialApp(
          title: 'Oasis Test App',
          theme: ThemeData(
            primarySwatch: Colors.purple,
          ),
          initialRoute: "/",
          routes: {
            "/": (_) => HomeScreen(),
            AddProductScreen.RouteName: (_) => AddProductScreen(),
            ExportScreen.RouteName: (_) => ExportScreen(),
          },
        ),
      ),
    );
  }
}

