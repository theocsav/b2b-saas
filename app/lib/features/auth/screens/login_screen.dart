import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../shared_widgets/custom_button.dart';
import '../../../shared_widgets/loading_indicator.dart';
import '../../../shared_widgets/error_dialog.dart';
import '../../../utils/email_validator.dart';
import '../../../app/app_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<AuthProvider>(context, listen: false).clearErrorMessage();
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login(AuthProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      final success = await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      if (!success && mounted && authProvider.errorMessage != null) {
        ErrorDialog.show(
          context,
          'Login Failed',
          authProvider.errorMessage!,
          onRetry: () => _login(authProvider),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    Widget loginFormCard = Material(
      elevation: 4.0,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        width: isSmallScreen ? double.infinity : 400,
        padding: const EdgeInsets.all(32.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text('S', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
              Text('Welcome Back', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text('Sign in to continue to Supervisor Hub', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF4B5563))),
              const SizedBox(height: 32),
              Align(alignment: Alignment.centerLeft, child: Text('Email Address', style: theme.textTheme.labelMedium)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'you@example.com',
                  prefixIcon: Icon(Icons.mail_outline, color: Colors.grey[600]),
                ),
                validator: EmailValidator.validate,
              ),
              const SizedBox(height: 20),
              Align(alignment: Alignment.centerLeft, child: Text('Password', style: theme.textTheme.labelMedium)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      TextButton(
                        onPressed: () {
                          if (mounted) Provider.of<AuthProvider>(context, listen: false).clearErrorMessage();
                          Navigator.pushNamed(context, AppRouter.forgotPasswordRoute);
                        },
                        child: Text('Forgot?', style: TextStyle(color: theme.colorScheme.primary, fontSize: 13, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your password';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Consumer<AuthProvider>(builder: (context, provider, child) {
                return provider.isLoading
                    ? const LoadingIndicator()
                    : CustomElevatedButton(text: 'Login', onPressed: () => _login(provider), width: double.infinity);
              }),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  if (mounted) Provider.of<AuthProvider>(context, listen: false).clearErrorMessage();
                  Navigator.pushNamed(context, AppRouter.signupRoute);
                },
                child: RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF4B5563)),
                    children: <TextSpan>[TextSpan(text: 'Sign Up', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w500))],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return Scaffold(
      key: const ValueKey("LoginScreenScaffold"),
      backgroundColor: const Color(0xFFF0F9FF),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: isSmallScreen ? loginFormCard : ConstrainedBox(constraints: const BoxConstraints(maxWidth: 400), child: loginFormCard),
        ),
      ),
    );
  }
}
