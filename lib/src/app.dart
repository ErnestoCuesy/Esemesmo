import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sms/sms.dart';
import 'resources/globals.dart';
import 'screens/splash_screen.dart';
import 'screens/home.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  bool dbInitialized = false;
  double bottomPadding;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      _determinePermissions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "esemesmo",
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: dbInitialized ? Home() : SplashScreen(),
    );
  }

  _determinePermissions() async {
    var smsPermissionStatus = await Permission.sms.status;
    if (smsPermissionStatus.isGranted) {
      _initAndLoadDB();
    } else {
      if (await Permission.sms.request().isGranted) {
        _initAndLoadDB();
      } else {
        exit(0);
      }
    }
  }

  Future<bool> _initializeDB() async {
    print("Initializing DB from app");
    try {
      dBProvider.init();
      print("Finish Initializing DB from app");
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  _initAndLoadDB() {
    _initializeDB().then((dbFlag) {
      if (dbFlag) {
        Timer(Duration(seconds: 2), () {
          print("Timeout");
          PaymentServices.getTransactions().then((transactions) {
            CategoryServices.loadCategories().then((cats) {
              PreferencesServices.loadPreferences().then((pref) {
                setState(() {
                  globalData.transactionsMaster = transactions;
                  dbInitialized = dbFlag;
                  print(
                      "Transactions loaded: ${globalData.transactionsMaster.length}");
                  globalData.categories = cats;
                  print("Categories loaded: ${globalData.categories.length}");
                  globalData.preferences = pref;
                  print("Preferences loaded");
                });
              });
            });
          });
        });
        _listenForSMS();
      } else {
        print("Failed to init DB");
      }
    });
  }

  _listenForSMS() {
    var receiver = SmsReceiver();
    receiver.onSmsReceived.listen((SmsMessage sms) {
      Payment payment = PaymentServices.isTransaction(sms);
      if (payment != null) {
        int autoCategory = PaymentServices.getAutoCategory(
            globalData.transactionsMaster, payment.vendor);
        globalData.transactionsMaster.clear();
        PaymentServices.getTransactions().then((transactions) {
          setState(() {
            globalData.transactionsMaster = transactions;
            globalData.transactionsMaster[0].category = autoCategory;
            dBProvider.updateTransaction(globalData.transactionsMaster[0]);
          });
        });
      }
    });
  }
}
