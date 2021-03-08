import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import '../resources/globals.dart';

class EmailServices {
  static void sendPayments() async {
    var externalStoragePermissionStatus = await Permission.storage.status;
    if (externalStoragePermissionStatus.isGranted) {
      writeCSV().then((file) {
        sendEmail(file);
      });
    } else {
      print("External storage access permission denied");
    }
  }

  static Future<String> writeCSV() async {
    String file;
    List<List<dynamic>> rows = [];
    for (int i = 0; i < globalData.transactions.length; i++) {
      List<dynamic> row = [];
      row.add(Utilities.formatDateTime(globalData.transactions[i].date));
      row.add(globalData.transactions[i].vendor);
      row.add(globalData.transactions[i].amount);
      row.add(globalData.categories[globalData.transactions[i].category].name);
      rows.add(row);
    }

    String dir = (await getExternalStorageDirectory()).absolute.path;
    file = "$dir" + "/Esemesmo.csv";
    print("Esemesmo FILE " + file);
    File f = File(file);
    String csv = const ListToCsvConverter().convert(rows);
    try {
      f.writeAsString(csv);
    } catch (e) {
      print(e.toString());
    }
    return file;
  }

  static Future<void> sendEmail(String file) async {
    final MailOptions mailOptions = MailOptions(
      body: 'Herewith attached, with love.',
      subject: 'Your Esemesmo credit card payments',
      recipients: ['${globalData.preferences.recipientEmailAddress}'],
      isHTML: true,
      attachments: [
        '$file',
      ],
    );

    await FlutterMailer.send(mailOptions).then((_) {
      print(
          "Email sent successfully to: ${globalData.preferences.recipientEmailAddress}");
    });
  }
}
