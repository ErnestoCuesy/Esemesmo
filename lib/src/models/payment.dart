import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class Payment {
  final int date;
  final int bank;
  final int year;
  final int month;
  final int day;
  int accountingYear;
  int accountingMonth;
  final String vendor;
  final double amount;
  int category;
  bool excludeFlag;
  bool manualEntry;

  Payment({
    @required this.date,
    @required this.bank,
    @required this.year,
    @required this.month,
    @required this.day,
    @required this.accountingYear,
    @required this.accountingMonth,
    @required this.vendor,
    @required this.amount,
    @required this.category,
    @required this.excludeFlag,
    @required this.manualEntry
  });

  @override
  String toString() {
    return "-> $date : $bank : $year : $month : $day : $accountingYear : $accountingMonth : $vendor : $category : ${amount.toStringAsFixed(2)} : $excludeFlag : $manualEntry";
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic> {
      "id": date,
      "bank": bank,
      "year": year,
      "month": month,
      "day": day,
      "accountingYear": accountingYear,
      "accountingMonth": accountingMonth,
      "vendor": vendor,
      "amount": amount,
      "category": category,
      "excludeFlag": excludeFlag ? 1 : 0,
      "manualEntry": manualEntry ? 1 : 0
    };
  }

  Payment.fromDB(Map<String, dynamic> parsedMap)
    : date = parsedMap['id'],
      bank = parsedMap['bank'],
      year = parsedMap['year'],
      month = parsedMap['month'],
      day = parsedMap['day'],
      accountingYear = parsedMap['accountingYear'],
      accountingMonth = parsedMap['accountingMonth'],
      vendor = parsedMap['vendor'],
      amount = parsedMap['amount'],
      category = parsedMap['category'],
      excludeFlag = parsedMap['excludeFlag'] == 1,
      manualEntry = parsedMap['manualEntry'] == 1;

}
