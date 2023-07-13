import 'package:toy_exchange_app/constants/colors.dart';
import 'package:toy_exchange_app/constants/validators.dart';
import 'package:toy_exchange_app/constants/widgets.dart';
import 'package:toy_exchange_app/screens/auth/login_screen.dart';
import 'package:toy_exchange_app/services/auth.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetForm extends StatefulWidget {
  const ResetForm({
    Key? key,
  }) : super(key: key);

  @override
  State<ResetForm> createState() => _ResetFormState();
}

class _ResetFormState extends State<ResetForm> {
  Auth authService = Auth();
  late final TextEditingController _emailController;
  late final FocusNode _emailNode;
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    _emailController = TextEditingController();
    _emailNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  focusNode: _emailNode,
                  controller: _emailController,
                  validator: (value) {
                    return validateEmail(
                        value, EmailValidator.validate(_emailController.text));
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your Email',
                      hintStyle: TextStyle(
                        color: greyColor,
                        fontSize: 12,
                      ),
                      contentPadding: const EdgeInsets.all(20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
                const SizedBox(
                  height: 25,
                ),
                roundedButton(
                    context: context,
                    bgColor: secondaryColor,
                    text: 'Send Reset Link',
                    textColor: whiteColor,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        FirebaseAuth.instance
                            .sendPasswordResetEmail(
                                email: _emailController.text)
                            .then((value) {
                          customSnackBar(
                              context: context,
                              content: 'Reset email sent to your email');
                          Navigator.pushReplacementNamed(
                              context, LoginScreen.screenId);
                        });
                      }
                    }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
