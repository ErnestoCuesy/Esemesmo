import 'package:flutter/material.dart';
import 'payment_list_view.dart';
import 'category_list_view.dart';
import 'budget_view.dart';
import 'settings_view.dart';

class Home extends StatefulWidget {
  @override
  State createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  GlobalKey<ScaffoldState> scaffoldStateKey = GlobalKey();

  static List<Widget> _widgetList = [
    BudgetView(),
    PaymentListView(),
    CategoryListView(),
    SettingsView(),
  ];

  int index = 0;
  Widget _activeWidget = _widgetList[0];

  Widget buildAppBar() {
    return AppBar(
      title: Text("esemesmo"),
      elevation: 0.0,
      backgroundColor: Colors.pink[300],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldStateKey,
        backgroundColor: Colors.pink[100],
        body: SafeArea(child: _activeWidget),
        bottomNavigationBar: bottomNavigationBar());
  }

  bottomNavigationBar() {
    return BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.library_books), label: 'My Budget'),
          BottomNavigationBarItem(
              icon: Icon(Icons.payment), label: 'My Payments'),
          BottomNavigationBarItem(
              icon: Icon(Icons.category), label: 'Categories'),
          BottomNavigationBarItem(
              icon: Icon(Icons.forward_30), label: 'Cycle cut-off'),
        ],
        fixedColor: Colors.pink[500],
        currentIndex: index,
        type: BottomNavigationBarType.fixed,
        onTap: (tapIndex) {
          setState(() {
            index = tapIndex;
            _activeWidget = _widgetList[tapIndex];
          });
        });
  }

  @override
  void initState() {
    super.initState();
  }
}
