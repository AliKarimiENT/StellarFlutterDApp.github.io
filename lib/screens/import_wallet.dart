import 'package:flutter/material.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart' as stl;

import '../app_theme.dart';
import '../main.dart';
import '../widgets/custom_appbar.dart';
import 'home.dart';

class ImportWalletPage extends StatefulWidget {
  ImportWalletPage({Key? key, required this.keys, required this.accountId})
      : super(key: key);
  List<String> keys;
  late String accountId;

  @override
  State<ImportWalletPage> createState() => _ImportWalletPageState();
}

class _ImportWalletPageState extends State<ImportWalletPage> {
  List<String> insertedKeys = [];
  late List<bool> validationKeys;
  bool isChecking = false;
  bool validated = true;
  @override
  void initState() {
    insertedKeys = List.filled(widget.keys.length, '');
    validationKeys = List.filled(widget.keys.length, true);
    super.initState();
  }

  final _importFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
backgroundColor: themeProvider.isDarkMode
          ? AppTheme.darkBackgroundColor
          : Colors.white,      appBar: CustomAppBar(context, false, null),
      body: ConstrainedBox(
        constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                AppBar().preferredSize.height),
        child: Stack(
          children: [
            NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (notification) {
                notification.disallowIndicator();
                return false;
              },
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'Import keys',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                    ),
                    Form(
                      key: _importFormKey,
                      child: Container(
                        margin: const EdgeInsets.only(
                            left: 24, right: 24, bottom: 64),
                        padding: EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: Colors.grey.shade300, width: 2),
                        ),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: 3,
                                  mainAxisSpacing: 4,
                                  mainAxisExtent: 64),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 5),
                          itemCount: widget.keys.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) => TextFormField(
                            autocorrect: false,
                            maxLines: 1,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == "") {
                                return "Enter key";
                              } else {
                                if (validationKeys[index] == false) {
                                  return 'Invalid key';
                                }
                              }
                              return null;
                            },
                            autofocus: false,
                            decoration: InputDecoration(
                              helperText: ' ',
                              contentPadding: const EdgeInsets.all(8),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: AppTheme.primaryColor),
                                  borderRadius: BorderRadius.circular(8)),
                              labelText: 'key ${index + 1}',
                            ),

                            // decoration: const InputDecoration(
                            //     fillColor: Colors.white,
                            //     focusColor: Colors.white,
                            //     labelText: 'Selling amount'),
                            onChanged: (value) {
                              insertedKeys[index] = value.replaceAll(' ', '');
                            },
                            keyboardType: TextInputType.text,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: SizedBox(
                    width: double.maxFinite,
                    child: RawMaterialButton(
                      onPressed: () async {
                        setState(() {
                          validated = true;
                          isChecking = true;
                        });
                        for (var key in widget.keys) {
                          var index = widget.keys.indexOf(key);
                          if (key != insertedKeys[index]) {
                            validationKeys[index] = false;
                            validated = false;
                          } else {
                            validationKeys[index] = true;
                          }
                        }
                        if (validated) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => HomePage(widget.accountId),
                          ));
                        } else {
                          _importFormKey.currentState!.validate();
                        }
                        setState(() {
                          isChecking = false;
                        });
                      },
                      // hoverColor: Colors.blue,
                      elevation: 0,
                      fillColor: AppTheme.primaryColor,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          side: BorderSide(
                              color: AppTheme.primaryColor, width: 2)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(isChecking ? 'Checking' : 'Continue',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Colors.white)),
                          ),
                          isChecking
                              ? Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                  child: const CircularProgressIndicator(),
                                  width: 16,
                                  height: 16,
                                )
                              : Container()
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              bottom: 0,
              right: 0,
              left: 0,
            ),
          ],
        ),
      ),
    );
  }
}
