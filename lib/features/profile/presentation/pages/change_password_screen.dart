import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/features/auth/presentation/state/auth_state.dart';
import 'package:munch_nearby/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:munch_nearby/features/auth/presentation/widgets/my_button.dart';
import 'package:munch_nearby/features/auth/presentation/widgets/my_text_form_field.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authViewModelProvider);

    ref.listen(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.passwordChanged) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password changed successfully")),
        );

        Navigator.pop(context);
      }

      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Change Password",
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontFamily: "PlusJakarta Bold"),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              MyTextFormField(
                controller: _oldPasswordController,
                obscureText: _obscureOld,
                label: "Old Password",
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureOld ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureOld = !_obscureOld;
                    });
                  },
                ),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter Old password";
                  }
                  return null;
                },
                onChanged: (String value) {},
              ),

              const SizedBox(height: 20),

              /// New Password
              MyTextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNew,
                label: "New Password",
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureNew = !_obscureNew;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter new password";
                  }
                  if (value.length < 6) {
                    return "Password must be at least 6 characters";
                  }
                  return null;
                },
                onChanged: (String value) {},
              ),

              const SizedBox(height: 20),

              /// Confirm Password
              MyTextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                label: "Confirm Password",
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirm = !_obscureConfirm;
                    });
                  },
                ),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please confirm password";
                  }
                  if (value != _newPasswordController.text) {
                    return "Passwords do not match";
                  }
                  return null;
                },
                onChanged: (String value) {},
              ),

              const SizedBox(height: 30),

              state.status == AuthStatus.loading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: MyButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            ref
                                .read(authViewModelProvider.notifier)
                                .changePassword(
                                  oldPassword: _oldPasswordController.text
                                      .trim(),
                                  newPassword: _newPasswordController.text
                                      .trim(),
                                  confirmPassword: _confirmPasswordController
                                      .text
                                      .trim(),
                                );
                          }
                        },
                        text: 'Change Password',
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
