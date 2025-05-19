import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../shared_widgets/custom_button.dart';
import '../../../shared_widgets/loading_indicator.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Provider.of<AuthProvider>(context, listen: false).clearErrorMessage();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail(AuthProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      final success = await authProvider.sendPasswordResetEmail(_emailController.text.trim());
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password reset email sent. Check your inbox.')),
          );
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    Widget forgotPasswordFormCard = Material(
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
              Text('Reset Password', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 16),
              Text('Enter your email address and we will send you instructions to reset your password.', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF4B5563))),
              const SizedBox(height: 32),
              Align(alignment: Alignment.centerLeft, child: Text('Email Address', style: theme.textTheme.labelMedium)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(hintText: 'you@example.com', prefixIcon: Icon(Icons.mail_outline, color: Colors.grey[600])),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your email';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Please enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Consumer<AuthProvider>(builder: (context, provider, child) {
                if (provider.errorMessage != null && !provider.isLoading) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(provider.errorMessage!, style: TextStyle(color: theme.colorScheme.error, fontSize: 13), textAlign: TextAlign.center),
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: 8),
              Consumer<AuthProvider>(builder: (context, provider, child) {
                return provider.isLoading
                    ? const LoadingIndicator()
                    : CustomElevatedButton(text: 'Send Reset Email', onPressed: () => _sendResetEmail(provider), width: double.infinity);
              }),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  if (mounted) Provider.of<AuthProvider>(context, listen: false).clearErrorMessage();
                  Navigator.pop(context);
                },
                child: Text('Back to Login', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
        backgroundColor: Colors.transparent, elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        titleTextStyle: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.onSurface),
      ),
      backgroundColor: const Color(0xFFF0F9FF),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: isSmallScreen ? forgotPasswordFormCard : ConstrainedBox(constraints: const BoxConstraints(maxWidth: 400), child: forgotPasswordFormCard),
        ),
      ),
    );
  }
}
