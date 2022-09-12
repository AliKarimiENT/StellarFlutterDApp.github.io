import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:stellar_flutter_dapp/app_theme.dart';
import 'package:stellar_flutter_dapp/blocs/info/info_cubit.dart';
import 'package:stellar_flutter_dapp/main.dart';
import 'package:stellar_flutter_dapp/screens/edit_profile.dart';
import 'package:stellar_flutter_dapp/screens/wallet.dart';

import '../widgets/custom_appbar.dart';
import 'package:stellar_flutter_sdk/src/responses/account_response.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late InfoCubit _infoCubit;
  late AccountResponse account;
  late int index;
  AccountResponseData? data;
  @override
  void initState() {
    super.initState();
    _infoCubit = InfoCubit();
    _infoCubit.getBasicAccountInfo(activeAccountId);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    String? name, email;
    bool hasNameKey = false, hasEmailKey = false;
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode
          ? AppTheme.darkBackgroundColor
          : Colors.white,
      appBar: CustomAppBar(context, false, null),
      body: BlocProvider(
        create: (context) => _infoCubit,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BlocConsumer<InfoCubit, InfoState>(listener: (context, state) {
                if (state is AccountInfoLoaded) {
                  setState(() {
                    account = state.account;
                    var keysList = keys.keys.toList();
                    index = keysList.indexOf(activeAccountId);
                    data = account.data;
                  });
                }
              }, builder: (context, state) {
                if (state is AccountInfoLoaded) {
                  if (data != null && data!.length != 0) {
                    for (var key in data!.keys) {
                      Uint8List resultBytes = data!.getDecoded(key);
                      if (key == 'name') {
                        name = String.fromCharCodes(resultBytes);
                        hasNameKey = true;
                      } else if (key == 'email') {
                        email = String.fromCharCodes(resultBytes);
                        hasEmailKey = true;
                      }
                    }
                  }
                  return Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryColor,
                        ),
                        child: CircleAvatar(
                          foregroundColor: Colors.white,
                          radius: 24,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.network(
                              images.values.toList()[index],
                            ),
                          ),
                        ),
                      ),
                      name != null
                          ? Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                name!,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.w500),
                              ),
                            )
                          : Container(),
                      email != null
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                email!,
                                style: TextStyle(
                                    color: themeProvider.isDarkMode
                                        ? Colors.grey.shade200
                                        : Colors.grey.shade500),
                              ),
                            )
                          : Container(),
                      userAccountIdView(account),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RawMaterialButton(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(25),
                            ),
                          ),
                          fillColor: AppTheme.primaryColor,
                          child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, top: 8, right: 8, bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    'Edit Profile',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Icon(
                                      Icons.chevron_right_rounded,
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              )),
                          onPressed: () {
                            Navigator.of(context)
                                .push(
                              MaterialPageRoute(
                                builder: (context) => EditProfilePage(
                                    name: name,
                                    email: email,
                                    cubit: _infoCubit,
                                    account: account,
                                    hasNameKey: hasNameKey,
                                    hasEmailKey: hasEmailKey),
                              ),
                            )
                                .then((value) {
                              if (value) {
                                _infoCubit.getBasicAccountInfo(activeAccountId);
                              }
                            });
                          },
                        ),
                      )
                    ],
                  );
                }
                return Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(8),
                          width: 24,
                          height: 24,
                          child: const CircularProgressIndicator(
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const Text(
                          'Loading Account Info',
                        ),
                      ],
                    ),
                  ),
                );
              }),
              Padding(
                padding: const EdgeInsets.only(bottom: 65),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      margin: EdgeInsets.only(right: 8),
                      child: SvgPicture.asset(
                        'assets/svgs/moon.svg',
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    const Text('Dark Theme'),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: CupertinoSwitch(
                          value: themeProvider.isDarkMode,
                          activeColor: AppTheme.green,
                          onChanged: (value) async {
                            final provider = Provider.of<ThemeProvider>(context,
                                listen: false);
                            provider.toggleTheme(value);
                            await pref.setBool('darkTheme', value);
                          },
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Container userAccountIdView(AccountResponse account) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: const BorderRadius.all(Radius.circular(25))),
      child: RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: account.accountId.substring(0, 15),
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
            TextSpan(
              text: '...',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
            TextSpan(
              text: account.accountId.substring(
                  account.accountId.length - 15, account.accountId.length),
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
