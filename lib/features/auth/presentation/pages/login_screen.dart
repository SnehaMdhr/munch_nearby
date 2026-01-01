import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/features/auth/presentation/pages/register_screen.dart';
import 'package:munch_nearby/screens/bottom_navigation_bar_for_customer.dart';
import 'package:munch_nearby/screens/forget_password_screen.dart';
import '../../../../screens/bottom_navigation_bar_for_restaurant.dart';
import '../state/auth_state.dart';
import '../view_model/auth_view_model.dart';
import '../../../../core/widgets/my_button.dart';
import '../../../../core/widgets/my_text_form_field.dart';
import '../../../../core/utils/snackbar_utils.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.error) {
        SnackbarUtils.showError(
          context,
          next.errorMessage ?? "Login failed",
        );
      } else if (next.status == AuthStatus.authenticated) {
        SnackbarUtils.showSuccess(
          context,
          "Login successful",
        );

        final role = next.authEntity?.role;
        if (role == "Customer") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const BottomNavigationBarForCustomer(),
            ),
          );
        } else if (role == "Restaurant Owner") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const BottomNavigationBarForRestaurant(),
            ),
          );
        } else {
          // fallback if role is missing or unknown
          SnackbarUtils.showError(context, "Unknown role, cannot navigate");
        }
      }
    });


    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
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
                  "Welcome Back!",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 40),

                // Email Field
                MyTextFormField(
                  label: "Email",
                  controller: emailController,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value!.isEmpty) return "Enter your email";
                    return null;
                  },
                  onChanged: (_) {},
                ),

                const SizedBox(height: 20),

                // Password Field
                MyTextFormField(
                  label: "Password",
                  controller: passwordController,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: Icons.visibility_off_outlined,
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) return "Enter your password";
                    return null;
                  },
                  onChanged: (_) {},
                ),

                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ForgetPasswordScreen()),
                      );
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Color(0xFFE87A5D),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                MyButton(
                  text: "Login",
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await ref.read(authViewModelProvider.notifier).login(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      );
                    }
                  },
                ),

                const SizedBox(height: 35),

                // Divider Line
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("Or sign in with"),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 20),
                Center(
                  child: InkWell(
                    onTap: () {},
                    child: Image.asset(
                      "assets/images/google.png",
                      width: 55,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Register text link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don’t have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: const Text(
                        "Create Account",
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
      ),
    );
  }
}