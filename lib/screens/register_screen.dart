import 'package:flutter/material.dart';
import '../widgets/my_button.dart';
import '../widgets/my_text_form_field.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String selectedRole = "Customer"; // default role

  @override
  Widget build(BuildContext context) {
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

                // Title
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

                // Email Field
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

                // Role Title
                const Text(
                  "Role:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 10),

                // Role Radio Buttons
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

                // Password Field
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

                // Confirm Password
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

                // Register Button
                MyButton(
                  text: "Register",
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      print("Email = ${emailController.text}");
                      print("Role = $selectedRole");
                      print("Password = ${passwordController.text}");
                    }
                  },
                ),

                const SizedBox(height: 25),

                // Divider
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

                // Google Sign-in Button
                Center(
                  child: InkWell(
                    onTap: () {},
                    child: Image.asset(
                      "assets/images/google.png",
                      width: 55,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Already have account? Login
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
