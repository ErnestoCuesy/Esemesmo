import '../models/preferences.dart';
import '../models/category.dart';
import '../models/payment.dart';

export '../models/preferences.dart';
export '../models/category.dart';
export '../models/payment.dart';

export '../services/db_provider.dart';
export '../services/payment_services.dart';
export '../services/category_services.dart';
export '../services/preferences_services.dart';
export '../services/email_services.dart';

export 'utilities.dart';
export 'app_data.dart';

class GlobalData {
  List<Payment> transactionsMaster = [];
  List<Payment> transactions = [];
  List<String> yearMonthList = [];
  List<String> accountingYearMonthList = [];
  List<Category> categories = [];
  List<Category> categoryTotals = [];
  Preferences preferences = Preferences();
}

final globalData = GlobalData();
