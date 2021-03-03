import '../resources/globals.dart';

class PreferencesServices {

  static Future<Preferences> loadPreferences() async {
    Preferences preferences;
    // Load preferences
    try {
      await dBProvider.fetchPreferences().then((pref) {
        preferences = pref;
      });
    } catch (e){
      print(e.toString());
    }
    print("Preferences: ${preferences.toString()}");
    return preferences;
  }

}