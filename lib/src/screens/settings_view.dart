import 'package:flutter/material.dart';
import '../resources/globals.dart';

class SettingsView extends StatefulWidget {
  @override
  SettingsViewState createState() => SettingsViewState();
}

class SettingsViewState extends State<SettingsView> {
  final formKey = GlobalKey<FormState>();
  final List<int> monthDays = List<int>.generate(31, (int i) => i + 1);
  double width;
  double maxCrossAxis;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    maxCrossAxis = width > 600.0 ? width / 7 : width / 5;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Choose cut off day",
            style: TextStyle(fontSize: 16.0),
          ),
        ),
        body: GridView.extent(
          maxCrossAxisExtent: maxCrossAxis,
          mainAxisSpacing: 6.0,
          crossAxisSpacing: 6.0,
          padding: const EdgeInsets.all(5.0),
          children: calendarMonth(monthDays.length),
        ));
  }

  List<Widget> calendarMonth(int days) {
    List<Container> containers = List<Container>.generate(days, (int index) {
      return Container(
        child: ElevatedButton(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(
                globalData.preferences.budgetCycleDay == (index + 1)
                    ? Colors.pink[100]
                    : Colors.green[100]),
          ),
          onPressed: () async {
            setState(() {
              updatePreferences(index + 1);
            });
          },
          child: Column(
            children: <Widget>[
              Text(
                "${monthDays[index]}",
                style: TextStyle(fontSize: 26.0),
              )
            ],
          ),
        ),
      );
    });
    return containers;
  }

  updatePreferences(int index) {
    globalData.preferences.budgetCycleDay = index;
    print("Preferences: ${globalData.preferences.toString()}");
    dBProvider.updatePreferencesCutoffday(index);
  }
}
