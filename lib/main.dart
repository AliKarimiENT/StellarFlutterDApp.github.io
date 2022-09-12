import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stellar_flutter_dapp/app_theme.dart';
import 'package:stellar_flutter_dapp/screens/home.dart';
import 'package:stellar_flutter_dapp/screens/onboarding.dart';

late SharedPreferences pref;
late ThemeProvider themeProvider;
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.getInstance().then((value) {
    pref = value;
    runApp(MyApp());
  });
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool keyGenerated;
  late String accountId;
  @override
  void initState() {
    loadUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      builder: (context, _) {
        themeProvider = Provider.of<ThemeProvider>(context);
        var isDarkTheme = pref.getBool('darkTheme');
        if (isDarkTheme != null) {
          themeProvider.setTheme(isDarkTheme);
        }
        return MaterialApp(
          title: 'Flutter Demo',
          themeMode: themeProvider.themeMode,
          darkTheme: AppTheme.darkTheme,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: keyGenerated ? HomePage(accountId) : Onboarding(),
        );
      },
    );
  }

  Future<void> loadUserData() async {
    String? mnemonicWords = pref.getString('mnemonic');
    if (mnemonicWords != null) {
      keyGenerated = true;
    } else {
      keyGenerated = false;
    }
    if (pref.getString('accountId') != null) {
      accountId = pref.getString('accountId')!;
    }
  }
}
