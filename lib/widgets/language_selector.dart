import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whisper/globals.dart';

class LanguageSelector extends StatefulWidget {
  const LanguageSelector({super.key});

  @override
  LanguageSelectorState createState() => LanguageSelectorState();
}

class LanguageSelectorState extends State<LanguageSelector> {
  late SharedPreferences _prefs;

  // List of supported languages

  @override
  void initState() {
    super.initState();
    _getPrefs();
  }

  // Get SharedPreferences instance
  Future<void> _getPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage =
          _prefs.getString('selectedLanguage') ?? 'en'; // Default language code
    });
  }

  // Save selected language to SharedPreferences
  Future<void> _saveLanguage(String languageCode) async {
    await _prefs.setString('selectedLanguage', languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedLanguage,
      underline: const SizedBox.shrink(),
      onChanged: (newValue) {
        setState(() {
          selectedLanguage = newValue!;
          _saveLanguage(newValue);
        });
      },
      items: languages.map((language) {
        return DropdownMenuItem<String>(
          value: language['code']!,
          child: Text(
            language['name']!,
          ),
        );
      }).toList(),
    );
  }
}
