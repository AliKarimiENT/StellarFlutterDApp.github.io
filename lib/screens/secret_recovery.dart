import 'package:cupertino_stepper/cupertino_stepper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stellar_flutter_dapp/app_theme.dart';
import 'package:stellar_flutter_dapp/screens/home.dart';
import 'package:stellar_flutter_dapp/widgets/custom_appbar.dart';

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
      appBar: CustomAppBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Center(
                child: Text(
                  'Secret Recovery Phrase',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: GridView.builder(
                // physics: NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 0.5,
                  childAspectRatio: 3,
                  mainAxisSpacing: 1,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                itemCount: widget.mnemonicKeys.length,
                shrinkWrap: true,
                itemBuilder: (context, index) => Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryColor, width: 2),
                  ),
                  child: Center(
                    child: Text('${index + 1}. ${widget.mnemonicKeys[index]}'),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
            ),
          ],
        ),
      ),
    );
  }
}
