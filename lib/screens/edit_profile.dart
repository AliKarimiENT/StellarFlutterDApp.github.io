import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stellar_flutter_sdk/src/responses/account_response.dart';

import 'package:stellar_flutter_dapp/blocs/info/info_cubit.dart';
import 'package:stellar_flutter_dapp/main.dart';
import 'package:stellar_flutter_dapp/screens/wallet.dart';
import 'package:stellar_flutter_dapp/widgets/custom_appbar.dart';

import '../app_theme.dart';

class EditProfilePage extends StatefulWidget {
  EditProfilePage({
    Key? key,
    required this.name,
    required this.email,
    required this.cubit,
    required this.account,
    required this.hasNameKey,
    required this.hasEmailKey,
  }) : super(key: key);
  late InfoCubit cubit;
  late AccountResponse account;
  late bool hasNameKey, hasEmailKey;
  String? email, name;
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String? name, stellarAddress, email;
  bool profileEdited = false;

  @override
  void initState() {
    super.initState();
    var account = widget.account;
    name = widget.name;
    email = widget.email;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(profileEdited);
        return true;
      },
      child: Scaffold(
        backgroundColor: themeProvider.isDarkMode
            ? AppTheme.darkBackgroundColor
            : Colors.white,
        appBar: CustomAppBar(context, true, profileEdited),
        body: BlocProvider(
          create: (context) => widget.cubit,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Form(
                      key: _formKey,
                      child: BlocBuilder<InfoCubit, InfoState>(
                        bloc: widget.cubit,
                        builder: (context, state) => Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: getColor(),
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              'Name  (optional)',
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: 14,
                                color: getColor(),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 16),
                              child: TextFormField(
                                maxLines: 1,
                                maxLength: 64,
                                autofocus: false,
                                controller: TextEditingController(text: name),
                                keyboardType: TextInputType.name,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: AppTheme.primaryColor),
                                      borderRadius: BorderRadius.circular(8)),
                                  // labelText: 'Name',
                                  hintText: 'Example: Aron Garcia',
                                  helperText:
                                      'To delete key and its value put this field empty',
                                ),
                                onChanged: (value) {
                                  name = value;
                                },
                              ),
                            ),

                            const Divider(height: 1),
                            const SizedBox(height: 16),
                            // Text(
                            //   'Stellar Address  (optional)',
                            //   style: TextStyle(
                            //     fontWeight: FontWeight.w300,
                            //     fontSize: 14,
                            //     color: getColor(),
                            //   ),
                            // ),
                            // Container(
                            //   margin: const EdgeInsets.symmetric(vertical: 16),
                            //   child: TextFormField(
                            //     maxLines: 1,
                            //     maxLength: 64,
                            //     validator: (value) {
                            //       if (value != '') {
                            //         if (value!.contains('*') == false) {
                            //           return 'Entered stellar address is not valid!';
                            //         }
                            //       }
                            //       return null;
                            //     },
                            //     autofocus: false,
                            //     decoration: InputDecoration(
                            //       border: OutlineInputBorder(
                            //           borderRadius: BorderRadius.circular(8)),
                            //       focusedBorder: OutlineInputBorder(
                            //           borderSide: const BorderSide(
                            //               color: AppTheme.primaryColor),
                            //           borderRadius: BorderRadius.circular(8)),
                            //       hintText: 'Example: aron*stellar.com',
                            //     ),
                            //     onChanged: (value) {
                            //       stellarAddress = value;
                            //     },
                            //   ),
                            // ),
                            // const Divider(height: 1),
                            // const SizedBox(height: 16),
                            Text(
                              'Email Address  (optional)',
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: 14,
                                color: getColor(),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 16),
                              child: TextFormField(
                                maxLines: 1,
                                maxLength: 64,
                                autofocus: false,
                                validator: (value) {
                                  if (value != '') {
                                    if (isValidEmail(value!) == false) {
                                      return 'Invalid email address';
                                    }
                                  }
                                  return null;
                                },
                                controller: TextEditingController(text: email),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: AppTheme.primaryColor),
                                      borderRadius: BorderRadius.circular(8)),
                                  // labelText: 'Name',
                                  hintText: 'Example: arongarcia@gmail.com',
                                  helperText:
                                      'To delete key and its value put this field empty',
                                ),
                                onChanged: (value) {
                                  email = value;
                                },
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  width: double.maxFinite,
                                  height: 45,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: RawMaterialButton(
                                    fillColor: AppTheme.primaryColor,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8),
                                      ),
                                    ),
                                    child: BlocConsumer<InfoCubit, InfoState>(
                                        bloc: widget.cubit,
                                        listener: (context, state) {
                                          if (state is EditedProfile) {
                                            setState(() {
                                              profileEdited = true;
                                              widget.email = email;
                                              widget.name = name;
                                            });
                                          }
                                        },
                                        builder: (context, state) {
                                          if (state is EditingProfile) {
                                            return Row(
                                              children: [
                                                const Text(
                                                  'Editing',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 16,
                                                      color: Colors.white),
                                                ),
                                                Container(
                                                  margin: const EdgeInsets
                                                      .symmetric(horizontal: 8),
                                                  child:
                                                      const CircularProgressIndicator(
                                                    color: Colors.white,
                                                  ),
                                                  width: 16,
                                                  height: 16,
                                                )
                                              ],
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                            );
                                          } else if (state is EditedProfile) {
                                            return Row(
                                              children: [
                                                const Text(
                                                  'Edited',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 16,
                                                      color: Colors.white),
                                                ),
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      left: 8,
                                                      right: 8,
                                                      bottom: 8),
                                                  child: const Icon(
                                                    Icons.check_circle_outline,
                                                    color: Colors.white,
                                                  ),
                                                  width: 16,
                                                  height: 16,
                                                )
                                              ],
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                            );
                                          }
                                          return const Text(
                                            'Edit',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500),
                                          );
                                        }),
                                    onPressed: () {
                                      if (name != null) {
                                        if (name != '') {
                                          name = name![name!.length - 1] == ' '
                                              ? name!.substring(
                                                  0, name!.length - 1)
                                              : name;
                                        } else {
                                          name = null;
                                        }
                                      }
                                      if (_formKey.currentState!.validate()) {
                                        // check that name and email has changed or not
                                        var emailChanged = email == widget.email
                                            ? false
                                            : true;
                                        var nameChanged =
                                            name == widget.name ? false : true;
                                        if (nameChanged || emailChanged) {
                                          widget.cubit.editProfile(
                                            name: name,
                                            address: stellarAddress,
                                            email: email,
                                            secretSeed: keys[activeAccountId],
                                            hasNameKeyValue: widget.hasNameKey,
                                            hasEmailKeyValue:
                                                widget.hasEmailKey,
                                            nameChanged: nameChanged,
                                            emailChanged: emailChanged,
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: const Text(
                                                  'Nothing has been changed',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16)),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              margin: const EdgeInsets.only(
                                                  left: 16,
                                                  right: 16,
                                                  bottom: 80),
                                              backgroundColor:
                                                  AppTheme.primaryColor,
                                              duration: const Duration(
                                                  milliseconds: 1000),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            if (state is EditingProfileFailed)
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 16, left: 8, right: 8),
                                child: Text(
                                  'An Error Accord\n${state.message.toString()}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: AppTheme.red),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color getColor() {
    return themeProvider.isDarkMode
        ? Colors.white.withOpacity(0.80)
        : Colors.black.withOpacity(0.80);
  }

  bool isValidEmail(String value) {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(value);
  }
}
