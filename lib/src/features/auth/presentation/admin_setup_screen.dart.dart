import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:queue_management_system/src/common_widgets/button.dart'
    as button;
import 'package:queue_management_system/src/constants/app_theme.dart';
import 'package:queue_management_system/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:queue_management_system/src/common_widgets/text_feild.dart';

class AdminSetupScreen extends HookConsumerWidget {
  const AdminSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _formKey = GlobalKey<FormState>();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final isLoading = useState(false);
    final auth = ref.read(authControllerProvider.notifier);

    void createAdmin() async {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      isLoading.value = true;

      final errorMessage =
          await auth.createAdmin(emailController.text, passwordController.text);
      isLoading.value = false;

      emailController.clear();
      passwordController.clear();

      if (context.mounted) {
        if (errorMessage != null) {
          //
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Error"),
                content: Text(errorMessage),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      (context).pop();
                    },
                    child: const Text("OK"),
                  ),
                ],
              );
            },
          );
        } else {
          //
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Admin created successfully!')),
          );
          context.goNamed('welcome');
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Admin',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: secondaryColor),
        ),
        centerTitle: true,
        backgroundColor: button.primaryColor,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [secondaryColor, secondaryColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 18),
                Image.asset(
                  'assets/logo/logo.png',
                  width: MediaQuery.of(context).size.width,
                  height: 150,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Replace TextFormField with AppTextFormField for email
                        AppTextFormField(
                          controller: emailController,
                          hintText: 'Enter your email',
                          helpText: 'Email',
                          obscureText: false,
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an email address';
                            }
                            if (!RegExp(
                                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                .hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Replace TextFormField with AppTextFormField for password
                        AppTextFormField(
                          controller: passwordController,
                          hintText: 'Enter your password',
                          helpText: 'Password',
                          obscureText: true,
                          icon: Icons.lock,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters long';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Create Admin button
                ElevatedButton(
                  onPressed: isLoading.value ? null : createAdmin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    side: BorderSide(color: AppTheme.theme.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: isLoading.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: primaryColor,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'Create',
                          style: TextStyle(
                            color: AppTheme.theme.scaffoldBackgroundColor,
                            fontSize: 16.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 10),

                // View Admin List button
                button.Btn(
                  onPress: () {
                    context.goNamed('adminList');
                  },
                  text: 'View Admin List',
                  backgroundColor: button.primaryColor,
                ),
                const SizedBox(height: 20),

                // Back button
                button.Btn(
                  onPress: () {
                    context.goNamed('welcome');
                  },
                  text: 'Back',
                  backgroundColor: button.primaryColor,
                ),
              ],
            ),
          ),
          if (isLoading.value)
            Container(
              color: primaryColor,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
