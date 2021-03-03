import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'category_payment_list.dart';
import '../resources/globals.dart';

class BudgetView extends StatefulWidget {
  @override
  _BudgetViewState createState() => _BudgetViewState();
}

class _BudgetViewState extends State<BudgetView> {
  String _yearMonth = 'all periods';
  int _year = 99;
  int _month = 99;
  final f = NumberFormat.simpleCurrency(locale: "en_ZA");

  @override
  void initState() {
    super.initState();
    PaymentServices.copyTransactions(COPY_ALL, 0, 0);
    PaymentServices.buildAccountingYearMonthList(globalData.preferences.budgetCycleDay);
    CategoryServices.calculateCategoryTotals(99, 99);
    setState(() {
      print("Totals loaded");
    });
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
              _yearMonth = yearMonth;
            } else {
              _yearMonth = 'all periods';
              _year = 99;
              _month = 99;
            }
            CategoryServices.calculateCategoryTotals(_year, _month);
          });
        },
        itemBuilder: (BuildContext context) {
          return globalData.accountingYearMonthList.map((String ymItem) {
            return PopupMenuItem<String>(
              child: Text(ymItem),
              value: ymItem
            );
          }).toList();
        });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "My Budget Status for ($_yearMonth)",
        style: TextStyle(fontSize: 16.0),
        ),
        actions: <Widget>[yearMonthMenuButton()],
      ),
      body: GridView.extent(
        maxCrossAxisExtent: width > 600.0 ? width / 4 : width / 2,
        mainAxisSpacing: 5.0,
        crossAxisSpacing: 5.0,
        padding: const EdgeInsets.all(5.0),
        children: _buildGridTilesButton(globalData.categoryTotals.length),
      ),
    );
  }

  List<Widget> _buildGridTilesButton(int numberOfTiles) {
    List<Container> containers = List<Container>.generate(numberOfTiles, (int index) {
      return Container(
        child: RaisedButton(
          elevation: 8.0,
          color: CategoryServices.categoryRAG(globalData.categoryTotals[index].budgetAmount, globalData.categoryTotals[index].threshold, globalData.categoryTotals[index].transactionsTotal),
          onPressed: () async {
            var trans;
            if (_year == 99 && _month == 99) {
              trans = globalData.transactionsMaster.where((payment) {
                return (payment.category == globalData.categoryTotals[index].id);
              }).toList();
            } else {
              trans = globalData.transactionsMaster.where((payment) {
                return (payment.accountingYear == _year && payment.accountingMonth == _month && payment.category == globalData.categoryTotals[index].id);
              }).toList();
            }
            _popUpTransactionList(trans);
          },
          child: Column(
            children: <Widget>[
              categoryName(index),
              spentAmount(index),
              budgetAmount(index),
              minimumAmount(index),
              availableAmount(index)
            ],
          ),
        ),
      );
    });
    return containers;
  }

  _popUpTransactionList(List<Payment> transactions) {
    transactions.sort((a, b) => b.date.compareTo(a.date));
    Navigator.of(context).push(CategoryPaymentList(transactions: transactions));
  }

  categoryName(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom:18.0, top: 16.0),
      child: Column(
        children: <Widget>[
          Text(
            globalData.categoryTotals[index].name,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18.0
            ),
          ),
          Icon(CategoryServices.categoryIcon(globalData.categoryTotals[index].id))
        ]
      ),
    );
  }

  budgetAmount(int index) {
    if (globalData.categoryTotals[index].budgetAmount == 0) {
      return Container();
    } else {
      return Container(
        padding: EdgeInsets.only(left: 2.0, right: 2.0, top: 2.0, bottom: 2.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Budget: ",
              ),
              Text(
                "${f.format(globalData.categoryTotals[index].budgetAmount)}",
              ),
            ]
        ),
      );
    }
  }

  minimumAmount(int index) {
    if (globalData.categoryTotals[index].budgetAmount == 0) {
      return Container();
    } else {
      return Container(
        padding: EdgeInsets.only(left: 2.0, right: 2.0, top: 2.0, bottom: 2.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Alert: ",
              ),
              Text(
                "${f.format(globalData.categoryTotals[index].threshold)}",
              ),
            ]
        ),
      );
    }
  }

  spentAmount(int index) {
    return Container(
      padding: EdgeInsets.only(left: 2.0, right: 2.0, top: 2.0, bottom: 2.0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "Spent: ",
            ),
            Text(
              "${f.format(globalData.categoryTotals[index].transactionsTotal)}",
            ),
          ]
      ),
    );
  }

  availableAmount(int index) {
    if (globalData.categoryTotals[index].budgetAmount == 0) {
      return Container();
    } else {
      return Container(
        padding: EdgeInsets.only(left: 2.0, right: 2.0, top: 2.0, bottom: 2.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Avail: ",
              ),
              Text(
                "${f.format((globalData.categoryTotals[index].budgetAmount - globalData.categoryTotals[index].transactionsTotal))}",
              ),
            ]
        ),
      );
    }
  }
}