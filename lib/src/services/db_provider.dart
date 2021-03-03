import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'dart:async';
import '../resources/globals.dart';

class DBProvider {
  Database db;

  DBProvider() {
    // init();
  }

  void init() async {
    print("Attempting to open/create DB");
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, "esemesmoDB.db");
    db = await openDatabase(
        path,
        version: 1,
        onCreate: (Database newDb, int version){
          newDb.execute("""
              CREATE TABLE Transactions
                (
                  id INTEGER PRIMARY KEY,
                  bank INTEGER,
                  year INTEGER,
                  month INTEGER,
                  day INTEGER,
                  accountingYear INTEGER,
                  accountingMonth INTEGER,
                  vendor TEXT,
                  amount REAL,
                  category INTEGER,
                  excludeFlag INTEGER,
                  manualEntry INTEGER
                )
              """);
          newDb.execute("""
              CREATE TABLE Categories
                (
                  id INTEGER PRIMARY KEY,
                  name TEXT,
                  budgetAmount REAL,
                  threshold REAL,
                  total REAL
                )
              """);
          newDb.execute("""
              INSERT INTO Categories VALUES
                (0, 'Uncategorized', 0.0, 0.0, 0.0)
              """);
          newDb.execute("""
              INSERT INTO Categories VALUES
                (1, 'Groceries', 0.0, 0.0, 0.0)
              """);
          newDb.execute("""
              INSERT INTO Categories VALUES
                (2, 'Restaurants', 0.0, 0.0, 0.0)
              """);
          newDb.execute("""
              INSERT INTO Categories VALUES
                (3, 'Car', 0.0, 0.0, 0.0)
              """);
          newDb.execute("""
              INSERT INTO Categories VALUES
                (4, 'Fuel', 0.0, 0.0, 0.0)
              """);
          newDb.execute("""
              INSERT INTO Categories VALUES
                (5, 'Travel', 0.0, 0.0, 0.0)
              """);
          newDb.execute("""
              INSERT INTO Categories VALUES
                (6, 'Pets', 0.0, 0.0, 0.0)
              """);
          newDb.execute("""
              INSERT INTO Categories VALUES
                (7, 'ATM', 0.0, 0.0, 0.0)
              """);
          newDb.execute("""
              INSERT INTO Categories VALUES
                (8, 'Entertainment', 0.0, 0.0, 0.0)
              """);
          newDb.execute("""
              INSERT INTO Categories VALUES
                (9, 'Clothes', 0.0, 0.0, 0.0)
              """);
          newDb.execute("""
              INSERT INTO Categories VALUES
                (10, 'Medical', 0.0, 0.0, 0.0)
              """);
          newDb.execute("""
              INSERT INTO Categories VALUES
                (11, 'Home', 0.0, 0.0, 0.0)
              """);
          newDb.execute("""
              INSERT INTO Categories VALUES
                (12, 'Gifts', 0.0, 0.0, 0.0)
              """);
          newDb.execute("""
              CREATE TABLE Preferences
                (
                  budgetCycleDay INTEGER,
                  recipientEmailAddress TEXT
                )
              """);
          newDb.execute("""
              INSERT INTO Preferences VALUES
                (24, '')
              """);
        });
    print("Finished DB init");
  }

  Future<Preferences> fetchPreferences() async {
    Preferences preferences;
    final maps = await db.rawQuery("SELECT * FROM Preferences");

    if (maps.length > 0) {
      maps.forEach((preference) {
        preferences = Preferences.fromDB(preference);
      });
    }
    return preferences;
  }

  Future<List<Category>> fetchAllCategories() async {
    List<Category> categories = [];
    final maps = await db.query("Categories");

    if (maps.length > 0) {
      maps.forEach((category) {
        categories.add(Category.fromDB(category));
      });
      categories.sort((a, b) => a.id.compareTo(b.id));
      return categories;
    }
    categories.add(Category(id: 0, name: 'No categories found', budgetAmount: 0.0, threshold: 0.0, transactionsTotal: 0.0));
    return categories;
  }

  Future<List<Payment>> fetchAllTransactions() async {
    List<Payment> transactions = [];
    final maps = await db.rawQuery(
      "SELECT * FROM Transactions T ORDER BY T.id DESC",
    );

    if (maps.length > 0) {
      maps.forEach((transaction) {
        transactions.add(Payment.fromDB(transaction));
      });
      return transactions;
    }

    return null;
  }

  Future<int> addTransaction(Payment transaction) {
    return db.insert(
        "Transactions",
        transaction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore
    );
  }

  Future<int> addCategory(Category category) {
    return db.insert(
        "Categories",
        category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  Future<int> updateTransaction(Payment transaction) {
    return db.insert(
        "Transactions",
        transaction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  updateAllVendorTransactions(String vendor, int newCategory) async {
    return db.rawQuery(
      "UPDATE Transactions SET category = ? WHERE vendor = ?", [newCategory, vendor]
    );
  }

  updatePreferencesCutoffday(int newCutoffday) async {
    return db.rawQuery(
        "UPDATE Preferences SET budgetCycleDay = ?", [newCutoffday]
    );
  }

  updatePreferencesEmailAddress(String newRecipientEmailAddress) async {
    return db.rawQuery(
        "UPDATE Preferences SET recipientEmailAddress = ?", [newRecipientEmailAddress]
    );
  }

  deleteCategory(int category) async {
    return db.rawQuery(
        "DELETE FROM Categories WHERE id = ?", [category]
    );
  }

  updateAllCategoryTransactions(int newCategory, int oldCategory) async {
    return db.rawQuery(
        "UPDATE Transactions SET category = ? WHERE category = ?", [newCategory, oldCategory]
    );
  }

  Future<int> clear() {
    return db.delete("Transactions");
  }

}

final dBProvider = DBProvider();
