class Utilities {

  static String formatDateTime(int date) {
    String dateTimeIn = DateTime.fromMillisecondsSinceEpoch(date).toString();
    List<String> splitTime = dateTimeIn.split('.');
    return splitTime[0];
  }

}
