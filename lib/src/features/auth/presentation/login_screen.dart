import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:queue_management_system/src/common_widgets/button.dart';
import 'package:queue_management_system/src/common_widgets/text_feild.dart';
import '../../../constants/app_theme.dart';
import 'controllers/auth_controller.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final isLoading = useState(false);
    final auth = ref.read(authControllerProvider.notifier);

    void login() async {
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter both email and password')),
        );
        return;
      }
      FocusScope.of(context).unfocus();
      isLoading.value = true;
      final error = await auth.signIn(
        emailController.text,
        passwordController.text,
      );
      isLoading.value = false;

      if (error != null) {
        // Show dialog in case of error
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Login Error'),
            content: Text(error),
            actions: [
              TextButton(
                onPressed: () => (context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Queue Management',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.theme.primaryColor,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF1F2ED), Color(0xFFF1F2ED)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const SizedBox(height: 18),
              Image.asset(
                'assets/logo/logo.png',
                width: MediaQuery.of(context).size.width,
                height: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
              AppTextFormField(
                controller: emailController,
                hintText: 'Email',
                helpText: 'Enter your email',
                obscureText: false,
                icon: Icons.email,
              ),
              const SizedBox(height: 20),
              AppTextFormField(
                controller: passwordController,
                hintText: 'Password',
                helpText: 'Enter your password',
                obscureText: true,
                icon: Icons.lock,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading.value ? null : login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF335A7B),
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
                          color: Color(0xFF335A7B),
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'Login',
                        style: TextStyle(
                          color: AppTheme.theme.scaffoldBackgroundColor,
                          fontSize: 16.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 10),
              Btn(
                onPress: () => context.goNamed('welcome'),
                text: 'Back',
              ),
            ],
          ),
          if (isLoading.value)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
