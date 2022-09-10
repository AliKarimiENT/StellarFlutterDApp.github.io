import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stellar_flutter_dapp/app_theme.dart';
import 'package:stellar_flutter_dapp/screens/import_wallet.dart';
import 'package:stellar_flutter_dapp/screens/secret_recovery.dart';

import '../widgets/custom_appbar.dart';

class SetupWalletPage extends StatelessWidget {
  SetupWalletPage(this.mnemonicKeys, this.accountId, {Key? key})
      : super(key: key);
  List<String> mnemonicKeys;
  String accountId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(context, false, null),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Expanded(
            flex: 3,
            child: Container(
              margin: EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: SvgPicture.asset(
                'assets/setup.svg',
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'Set Up your Wallet',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Import an existing wallet or create a new one',
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                        color: Colors.grey.shade500),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.maxFinite,
                    child: RawMaterialButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              ImportWalletPage(keys: mnemonicKeys,accountId: accountId,),
                        ));
                      },
                      // hoverColor: Colors.blue,
                      elevation: 0,
                      fillColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          side: BorderSide(
                              color: AppTheme.primaryColor, width: 2)),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Import using Secret Recovery Phrase',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: AppTheme.primaryColor)),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 24, right: 24, top: 8, bottom: 16),
                  child: SizedBox(
                    width: double.maxFinite,
                    child: RawMaterialButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              SecretRecoveryPage(mnemonicKeys, accountId),
                        ));
                      },
                      // hoverColor: Colors.blue,
                      elevation: 0,
                      fillColor: AppTheme.primaryColor,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Create New Wallet',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Colors.white)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
            child: RichText(
              text: TextSpan(children: <TextSpan>[
                TextSpan(
                  text: 'By proceeding, you agree to these ',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
                const TextSpan(
                  text: 'Terms and Conditions',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    decoration: TextDecoration.underline,
                    fontSize: 12,
                  ),
                ),
              ]),
            ),
          )
        ],
      ),
    );
  }
}
