import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/core/widgets/my_button.dart';
import 'package:munch_nearby/core/widgets/my_text_form_field.dart';
import 'package:munch_nearby/features/auth/domain/entities/auth_entity.dart';

import '../../../../core/utils/snackbar_utils.dart';
import '../state/auth_state.dart';
import '../view_model/auth_view_model.dart';
import 'login_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String selectedRole = "Customer";

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.error) {
        SnackbarUtils.showError(
          context,
          next.errorMessage ?? "Registration failed",
        );
      } else if (next.status == AuthStatus.registered) {
        SnackbarUtils.showSuccess(
          context,
          "Registration successful",
        );
      }
    });

    final authState = ref.watch(authViewModelProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 60),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100),
                const Center(
                  child: Text(
                    "MunchNearby",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE87A5D),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    "Create your Account",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                MyTextFormField(
                  label: "Name",
                  controller: nameController,
                  prefixIcon: Icons.person_2_outlined,
                  onChanged: (value) {},
                  validator: (value) {
                    if (value!.isEmpty) return "Enter your name";
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                MyTextFormField(
                  label: "Email",
                  controller: emailController,
                  prefixIcon: Icons.email_outlined,
                  onChanged: (value) {},
                  validator: (value) {
                    if (value!.isEmpty) return "Enter your email";
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  "Role:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Radio(
                      value: "Customer",
                      groupValue: selectedRole,
                      activeColor: Color(0xFFE87A5D),
                      onChanged: (value) {
                        setState(() => selectedRole = value!);
                      },
                    ),
                    const Text("Customer"),
                    const SizedBox(width: 25),
                    Radio(
                      value: "Restaurant Owner",
                      groupValue: selectedRole,
                      activeColor: Color(0xFFE87A5D),
                      onChanged: (value) {
                        setState(() => selectedRole = value!);
                      },
                    ),
                    const Text("Restaurant Owner"),
                  ],
                ),
                const SizedBox(height: 10),
                MyTextFormField(
                  label: "Password",
                  controller: passwordController,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: Icons.visibility_off_outlined,
                  obscureText: true,
                  onChanged: (value) {},
                  validator: (value) {
                    if (value!.isEmpty) return "Enter your password";
                    if (value.length < 6) return "Password must be at least 6 characters";
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                MyTextFormField(
                  label: "Confirm Password",
                  controller: confirmPasswordController,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: Icons.visibility_off_outlined,
                  obscureText: true,
                  onChanged: (value) {},
                  validator: (value) {
                    if (value!.isEmpty) return "Re-enter your password";
                    if (value != passwordController.text) return "Passwords do not match";
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                MyButton(
                  text: "Register",
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ref.read(authViewModelProvider.notifier).register(
                        name: nameController.text.trim(),
                        email: emailController.text.trim(),
                        username: emailController.text.trim().split("@").first,
                        password: passwordController.text,
                        role: selectedRole == "Customer"
                            ? UserRole.customer
                            : UserRole.restaurantOwner,
                      );
                    }
                  },
                ),
                const SizedBox(height: 25),
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
                    onTap: () {
                      // TODO: Implement Google sign-in
                    },
                    child: Image.asset(
                      "assets/images/google.png",
                      width: 55,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Have Account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
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
      ),
    );
  }
}