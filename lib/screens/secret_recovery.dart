import 'package:cupertino_stepper/cupertino_stepper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stellar_flutter_dapp/app_theme.dart';
import 'package:stellar_flutter_dapp/screens/home.dart';
import 'package:stellar_flutter_dapp/widgets/custom_appbar.dart';

import '../main.dart';

class SecretRecoveryPage extends StatefulWidget {
  SecretRecoveryPage(this.mnemonicKeys, this.accountId, {Key? key})
      : super(key: key);
  List<String> mnemonicKeys;
  String accountId;

  State<SecretRecoveryPage> createState() => _SecretRecoveryPageState();
}

class _SecretRecoveryPageState extends State<SecretRecoveryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(context, false, null),
     backgroundColor: themeProvider.isDarkMode
          ? AppTheme.darkBackgroundColor
          : Colors.white,
      body: SafeArea(
        child: ConstrainedBox(
          constraints:
              BoxConstraints(minHeight: MediaQuery.of(context).size.height),
          child: Stack(
            children: [
              Positioned(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: SizedBox(
                      width: double.maxFinite,
                      child: RawMaterialButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => HomePage(widget.accountId),
                          ));
                        },
                        // hoverColor: Colors.blue,
                        elevation: 0,
                        fillColor: AppTheme.primaryColor,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            side: BorderSide(
                                color: AppTheme.primaryColor, width: 2)),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Continue',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                ),
                bottom: 0,
                right: 0,
                left: 0,
              ),
              SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 0),
                      child: Center(
                        child: Text(
                          'Secret Recovery Phrase',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      child: Text(
                        'This is Secret Recovery Phrase.Write it down on a paper and keep it in a safe place.You will be asked to re-enter this phrase on the next step',
                        maxLines: 5,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                            color: Colors.grey.shade500),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: Colors.grey.shade300, width: 2),
                      ),
                      child: GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 0.5,
                          childAspectRatio: 3,
                          mainAxisSpacing: 1,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        itemCount: widget.mnemonicKeys.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) => Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppTheme.primaryColor, width: 2),
                          ),
                          child: Center(
                            child: Text(
                                '${index + 1}. ${widget.mnemonicKeys[index]}'),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                            ClipboardData(text: widget.mnemonicKeys.join(' ')));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text(
                              'Secret recovery words added to clipboard'),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(16),
                          backgroundColor: AppTheme.primaryColor,
                          duration: const Duration(milliseconds: 2000),
                        ));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Copy'),
                      ),
                    ),
                    SizedBox(
                      height: 75,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
