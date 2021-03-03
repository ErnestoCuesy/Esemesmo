import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../resources/globals.dart';
import 'email_capture_view.dart';

class PaymentListView extends StatefulWidget {

  @override
  _PaymentListViewState createState() => _PaymentListViewState();
}

class _PaymentListViewState extends State<PaymentListView> {
  final f = NumberFormat.simpleCurrency(locale: "en_ZA");
  final snackBarExcluded = SnackBar(content: Text('Payment excluded'),);
  final snackBarIncluded = SnackBar(content: Text('Payment included'),);
  final snackBarEmailSent = SnackBar(content: Text('Email sent'),);
  String _appBarCategory;
  String _appBarPeriod;
  var theme;
  var textTheme;
  int currentFilter;
  int _year;
  int _month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      leading: categoryFilterMenuButton(),
        title: Text(
          "${globalData.transactions.length} $_appBarCategory $_appBarPeriod",
          style: TextStyle(fontSize:16.0),
        ),
        actions: <Widget>[yearMonthMenuButton()],
      ),
      body: RefreshIndicator(
          child: _paymentsList(),
        onRefresh: () async {
            setState(() {

            });
        },
      ),
    );
  }

  Widget _paymentsList() {
    theme = Theme.of(context);
    textTheme = theme.textTheme;
    if (globalData.categories.length == 0) {
      return Center(child: CircularProgressIndicator());
    } else {
      return ListView.builder(
        itemCount: globalData.transactions.length,
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
            key: Key(globalData.transactions[index].date.toString()),
            background: Container(
              color: Colors.white,
              child: globalData.transactions[index].excludeFlag ? Icon(Icons.lightbulb_outline, size: 32.0,) : Icon(Icons.delete, size: 32.0,),
            ),
            direction: DismissDirection.horizontal,
            onDismissed: (_) {
              setState(() {
                if (globalData.transactions[index].excludeFlag) {
                  globalData.transactionsMaster.forEach((trans) {
                    if (trans.date == globalData.transactions[index].date) {
                      trans.excludeFlag = false;
                    }
                  });
                  globalData.transactions[index].excludeFlag = false;
                  // TODO change to a nicer sound
                  SystemSound.play(SystemSoundType.click);
                  Scaffold.of(context).showSnackBar(snackBarIncluded);
                } else {
                  globalData.transactionsMaster.forEach((trans) {
                    if (trans.date == globalData.transactions[index].date) {
                      trans.excludeFlag = true;
                    }
                  });
                  globalData.transactions[index].excludeFlag = true;
                  // TODO change to a nicer sound
                  SystemSound.play(SystemSoundType.click);
                  Scaffold.of(context).showSnackBar(snackBarExcluded);
                }
                dBProvider.updateTransaction(globalData.transactions[index]);
                globalData.transactions.removeAt(index);
              });
            },
            child: Card(
              elevation:12.0,
              color: getCardColor(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // TODO add category name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: 160.0,
                        child: Container(
                          alignment: AlignmentDirectional.topStart,
                          margin: EdgeInsets.only(left: 64.0, top: 4.0),
                          height: 20.0,
                          child: categoryName(index),
                        ),
                      ),
                      Container(
                        alignment: AlignmentDirectional.topEnd,
                        padding: EdgeInsets.only(right: 4.0, top: 4.0),
                        width: 190.0,
                        height: 20.0,
                        child: Text(globalData.transactions[index].manualEntry ? "M/E" :
                        "${bankNames[globalData.transactions[index].bank]}",
                          style: textTheme.subtitle.copyWith(color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
                  leading: categoryMenuButton(index),
                  title: Padding(
                    padding: const EdgeInsets.only(left: 0.0),
                    child: Text(globalData.transactions[index].vendor),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(left: 0.0),
                    child: Text(
                        Utilities.formatDateTime(globalData.transactions[index].date))
                  ),
                  trailing: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0, right: 8.0),
                    child: Text(f.format(globalData.transactions[index].amount)),
                  ),
                ),
                ],
              ),
            ),
          );
        });
    }
  }

  Text categoryName(int index) {
    int catIndex = globalData.categories.indexWhere((cat) {
      return globalData.transactions[index].category == cat.id;
    });
    Text catName = Text("${globalData.categories[catIndex].name}",
        style: globalData.transactions[index].category == 0 ? textTheme.subtitle.copyWith(color: Colors.pink) :
        textTheme.subtitle.copyWith(color: Colors.blue));
    return catName;
  }

  Color getCardColor(int index) {
    Color cardColor;
    if (globalData.transactions[index].excludeFlag) {
      cardColor = Colors.grey[300];
    } else {
      if (globalData.transactions[index].category == 0) {
        cardColor = Colors.yellow[100];
      } else {
        cardColor = Colors.green[50];
      }
    }
    return cardColor;
  }

  Widget yearMonthMenuButton() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.calendar_today),
        onSelected: (String yearMonth) {
          setState(() {
            if (!yearMonth.contains('All')) {
              var yearMonthArr = yearMonth.split('/');
              _year = int.parse(yearMonthArr[0]);
              _month = int.parse(yearMonthArr[1]);
              _appBarPeriod = "for $yearMonth";
              PaymentServices.copyTransactions(currentFilter, _year, _month);
            } else {
              _appBarPeriod = '(all)';
              //_appBarCategory = 'payments';
              PaymentServices.copyTransactions(currentFilter, 0, 0);
            }
          });
        },
        itemBuilder: (BuildContext context) {
          return globalData.yearMonthList.map((String ymItem) {
            return PopupMenuItem<String>(
                child: Text(ymItem),
                value: ymItem
            );
          }).toList();
        });
  }

  Widget categoryFilterMenuButton() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.payment),
        onSelected: (String filterItem) {
          setState(() {
            _appBarPeriod = '';
            if (filterItem.contains(SHOW_CATEGORIZED)) {
              _appBarCategory = APPBAR_CATEGORIZED;
              currentFilter = COPY_CATEGORIZED;
              PaymentServices.copyTransactions(COPY_CATEGORIZED, 0, 0);
            } else {
              if (filterItem.contains(SHOW_UNCATEGORIZED)) {
                _appBarCategory = APPBAR_UNCATEGORIZED;
                currentFilter = COPY_UNCATEGORIZED;
                PaymentServices.copyTransactions(COPY_UNCATEGORIZED, 0, 0);
              } else {
                if (filterItem.contains(SHOW_EXCLUDED)) {
                  _appBarCategory = APPBAR_EXCLUDED;
                  currentFilter = COPY_EXCLUDED;
                  PaymentServices.copyTransactions(COPY_EXCLUDED, 0, 0);
                } else {
                  if (filterItem.contains(SHOW_ALL)) {
                    _appBarCategory = APPBAR_ALL;
                    currentFilter = COPY_ALL;
                    PaymentServices.copyTransactions(COPY_ALL, 0, 0);
                  } else {
                    _sendViaEmail();
                  }
                }
              }
            }
          });
        },
        itemBuilder: (BuildContext context) {
          int uncategorized = globalData.transactionsMaster.where((tx) => tx.category == 0 && !tx.excludeFlag).length;
          int excluded = globalData.transactionsMaster.where((tx) => tx.excludeFlag).length;
          int categorized = globalData.transactionsMaster.where((tx) => tx.category != 0 && !tx.excludeFlag).length;
          int all = globalData.transactionsMaster.where((tx) => !tx.excludeFlag).length;
          return [SHOW_UNCATEGORIZED + '($uncategorized)',
                  SHOW_CATEGORIZED + '($categorized)',
                  SHOW_ALL + '($all)',
                  SHOW_EXCLUDED + '($excluded)',
                  SEND_VIA_EMAIL].map((String filterItem) {
            return PopupMenuItem<String>(
                child: Text(filterItem),
                value: filterItem
            );
          }).toList();
        });
  }

  void _sendViaEmail() {
    Navigator.of(context).push(EmailCapture()).then((_) {
      print("Sending ${globalData.transactions.length} transactions to ${globalData.preferences.recipientEmailAddress}");
      EmailServices.sendPayments();
    });
  }

  void _showUpdatePaymentsCategoryDialog(Category category, int index) {
    if (globalData.transactions[index].category != category.id) {
      int vendorCount = 0;
      String testVendor = globalData.transactions[index].vendor;
      vendorCount = globalData.transactions.where((tx) => tx.vendor == testVendor).length;
      if (vendorCount > 1) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Category selected: ${category.name}"),
                content: Text("Would you like to change $vendorCount ${globalData.transactions[index]
                    .vendor} payments to this category?"),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Only this one"),
                    onPressed: () {
                      setState(() {
                        globalData.transactions[index].category = category.id;
                      });
                      dBProvider.updateTransaction(globalData.transactions[index]);
                      if (_appBarCategory.contains(APPBAR_UNCATEGORIZED)) {
                        globalData.transactions.removeAt(index);
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: Text("Change all of them"),
                    onPressed: () {
                      setState(() {
                        globalData.transactions.forEach((transaction) {
                          if (transaction.vendor == globalData.transactions[index].vendor) {
                            transaction.category = category.id;
                          }
                        });
                      });
                      dBProvider.updateAllVendorTransactions(globalData.transactions[index].vendor, category.id);
                      if (_appBarCategory.contains("uncategorized")) {
                        globalData.transactions.clear();
                        PaymentServices.copyTransactions(COPY_UNCATEGORIZED, 0, 0);
                      }
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            }
        );
      } else {
        setState(() {
          globalData.transactions[index].category = category.id;
        });
        dBProvider.updateTransaction(globalData.transactions[index]);
        if (_appBarCategory.contains(APPBAR_UNCATEGORIZED)) {
          globalData.transactions.removeAt(index);
        }
      }
    }
  }

  Widget categoryMenuButton(int index) {
    return PopupMenuButton<Category>(
      icon: Icon(CategoryServices.categoryIcon(
          globalData.transactions[index].category)),
        onSelected: (Category category) {
          _showUpdatePaymentsCategoryDialog(category, index);
        },
        itemBuilder: (BuildContext context) {
        return globalData.categories.map((Category category) {
          return PopupMenuItem<Category>(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Icon(CategoryServices.categoryIcon(category.id)),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(category.name),
                  ),
                ]
            ),
            value: category,
          );
        }).toList();
      });
  }

  @override
  void initState() {
    super.initState();
    _appBarPeriod = '';
    _appBarCategory = APPBAR_UNCATEGORIZED;
    currentFilter = COPY_UNCATEGORIZED;
    PaymentServices.copyTransactions(COPY_UNCATEGORIZED, 0, 0);
  }

}