import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../shared_widgets/custom_button.dart';
import '../../../shared_widgets/loading_indicator.dart';
import '../../../shared_widgets/error_dialog.dart';
import '../../../utils/email_validator.dart';
import '../../../utils/password_validator.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String _selectedRole = 'therapist';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Provider.of<AuthProvider>(context, listen: false).clearErrorMessage();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp(AuthProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Creating your account..."),
            ],
          ),
        ),
      );

      final success = await authProvider.signUp(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _selectedRole,
      );

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (success) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created successfully! Redirecting...'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Additional fallback: if navigation doesn't happen automatically, force it
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted && authProvider.authStatus == AuthStatus.authenticated) {
          authProvider.forceReload();
        }
      } else if (mounted && authProvider.errorMessage != null) {
        ErrorDialog.show(
          context,
          'Signup Failed',
          authProvider.errorMessage!,
          onRetry: () => _signUp(authProvider),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    Widget signUpFormCard = Material(
      elevation: 4.0,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        width: isSmallScreen ? double.infinity : 400,
        padding: const EdgeInsets.all(32.0),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.0)),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Create Account', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text('Join the Supervisor Hub community', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF4B5563))),
              const SizedBox(height: 32),
              
              Align(alignment: Alignment.centerLeft, child: Text('Full Name', style: theme.textTheme.labelMedium)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(hintText: 'Your Name', prefixIcon: Icon(Icons.person_outline, color: Colors.grey[600])),
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 20),
              
              Align(alignment: Alignment.centerLeft, child: Text('Email Address', style: theme.textTheme.labelMedium)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(hintText: 'you@example.com', prefixIcon: Icon(Icons.mail_outline, color: Colors.grey[600])),
                validator: EmailValidator.validate,
              ),
              const SizedBox(height: 20),
              
              Align(alignment: Alignment.centerLeft, child: Text('Password', style: theme.textTheme.labelMedium)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'At least 6 characters',
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: PasswordValidator.validate,
              ),
              const SizedBox(height: 20),
              
              Align(alignment: Alignment.centerLeft, child: Text('Confirm Password', style: theme.textTheme.labelMedium)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  hintText: 'Re-enter password',
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please confirm your password';
                  if (value != _passwordController.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              Align(alignment: Alignment.centerLeft, child: Text('I am a:', style: theme.textTheme.labelMedium)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items: const [
                  DropdownMenuItem(value: 'therapist', child: Text('Therapist')),
                  DropdownMenuItem(value: 'admin', child: Text('Practice Admin')),
                ],
                onChanged: (value) => setState(() => _selectedRole = value!),
                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0)),
                validator: (value) => value == null ? 'Please select a role' : null,
              ),
              const SizedBox(height: 24),
              
              Consumer<AuthProvider>(builder: (context, provider, child) {
                return provider.isLoading
                    ? const LoadingIndicator()
                    : CustomElevatedButton(text: 'Create Account', onPressed: () => _signUp(provider), width: double.infinity);
              }),
              const SizedBox(height: 24),
              
              TextButton(
                onPressed: () {
                  if (mounted) Provider.of<AuthProvider>(context, listen: false).clearErrorMessage();
                  Navigator.pop(context);
                },
                child: RichText(
                  text: TextSpan(
                    text: "Already have an account? ",
                    style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF4B5563)),
                    children: <TextSpan>[TextSpan(text: 'Login', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w500))],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
        backgroundColor: Colors.transparent, elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        titleTextStyle: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.onSurface),
      ),
      backgroundColor: const Color(0xFFF0F9FF),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: isSmallScreen ? signUpFormCard : ConstrainedBox(constraints: const BoxConstraints(maxWidth: 400), child: signUpFormCard),
        ),
      ),
    );
  }
}
