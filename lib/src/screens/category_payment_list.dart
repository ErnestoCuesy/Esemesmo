import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/payment.dart';
import '../resources/utilities.dart';

class CategoryPaymentList extends ModalRoute<void> {
  List<Payment> transactions = [];
  double width;

  CategoryPaymentList({this.transactions});

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.5);

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    // This makes sure that text and other content follows the material style
    return Material(
      type: MaterialType.transparency,
      // make sure that the overlay content is not cut off
      child: SafeArea(
        child: _buildOverlayContent(context),
      ),
    );
  }

  Widget _buildOverlayContent(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Center(
      child: Container(
        color: Colors.grey[50],
        height: width > 600.0 ? 700.0 : 500.0,
        width: width > 600.0 ? 550.0 : 330.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 400.0,
                width: width > 600.0 ? 550.0 : 450.0,
                child: _paymentsList()
            ),
            Padding(
              padding: EdgeInsets.only(top: width > 600.0 ? 210.0 : 16.0),
              child: FloatingActionButton(
                backgroundColor: Colors.pink[100],
                child: Icon(Icons.clear),
                onPressed: () => Navigator.pop(context),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _paymentsList() {
    final f = NumberFormat.simpleCurrency(locale: "en_ZA");
    return ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text("${transactions[index].vendor}"),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(Utilities.formatDateTime(transactions[index].date)),
            ),
            trailing: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(f.format(transactions[index].amount)),
            ),
          );
        });

  }

  @override
  Widget buildTransitions(
      BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    // You can add your own animations for the overlay content
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: child,
      ),
    );
  }
}
