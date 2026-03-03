import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.otpSent) {
        setState(() => otpSent = true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('OTP sent successfully!')));
      } else if (next.status == AuthStatus.passwordReset) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset successfully!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
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
              const Text(
                "MunchNearby",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE87A5D),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Forgot Password",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                otpSent
                    ? "Enter OTP and new password"
                    : "Enter your identifier to get OTP",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 15),
              ),
              const SizedBox(height: 40),

              if (!otpSent)
                MyTextFormField(
                  label: "Identifier",
                  controller: identifierController,
                  prefixIcon: Icons.person_outline,
                  validator: (value) =>
                      value!.isEmpty ? "Enter your identifier" : null,
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
