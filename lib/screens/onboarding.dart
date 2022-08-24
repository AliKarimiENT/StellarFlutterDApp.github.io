import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stellar_flutter_dapp/blocs/key%20generation/key_generation_cubit.dart';
import 'package:stellar_flutter_dapp/screens/setup_wallet.dart';

import '../app_theme.dart';
import '../widgets/custom_appbar.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({Key? key}) : super(key: key);

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  late KeyGenerationCubit _keyGenerationCubit;

  @override
  void initState() {
    super.initState();
    _keyGenerationCubit = KeyGenerationCubit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(),
      body: BlocProvider(
        create: (context) => _keyGenerationCubit,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height / 2,
                    margin: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: SvgPicture.asset(
                      'assets/welcome.svg',
                    ),
                  ),
                  const Text(
                    'Welcome to Stellar DApp',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
              child: SizedBox(
                width: double.maxFinite,
                child: RawMaterialButton(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  fillColor: AppTheme.primaryColor,
                  onPressed: () {
                    _keyGenerationCubit.generateKeys();
                  },
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Get started',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500),
                        ),
                        BlocConsumer<KeyGenerationCubit, KeyGenerationState>(
                            bloc: _keyGenerationCubit,
                            listener: (context, state) {
                              if (state is KeyGenerationDone) {
                                var mnemonicKeys = state.keys.mnemonic;
                                var accountId = state.keys.publicKey;
                                print('Key generated . . . ');
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      SetupWalletPage(mnemonicKeys, accountId),
                                ));
                              }
                            },
                            builder: (context, state) {
                              if (state is KeyGenerationLoading) {
                                return Container(
                                  margin: EdgeInsets.symmetric(horizontal: 8),
                                  child: const CircularProgressIndicator(),
                                  width: 16,
                                  height: 16,
                                );
                              }
                              return Container();
                            })
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
