import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/core/utils/snackbar_utils.dart';
import 'package:munch_nearby/features/auth/presentation/state/auth_state.dart';
import 'package:munch_nearby/features/auth/presentation/view_model/auth_view_model.dart';
import '../widgets/my_button.dart';
import '../widgets/my_text_form_field.dart';
import 'login_screen.dart';

class ForgetPasswordScreen extends ConsumerStatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  ConsumerState<ForgetPasswordScreen> createState() =>
      _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends ConsumerState<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final identifierController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool otpSent = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.otpSent) {
        setState(() => otpSent = true);
        SnackbarUtils.showSuccess(context, 'OTP sent successfully!');
      } else if (next.status == AuthStatus.passwordReset) {
        SnackbarUtils.showSuccess(context, 'Password reset successfully!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 60),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 120),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Password ",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE87A5D),
                      ),
                    ),
                    TextSpan(
                      text: "Reset",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Text(
                otpSent
                    ? "Enter your email to get OTP"
                    : "Enter OTP and new password",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 40),

              if (!otpSent)
                MyTextFormField(
                  label: "Email",
                  controller: identifierController,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) =>
                      value!.isEmpty ? "Enter your EMail" : null,
                  onChanged: (String value) {},
                ),

              if (otpSent) ...[
                MyTextFormField(
                  label: "OTP",
                  controller: otpController,
                  prefixIcon: Icons.confirmation_number_outlined,
                  validator: (value) => value!.isEmpty ? "Enter OTP" : null,
                  onChanged: (String value) {},
                ),
                const SizedBox(height: 15),
                MyTextFormField(
                  label: "New Password",
                  controller: newPasswordController,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Enter new password" : null,
                  obscureText: true,
                  onChanged: (String value) {},
                ),
                const SizedBox(height: 15),
                MyTextFormField(
                  label: "Confirm Password",
                  controller: confirmPasswordController,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword = !obscureConfirmPassword;
                      });
                    },
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Confirm password" : null,
                  obscureText: true,
                  onChanged: (String value) {},
                ),
              ],

              const SizedBox(height: 35),

              MyButton(
                text: otpSent ? "Reset Password" : "Send OTP",
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (!otpSent) {
                      ref
                          .read(authViewModelProvider.notifier)
                          .requestPasswordReset(
                            email: identifierController.text,
                          );
                    } else {
                      ref
                          .read(authViewModelProvider.notifier)
                          .resetPassword(
                            otp: otpController.text,
                            newPassword: newPasswordController.text,
                            confirmPassword: confirmPasswordController.text,
                            email: identifierController.text, // optional
                          );
                    }
                  }
                },
              ),

              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Remembered Password?"),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: Color(0xFFE87A5D),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
