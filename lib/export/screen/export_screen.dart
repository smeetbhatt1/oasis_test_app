import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oasis_test_app/export/provider/export_provider.dart';
import 'package:oasis_test_app/utils/constants.dart';
import 'package:oasis_test_app/utils/empty_focus_node.dart';
import 'package:provider/provider.dart';

class ExportScreen extends StatefulWidget {
  static const String RouteName ='/export';
  @override
  _ExportScreenState createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {

  final _exportFormKey = GlobalKey<FormState>();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  DateTime _selectedStartDate;
  DateTime _selectedEndDate;

  ExportTo _exportTo = ExportTo.CSV;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Export Data'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _exportFormKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextFieldStartDate(),
                SizedBox(height: 8,),
                _buildTextFieldEndDate(),
                SizedBox(height: 8,),
                Text(
                  'Export to:',
                  style: new TextStyle(
                    fontSize: 14.0,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                RadioListTile(
                  value: ExportTo.CSV,
                    groupValue: _exportTo,
                    title: Text("CSV"),
                    onChanged: (value) {
                      setState(() {
                        _exportTo = value;
                      });
                    },
                ),
                RadioListTile(
                  value: ExportTo.Excel,
                  groupValue: _exportTo,

                  title: Text("Excel"),
                  onChanged: (value) {
                    setState(() {
                      _exportTo = value;
                    });
                  },
                ),
                SizedBox(height: 8,),
                _buildButtonSave(),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonSave() {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: double.infinity),
      child: ElevatedButton(
        onPressed: () {
          if (_exportFormKey.currentState.validate()) {
            if (_selectedEndDate.compareTo(_selectedStartDate) >= 0) {
              Provider.of<ExportProvider>(context, listen: false).exportData(
                context,
                _selectedStartDate,
                _selectedEndDate,
                _exportTo
              );
            }
            else {
              showDialog(
                  context: context,
                  builder: (ctx) {
                    return AlertDialog(
                      title: Text("Warning"),
                      content: Text("End date should be after start date"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                          child: Text("OK"),
                        ),
                      ],
                    );
                  });
            }
          }
        },
        child: Text('Export'),
      ),
    );
  }

  Widget _buildTextFieldStartDate() {
    return TextFormField(
      focusNode: AlwaysDisabledFocusNode(),
      controller: _startDateController,
      onTap: () {
        _selectStartDate(context);
      },
      decoration: InputDecoration(
          hintText: "Start Date",
        labelText: "Start Date",
      ),
      validator: _validateDate,
    );
  }

  Widget _buildTextFieldEndDate() {
    return TextFormField(
      focusNode: AlwaysDisabledFocusNode(),
      controller: _endDateController,
      onTap: () {
        _selectEndDate(context);
      },
      decoration: InputDecoration(
        hintText: "End Date",
        labelText: "End Date",
      ),
      validator: _validateDate,
    );
  }

  void _selectStartDate(BuildContext context) async {
    DateTime newSelectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate != null ? _selectedStartDate : DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),);

    if (newSelectedDate != null) {
      _selectedStartDate = newSelectedDate;
      _startDateController
        ..text = DateFormat("dd-MMM-yyyy").format(_selectedStartDate)
        ..selection = TextSelection.fromPosition(TextPosition(
            offset: _startDateController.text.length,
            affinity: TextAffinity.upstream));
    }
  }

  void _selectEndDate(BuildContext context) async {
    DateTime newSelectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate != null ? _selectedEndDate : DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),);

    if (newSelectedDate != null) {
      _selectedEndDate = newSelectedDate;
      _endDateController
        ..text = DateFormat("dd-MMM-yyyy").format(_selectedEndDate)
        ..selection = TextSelection.fromPosition(TextPosition(
            offset: _endDateController.text.length,
            affinity: TextAffinity.upstream));
    }
  }


  String _validateDate(String text) {
    if (text.trim().isEmpty)
      return "Select Date";
    return null;
  }
}
