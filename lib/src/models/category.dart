import 'package:meta/meta.dart';

class Category {
  final int id;
  final String name;
  final double budgetAmount;
  final double threshold;
  double transactionsTotal;

  Category({
    @required this.id,
    @required this.name,
    @required this.budgetAmount,
    @required this.threshold,
    @required this.transactionsTotal
  });

  @override
  String toString() {
    return "$id : $name : ${budgetAmount.toStringAsFixed(2)} : ${threshold.toStringAsFixed(2)} : ${transactionsTotal.toStringAsFixed(2)}";
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic> {
      "id": id,
      "name": name,
      "budgetAmount": budgetAmount,
      "threshold": threshold,
      "total": transactionsTotal
    };
  }

  Category.fromDB(Map<String, dynamic> parsedMap)
      : id = parsedMap['id'],
        name = parsedMap['name'],
        budgetAmount = parsedMap['budgetAmount'],
        threshold = parsedMap['threshold'],
        transactionsTotal = parsedMap['total'];

}
