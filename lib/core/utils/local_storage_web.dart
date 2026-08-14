import 'dart:html' as html;

class WebLocalStorage {
  static void save(String key, String value) {
    try {
      html.window.localStorage[key] = value;
    } catch (e) {
      print('Failed to write to localStorage: $e');
    }
  }

  static String? load(String key) {
    try {
      return html.window.localStorage[key];
    } catch (e) {
      print('Failed to read from localStorage: $e');
      return null;
    }
  }
}
