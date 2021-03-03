import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../resources/globals.dart';

class CategoryServices {

  static IconData categoryIcon(int index) {
    IconData icon;
    switch (index) {
      case 0:
        icon = FontAwesomeIcons.questionCircle;
        break;
      case 1:
        icon = FontAwesomeIcons.shoppingCart;
        break;
      case 2:
        icon = FontAwesomeIcons.utensils;
        break;
      case 3:
        icon = FontAwesomeIcons.car;
        break;
      case 4:
        icon = FontAwesomeIcons.gasPump;
        break;
      case 5:
        icon = FontAwesomeIcons.planeDeparture;
        break;
      case 6:
        icon = FontAwesomeIcons.dog;
        break;
      case 7:
        icon = FontAwesomeIcons.moneyBill;
        break;
      case 8:
        icon = FontAwesomeIcons.theaterMasks;
        break;
      case 9:
        icon = FontAwesomeIcons.tshirt;
        break;
      case 10:
        icon = FontAwesomeIcons.userNurse;
        break;
      case 11:
        icon = FontAwesomeIcons.home;
        break;
      case 12:
        icon = FontAwesomeIcons.gift;
        break;
      default:
        icon = FontAwesomeIcons.user;
    }
    return icon;
  }

  static Color categoryRAG(double budget, double threshold, double used) {
    Color color;
    if (budget == 0) {
      return Colors.transparent;
    } else {
      if (budget - used != 0) {
        if (budget - used > threshold) {
          color = Colors.green[100];
        } else if (budget - used <= 0) {
          color = Colors.red[200];
        } else if (budget - used <= threshold) {
          color = Colors.orange[300];
        }
      }
    }
    return color;
  }

  static Future<List<Category>> loadCategories() async {
    List<Category> categories;
    // Load categories
    try {
      await dBProvider.fetchAllCategories().then((cats) {
          categories = cats;
      });
    } catch (e) {
      print(e.toString());
    }
    return categories;
  }

  static calculateCategoryTotals(int year, int month) {
    globalData.categoryTotals.clear();
    globalData.transactionsMaster.forEach((payment) {
      if (!payment.excludeFlag) {
        if (year == 99 && month == 99) {
          _updateCategoryTotals(payment);
        } else {
          if (payment.accountingYear == year && payment.accountingMonth == month) {
            _updateCategoryTotals(payment);
          }
        }
      }
    });
  }

  static _updateCategoryTotals(Payment payment) {
    int index = globalData.categoryTotals.indexWhere((Category category) {
      return category.id == payment.category;
    });
    if (index >= 0) {
      globalData.categoryTotals[index].transactionsTotal += payment.amount;
    } else {
      int catIndex = globalData.categories.indexWhere((Category category) {
        return category.id == payment.category;
      });
      int id = globalData.categories[catIndex].id;
      String name = globalData.categories[catIndex].name;
      double budgetAmount = globalData.categories[catIndex].budgetAmount;
      double threshold = globalData.categories[catIndex].threshold;
      double transactionsTotal = payment.amount;
      globalData.categoryTotals.add(Category(id: id,
          name: name,
          budgetAmount: budgetAmount,
          threshold: threshold,
          transactionsTotal: transactionsTotal));
    }
  }

  static deleteCategoryTotal(int categoryId) {
    int index = globalData.categoryTotals.indexWhere((Category category) {
      return category.id == categoryId;
    });
    if (index >= 0) {
      globalData.categoryTotals.removeAt(index);
    }
  }
}

