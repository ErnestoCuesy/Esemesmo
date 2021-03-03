class Preferences{
  int budgetCycleDay;
  String recipientEmailAddress;

  Preferences({
    this.budgetCycleDay,
    this.recipientEmailAddress
  });

  @override
  String toString() {
    return "$budgetCycleDay : $recipientEmailAddress";
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic> {
      "budgetCycleDay": budgetCycleDay,
      "recipientEmailAddress": recipientEmailAddress,
    };
  }

  Preferences.fromDB(Map<String, dynamic> parsedMap)
      : budgetCycleDay = parsedMap['budgetCycleDay'],
        recipientEmailAddress = parsedMap['recipientEmailAddress'];

}