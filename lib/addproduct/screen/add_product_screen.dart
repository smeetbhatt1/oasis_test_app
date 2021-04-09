import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:oasis_test_app/addproduct/provider/add_product_provider.dart';
import 'package:oasis_test_app/model/product_model.dart';
import 'package:oasis_test_app/utils/constants.dart';
import 'package:oasis_test_app/utils/empty_focus_node.dart';
import 'package:provider/provider.dart';

class AddProductScreen extends StatefulWidget {
  static const String RouteName = '/add-product';
  static final _mobileStartWith = ["6", "7", "8", "9"];

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _addFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nameNode = FocusNode();
  final _mobileController = TextEditingController();
  final _mobileNode = FocusNode();
  final _amountController = TextEditingController();
  final _amountNode = FocusNode();
  final _dateController = TextEditingController();
  DateTime _selectedDate;

  static const double circularDPRadius = 52;
  static final _productTypeOptions = ["-- Select Product Type --", "Product", "Service",];
  String _ddProductTypeValue = _productTypeOptions[0];
  static final _amountTypeOptions = ["-- Select Amount Type --", "Cash", "Online", "Gpay"];
  String _ddAmountTypeValue = _amountTypeOptions[0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _addFormKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileAvatarStack(),
                _buildTextFieldName(),
                SizedBox(height: 8,),
                _buildTextFieldMobile(),
                SizedBox(height: 8,),
                _buildDropDownProductType(),
                _buildTextFieldAmount(),
                SizedBox(height: 8,),
                _buildDropDownAmountType(),
                _buildTextFieldDate(),
                SizedBox(height: 8,),
                _buildButtonSave(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatarStack() {
    return Stack(
      children: <Widget>[
        IntrinsicWidth(
          child: Container(
            child: Selector<AddProductProvider, String>(
              selector: (_, p) => p.profile,
              builder: (_, str, child) {
                return  CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: CircleAvatar(
                    child: str == null || str.trim().isEmpty || str.trim() == 'null' ? Image(image: AssetImage('assets/images/profile_image.png')) : null,
                    radius: circularDPRadius - 0.5,
                    backgroundImage: str == null || str.trim().isEmpty || str.trim() == 'null' ? null : MemoryImage(base64Decode(str)),
                    backgroundColor: Colors.white,
                  ),
                  radius: circularDPRadius,
                );
              },
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 3,
          child: Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              /*border: Border.all(color: ColorConstants.lightRoyalBue),
                color: Colors.white*/
            ),
            child: GestureDetector(
              onTap: _showModalSheet,
              child: Image(image: AssetImage('assets/images/camera_blue.png')),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFieldName() {
    return TextFormField(
      focusNode: _nameNode,
      controller: _nameController,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (s) {
        _nameNode.unfocus();
        _mobileNode.requestFocus();
      },
      autofocus: false,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.words,
      validator: _validateName,
      decoration: InputDecoration(
        hintText: "Name",
        /*border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
        ),*/
      ),
    );
  }

  Widget _buildTextFieldMobile() {
    return TextFormField(
      focusNode: _mobileNode,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (s) {
        _mobileNode.unfocus();
      },
      autofocus: false,
      keyboardType: TextInputType.number,
      controller: _mobileController,
      validator: _validateMobile,
      decoration: InputDecoration(
        hintText: "Mobile Number",
        /*border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
        ),*/
      ),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
    );
  }

  Widget _buildDropDownProductType() {
    return DropdownButton<String>(
      value: _ddProductTypeValue,
      isExpanded: true,
      onChanged: (String value) {
        _nameNode.unfocus();
        _mobileNode.unfocus();
        _amountNode.unfocus();
        FocusScope.of(context).requestFocus(FocusNode());
        setState(() {
          _ddProductTypeValue = value;
        });
      },
      items: _productTypeOptions.map((e) {
        return DropdownMenuItem<String>(
          value: e,
          child: Text(e),
        );

      }).toList(),
    );
  }

  Widget _buildTextFieldAmount() {
    return TextFormField(
      focusNode: _amountNode,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (s) {
        _amountNode.unfocus();
      },
      autofocus: false,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      controller: _amountController,
      validator: _validateAmount,
      decoration: InputDecoration(
        hintText: "Amount",
        /*border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
        ),*/
      ),
      /*inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp('([0-9]+(\.[0-9]+)?)')),
      ],*/
    );
  }

  Widget _buildDropDownAmountType() {
    return DropdownButton<String>(
      value: _ddAmountTypeValue,
      isExpanded: true,
      onChanged: (String value) {
        _nameNode.unfocus();
        _mobileNode.unfocus();
        _amountNode.unfocus();
        FocusScope.of(context).requestFocus(FocusNode());
        setState(() {
          _ddAmountTypeValue = value;
        });
      },
      items: _amountTypeOptions.map((e) {
        return DropdownMenuItem<String>(
          value: e,
          child: Text(e),
        );

      }).toList(),
    );
  }

  Widget _buildTextFieldDate() {
    return TextFormField(
      focusNode: AlwaysDisabledFocusNode(),
      controller: _dateController,
      onTap: () {
        _selectDate(context);
      },
      decoration: InputDecoration(
        hintText: "Date"
      ),
      validator: _validateDate,
    );
  }

  Widget _buildButtonSave() {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: double.infinity),
      child: ElevatedButton(
        onPressed: () {
          String message = "";
          bool isValid = true;
          if (_ddProductTypeValue == _productTypeOptions[0]) {
            message = "Select Product Type";
          }
          if (_ddAmountTypeValue == _amountTypeOptions[0]) {
            message = "Select Amount Type";
          }
          if (_ddProductTypeValue == _productTypeOptions[0] && _ddAmountTypeValue == _amountTypeOptions[0]) {
            message = "Select Product Type and Amount Type";
          }
          if (message.isNotEmpty) {
            isValid = false;
            Fluttertoast.showToast(
              msg: message,
              toastLength: Toast.LENGTH_LONG,

            );
          }
          if (_addFormKey.currentState.validate() && isValid) {
            Product product = Product(
              name: _nameController.text,
              mobile: _mobileController.text,
              productType: _ddProductTypeValue,
              amount: _amountController.text,
              amountType: _ddAmountTypeValue,
              date: DateFormat("yyyy-MM-dd HH:mm:ss").format(_selectedDate),
              imageBase64: "",
            );
            Provider.of<AddProductProvider>(context, listen: false)
                .insertProduct(context, product);
          }
        },
        child: Text('Save'),
      ),
    );
  }

  String _validateName(text) {
    if (text.trim().isEmpty)
      return "Enter Name";
    else if (!RegExp(r"^[a-zA-Z' ]+$").hasMatch(text))
      return "Invalid name";
    return null;
  }

  String _validateMobile(String text) {
    if (text.trim().isEmpty)
      return "Enter Mobile Number";

    try {
      double d = double.parse(text);
    }
    catch (e) {
      return "Invalid mobile number";
    }

    if (text.length != 10) {
      if (text.length != 11)
        return "Invalid mobile number";
    }

    if (!AddProductScreen._mobileStartWith.contains(text.substring(0,1))) {
      return "Invalid mobile number";;
    }
    return null;
  }

  String _validateAmount(String text) {
    if (text.trim().isEmpty)
      return "Enter Amount";
    if (text.trim().startsWith("-"))
      return "Amount should be greater than 0";
    try {
      double d = double.parse(text);
    }
    catch (e) {
      return "Invalid Amount";
    }
    return null;
  }

  String _validateDate(String text) {
    if (text.trim().isEmpty)
      return "Select Date";
    return null;
  }

  void _selectDate(BuildContext context) async {
    DateTime newSelectedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate != null ? _selectedDate : DateTime.now(),
        firstDate: DateTime(1990),
        lastDate: DateTime.now(),);

    if (newSelectedDate != null) {
      _selectedDate = newSelectedDate;
      _dateController
        ..text = DateFormat("dd-MMM-yyyy").format(_selectedDate)
        ..selection = TextSelection.fromPosition(TextPosition(
            offset: _dateController.text.length,
            affinity: TextAffinity.upstream));
    }
  }

  void _showModalSheet() {
    _nameNode.unfocus();
    _mobileNode.unfocus();
    _amountNode.unfocus();
    FocusScope.of(context).requestFocus(FocusNode());
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.camera, color: Theme.of(context).primaryColor,),
                  title: Text("Open Camera"),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _openCameraOrGallery(ImageUploader.Camera);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.image, color: Theme.of(context).primaryColor,),
                  title: Text("Open Gallery"),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _openCameraOrGallery(ImageUploader.File);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.clear, color: Theme.of(context).primaryColor,),
                  title: Text("Clear Image"),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    Provider.of<AddProductProvider>(context, listen: false).setProfile(null);
                  },
                ),
              ],
            ),
          );
        });
  }

  void _openCameraOrGallery(ImageUploader imageUploader) async {
    File imageFile;
    if (imageUploader == ImageUploader.Camera)
      imageFile = await ImagePicker.pickImage(
        source: ImageSource.camera,
        maxHeight: 600,
        maxWidth: 800,
        imageQuality: 80,
      );
    else if (imageUploader == ImageUploader.File)
      imageFile = await ImagePicker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 600,
        maxWidth: 800,
        imageQuality: 80,
      );

    if (imageFile != null) {
      List<int> imgBytes = imageFile.readAsBytesSync();
      String base64 = base64Encode(imgBytes);
      Provider.of<AddProductProvider>(context, listen: false).setProfile(base64);
    }
  }

}

