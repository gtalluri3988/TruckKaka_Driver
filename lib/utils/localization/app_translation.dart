import 'language_json/en_us.dart';
import 'language_json/hi_in.dart';
import 'language_json/te_in.dart';

class AppTranslation {
  static Map<String, Map<String, String>> get translationsKeys => {
        'en_US': enUS,
        'hi_IN': hiIN,
        'te_IN': teIN,
      };
}
