import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stellar_flutter_dapp/screens/home.dart';
import 'package:stellar_flutter_dapp/screens/onboarding.dart';

late SharedPreferences pref;
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
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Onboarding(),
      // home: keyGenerated ? HomePage(accountId) : Onboarding(),
    );
  }

  Future<void> loadUserData() async {
    String? mnemonicWords = pref.getString('mnemonic');
    if (mnemonicWords != null) {
      keyGenerated = true;
    } else {
      keyGenerated = false;
    }

    accountId = pref.getString('accountId')!;
  }
}
