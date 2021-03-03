import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'category_edit.dart';
import '../resources/globals.dart';

class CategoryListView extends StatefulWidget {
  @override
  _CategoryListViewState createState() => _CategoryListViewState();
}

class _CategoryListViewState extends State<CategoryListView> {
  final snackBarCategoryDeleted = SnackBar(
    content: Text('Category deleted'),
  );

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      await dBProvider.fetchAllCategories().then((cats) {
        setState(() {
          globalData.categories = cats;
        });
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Widget _formattedCategoryAmounts(int index) {
    final f = NumberFormat.simpleCurrency(locale: "en_ZA");
    return Column(
      children: <Widget>[
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Budget Amount:",
              ),
              Text(
                "${f.format(globalData.categories[index].budgetAmount)}",
              ),
            ]),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("Alert below:"),
            Text("${f.format(globalData.categories[index].threshold)}"),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Budget Categories",
          style: TextStyle(fontSize: 16.0),
        ),
      ),
      body: _categoryList(),
      floatingActionButton: _newCategoryFAB(),
    );
  }

  Widget _newCategoryFAB() {
    return FloatingActionButton(
      tooltip: "Add Category",
      child: Icon(Icons.add),
      onPressed: _newCategory,
    );
  }

  _newCategory() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => CategoryEdit(Category(
                id: globalData.categories[globalData.categories.length - 1].id +
                    1,
                name: "New category",
                budgetAmount: 0.0,
                threshold: 0.0,
                transactionsTotal: 0.0)))).then((newValues) {
      globalData.categories.clear();
      _loadCategories();
    });
  }

  Widget _categoryList() {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;
    return ListView.builder(
        itemCount: globalData.categories.length,
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
            key: Key(globalData.categories[index].id.toString()),
            background: Container(
              color: Colors.white,
              child: Icon(
                Icons.delete,
                size: 32.0,
              ),
            ),
            direction: DismissDirection.horizontal,
            confirmDismiss: (_) => _showDeleteCategoryDialog(context, index),
            child: Card(
              elevation: 8.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListTile(
                    leading: Icon(CategoryServices.categoryIcon(
                        globalData.categories[index].id)),
                    title: Text(
                      globalData.categories[index].name,
                      style: textTheme.headline6,
                    ),
                    subtitle: _formattedCategoryAmounts(index),
                    isThreeLine: true,
                    onTap: index == 0
                        ? null
                        : () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            CategoryEdit(
                                                globalData.categories[index])))
                                .then((newValues) {
                              globalData.categories.clear();
                              _loadCategories();
                            }),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<bool> _showDeleteCategoryDialog(
      BuildContext scaffoldContext, int index) async {
    bool dismiss;
    if (index == 0) {
      dismiss = false;
    } else {
      int txCount = 0;
      txCount = globalData.transactionsMaster
          .where((tx) => tx.category == globalData.categories[index].id)
          .length;
      if (txCount > 0) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                    "Delete category ${globalData.categories[index].name}?"),
                content: Text(
                    "There are $txCount payments allocated to this category, but don't worry they'll be uncategorized."),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Yes, delete category"),
                    onPressed: () {
                      setState(() {
                        _deleteCategory(index);
                        Scaffold.of(scaffoldContext)
                            .showSnackBar(snackBarCategoryDeleted);
                        Navigator.of(context).pop();
                        dismiss = true;
                      });
                    },
                  ),
                  FlatButton(
                    child: Text("No, cancel"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      dismiss = false;
                    },
                  )
                ],
              );
            });
      } else {
        setState(() {
          _deleteCategory(index);
          Scaffold.of(scaffoldContext).showSnackBar(snackBarCategoryDeleted);
          dismiss = true;
        });
      }
    }
    return dismiss;
  }

  _deleteCategory(int index) {
    globalData.transactionsMaster.forEach((transaction) {
      if (transaction.category == globalData.categories[index].id) {
        transaction.category = 0;
      }
    });
    dBProvider.updateAllCategoryTransactions(
        0, globalData.categories[index].id);
    dBProvider.deleteCategory(globalData.categories[index].id);
    CategoryServices.deleteCategoryTotal(globalData.categories[index].id);
    globalData.categories.removeAt(index);
  }
}
