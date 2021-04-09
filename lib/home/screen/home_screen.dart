import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:oasis_test_app/addproduct/screen/add_product_screen.dart';
import 'package:oasis_test_app/export/screen/export_screen.dart';
import 'package:oasis_test_app/model/product_model.dart';
import '../provider/home_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeProvider>(context, listen: false).fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
      ),
      body: Stack(
        children: [
          Container(
            child: _buildListProduct(),
          ),
          Selector<HomeProvider,bool>(
            selector: (_, p) => p.showLoader,
              builder: (_, val, child) {
                return val ? child : Container();
              },
              child: Center(
                child: CircularProgressIndicator(),
              ),)
        ],
      ),
      floatingActionButton: _buildSpeedDial(),
    );
  }

  Widget _buildListProduct() {
    return Consumer<HomeProvider>(
      builder: (_, p, child) {

        return p.products != null && p.products.isNotEmpty ?
        ListView.separated(
            itemBuilder: (_, i) {
              Product prd = p.products[i];
              return ListTile(
                leading: CircleAvatar(
                  child: prd.imageBase64 == null || prd.imageBase64.trim().isEmpty ? Image(image: AssetImage('assets/images/profile_image.png'), height: 32, width: 32,) : null,
                  radius: 32,
                  backgroundImage: prd.imageBase64 == null || prd.imageBase64.trim().isEmpty ? null : MemoryImage(base64Decode(prd.imageBase64)),
                  backgroundColor: Colors.white,
                ),
                title: Text(p.products[i].name),
                subtitle: Text(p.products[i].date),
                trailing: Text(p.products[i].amount),
              );
            },
            separatorBuilder: (_, i) => Divider(height: 1, color: Colors.grey,),
            itemCount: p.products.length,
        )
        : child;
      },
      child: Center(
        child: Text('No Data Found'),
      ),
    );
  }

  SpeedDial _buildSpeedDial() {
    return SpeedDial(
      marginEnd: 18,
      marginBottom: 20,
      icon: Icons.menu,
      activeIcon: Icons.clear,buttonSize: 56.0,
      visible: true,
      closeManually: false,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      tooltip: 'Menu',
      heroTag: 'speed-dial-hero-tag',
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      elevation: 8.0,
      shape: CircleBorder(),
      gradientBoxShape: BoxShape.circle,
      children: [
        SpeedDialChild(
          child: Icon(Icons.import_export, color: Theme.of(context).accentColor,),
          backgroundColor: Colors.white,
          label: 'Export',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: () => Navigator.of(context).pushNamed(ExportScreen.RouteName),
        ),
        SpeedDialChild(
          child: Icon(Icons.add, color: Theme.of(context).accentColor,),
          backgroundColor: Colors.white,
          label: 'Add',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: () => Navigator.of(context).pushNamed(AddProductScreen.RouteName).then((value) {
            if (value != null && value is bool && value) {
              Provider.of<HomeProvider>(context, listen: false).fetchProducts();
            }
          }),
        ),
      ],
    );
  }
}
