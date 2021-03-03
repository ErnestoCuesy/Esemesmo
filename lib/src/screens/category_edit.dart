import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/category.dart';
import '../services/db_provider.dart';

class CategoryEdit extends StatefulWidget {
  final Category originalCategory;

  CategoryEdit(this.originalCategory);

  @override
  _CategoryEditState createState() => _CategoryEditState();
}

class _CategoryEditState extends State<CategoryEdit> {
  final formKey = GlobalKey<FormState>();
  final f = NumberFormat.currency(customPattern: "#.##");
  final snackBarCategorySaved = SnackBar(content: Text('Category saved'),);

  String newCategoryName;
  double newBudgetAmount = 0.0;
  double newThresholdAmount = 0.0;

  Widget categoryName(){
    return TextFormField(
      textCapitalization: TextCapitalization.sentences,
      onSaved: (String category) {
        this.newCategoryName = category;
      },
      decoration: const InputDecoration(
          labelText: 'Category name',
          hintText:'Enter category name'
      ),
      initialValue: widget.originalCategory.name,
      validator: validateCategoryName,
    );
  }

  Widget budgetAmount() {
    return TextFormField(
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      onSaved: (String amount) {
          this.newBudgetAmount = double.parse(amount) * 1.0;
      },
      decoration: const InputDecoration(
          labelText: 'Budget amount',
          hintText: 'Enter budget amount'
      ),
      initialValue: "${f.format(widget.originalCategory.budgetAmount)}",
      validator: validateBudget,
    );
  }

  Widget thresholdAmount() {
    return TextFormField(
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      onSaved: (String amount) {
          this.newThresholdAmount = double.parse(amount) * 1.0;
      },
      decoration: const InputDecoration(
          labelText: 'Alert threshold',
          hintText: 'Enter minimum threshold alert'
      ),
      initialValue: "${f.format(widget.originalCategory.threshold)}",
      validator: validateThreshold,
    );
  }

  Widget saveButton(){
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: RaisedButton(
        color: Colors.pink[100],
        child: Text('Save'),
        onPressed: validateFields,
      ),
    );
  }

  String validateCategoryName(String name) {
    if (name.isEmpty) {
      return 'Invalid category name';
    }
  }

  String validateBudget(String amount) {
    try {
      double budget = double.parse(amount) * 1.0;
    } catch (e) {
      return 'Invalid budget amount';
    }
  }

  String validateThreshold(String amount) {
    try {
      double threshold = double.parse(amount) * 1.0;
    } catch (e) {
      return 'Invalid threshold amount';
    }
  }

  validateFields() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      print("$newCategoryName : $newBudgetAmount : $newThresholdAmount");
      dBProvider.addCategory(Category(
          id: widget.originalCategory.id,
          name: newCategoryName,
          budgetAmount: newBudgetAmount,
          threshold: newThresholdAmount,
          transactionsTotal: 0.0));
      Scaffold.of(formKey.currentContext).showSnackBar(snackBarCategorySaved);
      Timer(Duration(seconds: 2), () {
        Navigator.pop(context, false);
      });
      // TODO validate threshold must be less than budget
      if (newThresholdAmount >= newBudgetAmount) {
        print("Threshold must be less than budget");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(
          'Edit Category',
        style: TextStyle(fontSize: 16.0),
        ),
      ),
      body: Container(
        height: 250.0,
        margin: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              categoryName(),
              budgetAmount(),
              thresholdAmount(),
              saveButton()
            ],
          ),
        ),
      ),
    );
  }
}