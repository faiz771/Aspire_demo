import 'package:aspire/helper/app_common.dart';
import 'package:aspire/helper/app_text_field.dart';
import 'package:aspire/helper/color.dart';
import 'package:aspire/screen/dashboard.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpScreen extends StatelessWidget {
  final bool socialLogin;
  final String? userName;
  final bool isOtp;
  final String? countryCode;
  final String? privacyPolicyUrl;
  final String? termsConditionUrl;

  SignUpScreen({
    this.socialLogin = false,
    this.userName,
    this.isOtp = false,
    this.countryCode,
    this.privacyPolicyUrl,
    this.termsConditionUrl,
  });

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController firstController = TextEditingController();
  final TextEditingController lastController = TextEditingController();
  final TextEditingController repassController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController userController = TextEditingController();

  final FocusNode emailFocus = FocusNode();
  final FocusNode passFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  ClipRRect(
                    borderRadius: radius(50),
                    child: Image.asset("assets/logo.jpeg", width: 100, height: 100),
                  ),
                  Text("Create Account", style: boldTextStyle(size: 22)),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: 'Sign up to get started ',
                            style:   TextStyle(
                                color: Colors.blue,
                                fontSize: 14
                              ),),
                        TextSpan(text: '🚗', style: primaryTextStyle(size: 20)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 42),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: firstController,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'First Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "This field is required";
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: TextFormField(
                          controller: lastController,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'Last Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "This field is required";
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  if (!socialLogin) const SizedBox(height: 20),
                  if (!socialLogin)
                    TextFormField(
                      controller: userController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'User Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "This field is required";
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: emailController,
                    focusNode: emailFocus,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "This field is required";
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return "Enter a valid email address";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                       Expanded(
                         child: TextFormField(
                                             controller: passController,
                                             textInputAction: TextInputAction.next,
                                             keyboardType: TextInputType.visiblePassword,
                                             decoration: InputDecoration(
                                               labelText: 'Password',
                                               border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                                               ),
                                             ),
                                             validator: (value) {
                                               if (value == null || value.isEmpty) {
                          return "This field is required";
                                               }
                                               return null;
                                             },
                                           ),
                       ),
                 
                      const SizedBox(width: 16),
                       Expanded(
                         child: TextFormField(
                                             controller: repassController,
                                             textInputAction: TextInputAction.done,
                                             keyboardType: TextInputType.visiblePassword,
                                             decoration: InputDecoration(
                                               labelText: 'Confirm Password',
                                               border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                                               ),
                                             ),
                                             validator: (value) {
                                               if (value == null || value.isEmpty) {
                          return "This field is required";
                                               }
                                               if (value != passController.text) {
                          return "Passwords do not match";
                                               }
                                               return null;
                                             },
                                           ),
                       ),
                    ],
                  ),
                 
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(
                        height: 18,
                        width: 18,
                        child: Checkbox(
                          value: false, // Placeholder for actual value
                          shape: RoundedRectangleBorder(borderRadius: radius(4)),
                          onChanged: (v) {},
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: 'I Agree to the ',
                                style: secondaryTextStyle()),
                            TextSpan(
                              text: "Terms & Conditions",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 12
                              ),
                              recognizer: TapGestureRecognizer()..onTap = () {},
                            ),
                            TextSpan(text: ' & ',  style: TextStyle(
                                color: Colors.black,
                                fontSize: 10
                              ),),
                            TextSpan(
                              text: "Privacy Policy",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 12
                              ),
                              // style: boldTextStyle(color: Colors.blue, size: 14),
                              recognizer: TapGestureRecognizer()..onTap = () {},
                            ),
                          ]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        // Handle the SignUp logic
                        Get.to(DashBoardScreen());
                      }
                    },
                    child: const Text("Sign Up"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          const Positioned(top: 30, child: BackButton()),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Already Have An Account!", style: primaryTextStyle()),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text("Log In", style: boldTextStyle(color: primaryColor)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
