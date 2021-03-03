import 'package:sms/sms.dart';
import '../resources/globals.dart';

class PaymentServices {

  static Future<List<SmsMessage>> getInboxMessages() async {
    List<SmsMessage> smsList;
    SmsQuery query = SmsQuery();
    try {
      smsList = await query.querySms(kinds: [SmsQueryKind.Inbox]);
    } catch (e) {
      print(e.toString());
    }
    return smsList;
  }

  static Future<List<Payment>> getTransactions() async {
    List<Payment> transactions = [];
    await dBProvider.fetchAllTransactions().then((dBtransactions) {
      if (dBtransactions != null) {
        transactions = dBtransactions;
      }
    });
    // Get transactions from inbox anyway to check for new ones
    await getSMSTransactions().then((smsTransactions) {
      if (smsTransactions != null) {
        smsTransactions.forEach((smsTransaction) {
          // Checking for duplication, adding to transaction list and persisiting in DB
          bool inDB = false;
          transactions.forEach((t) {
            if (t.date == smsTransaction.date) {
              inDB = true;
            }
          });
          if (!inDB) {
            // Not in DB. Try to auto categorize and then persist in DB and add to list
            int autoCategory = getAutoCategory(transactions, smsTransaction.vendor);
            smsTransaction.category = autoCategory;
            dBProvider.addTransaction(smsTransaction);
            transactions.add(smsTransaction);
          }
        });
      }
    });
    transactions.sort((a,b) => b.date.compareTo(a.date));
    return transactions;
  }

  static Future<List<Payment>> getSMSTransactions() async {
    List<Payment> transactions = [];
    await getInboxMessages().then((messages) {
      for (SmsMessage message in messages) {
        Payment smsTransaction = isTransaction(message);
        if (smsTransaction != null) {
          transactions.add(smsTransaction);
        }
      }
    });
    return transactions;
  }

  static Payment isTransaction(SmsMessage message){
    // This method will try to determine if the string passed is a bank transaction or not
    // Regular expression to identify the different financial institutions are documented in app_data.dart
    var group1;
    var group2;
    var amount;
    int accYear = 0;
    int accMonth = 0;
    String vendor;
    int bank = 0;
    bool done = false;
    Iterable<Match> matchResult;
    while (!done) {
      if (bank < bankPatternsArray.length) {
        RegExp returnMatchPattern = RegExp('${bankPatternsArray[bank]}');
        Iterable<Match> matches = returnMatchPattern.allMatches(message.body);
        if (matches.length > 0) {
          matchResult = matches;
          done = true;
        } else {
          bank++;
        }
      } else {
        done = true;
      }
    }

    if (matchResult == null) {
      return null;
    }

    if (matchResult.length > 0) {
      for (Match m in matchResult) {
        group1 = m.group(1);
        group2 = bank == FNBREV ? null : m.group(2);
      }
      switch (bank) {
        case FNB:
        case NEDBANK:
        case CAPITEC:
        case SBSA:
        case DISC:
          amount = double.parse(group1);
          vendor = group2;
          break;
        case ABSA:
        case ABSA:
        case ABSAWTH:
        case WFS:
        case VMCC:
          amount = double.parse(group2);
          vendor = group1;
          break;
        case FNBREV:
          amount = double.parse(group1) * -1;
          vendor = 'Reversal';
          break;
      }

      vendor = vendor.substring(0, vendor.length > 30 ? 30 : vendor.length);
      accYear = message.date.year;
      accMonth = message.date.month;

      return Payment(
          date: message.date.millisecondsSinceEpoch,
          bank: bank,
          year: message.date.year,
          month: message.date.month,
          day: message.date.day,
          accountingYear: accYear,
          accountingMonth: accMonth,
          vendor: vendor,
          amount: amount,
          category: 0,
          excludeFlag: false,
          manualEntry: false
      );
    } else {
      return null;
    }
  }

  static copyTransactions(int command, int year, int month) {
    // Copy transactions from master array
    if (globalData.transactionsMaster.length > 0) {
      globalData.transactions.clear();
      switch (command) {
        case COPY_ALL:
          if (year == 0 && month == 0) {
            globalData.transactionsMaster.forEach((transaction) {
              if (!transaction.excludeFlag) {
                globalData.transactions.add(transaction);
              }
            });
          } else {
            globalData.transactionsMaster.forEach((transaction) {
              if (!transaction.excludeFlag && transaction.year == year && transaction.month == month) {
                globalData.transactions.add(transaction);
              }
            });
          }
          break;
        case COPY_CATEGORIZED:
          if (year == 0 && month == 0) {
            globalData.transactionsMaster.forEach((transaction) {
              if (transaction.category != 0 && !transaction.excludeFlag) {
                globalData.transactions.add(transaction);
              }
            });
          } else {
            globalData.transactionsMaster.forEach((transaction) {
              if (transaction.category != 0 && !transaction.excludeFlag && transaction.year == year && transaction.month == month) {
                globalData.transactions.add(transaction);
              }
            });
          }
          break;
        case COPY_UNCATEGORIZED:
          if (year == 0 && month == 0) {
            globalData.transactionsMaster.forEach((transaction) {
              if (transaction.category == 0 && !transaction.excludeFlag) {
                globalData.transactions.add(transaction);
              }
            });
          } else {
            globalData.transactionsMaster.forEach((transaction) {
              if (transaction.category == 0 && !transaction.excludeFlag && transaction.year == year && transaction.month == month) {
                globalData.transactions.add(transaction);
              }
            });
          }
          break;
        case COPY_EXCLUDED:
          if (year == 0 && month == 0) {
            globalData.transactionsMaster.forEach((transaction) {
              if (transaction.excludeFlag) {
                globalData.transactions.add(transaction);
              }
            });
          } else {
            globalData.transactionsMaster.forEach((transaction) {
              if (transaction.excludeFlag && transaction.year == year && transaction.month == month) {
                globalData.transactions.add(transaction);
              }
            });
          }
          break;
        case COPY_YEAR_MONTH:
          globalData.transactionsMaster.forEach((transaction) {
            if (transaction.year == year && transaction.month == month && !transaction.excludeFlag) {
              globalData.transactions.add(transaction);
            }
          });
          break;
      }
      _buildYearMonthList();
      print("Transactions in list for $year/$month: ${globalData.transactions.length}");
    }
  }

  static _buildYearMonthList() {
    Map<String, int> periodsMap = {};
    globalData.transactions.forEach((transaction) {
      var fill = transaction.month > 9 ? '' : '0';
      var yearMonth = transaction.year.toString() + '/' + fill + transaction.month.toString();
      if (periodsMap.containsKey(yearMonth)) {
        periodsMap.update(yearMonth, (int counter) => ++counter);
      } else {
        periodsMap.putIfAbsent(yearMonth, () => 1);
      }
    });
    globalData.yearMonthList.clear();
    globalData.yearMonthList = periodsMap.keys.toList();
    globalData.yearMonthList.sort((a, b) => b.compareTo(a));
    globalData.yearMonthList.insert(0, 'All Payments');
  }

  static buildAccountingYearMonthList(int cutoffDay) {
    Map<String, int> periodsMap = {};
    globalData.transactions.forEach((transaction) {
      if (!transaction.excludeFlag) {
        transaction.accountingYear = transaction.year;
        transaction.accountingMonth = transaction.month;
        if (transaction.day >= cutoffDay) {
          if (transaction.month < 12) {
            transaction.accountingMonth++;
          } else {
            transaction.accountingYear++;
            transaction.accountingMonth = 1;
          }
        }
        var fill = transaction.accountingMonth > 9 ? '' : '0';
        var yearMonth = transaction.accountingYear.toString() + '/' + fill + transaction.accountingMonth.toString();
        if (periodsMap.containsKey(yearMonth)) {
          periodsMap.update(yearMonth, (int counter) => ++counter);
        } else {
          periodsMap.putIfAbsent(yearMonth, () => 1);
        }
      }
    });
    globalData.accountingYearMonthList.clear();
    globalData.accountingYearMonthList = periodsMap.keys.toList();
    globalData.accountingYearMonthList.sort((a, b) => b.compareTo(a));
    globalData.accountingYearMonthList.insert(0, 'All Periods');
  }

  static int getAutoCategory(List<Payment> trans, String vendor) {
    int autoCategory = 0;
    if (trans.length > 0) {
      try {
        Payment instance = trans.firstWhere((tx) => tx.vendor == vendor && !tx.excludeFlag, orElse: null);
        if (instance != null) {
          autoCategory = instance.category;
        }
      } catch (e) {
        print(e.toString());
      }
    }
    return autoCategory;
  }

}

