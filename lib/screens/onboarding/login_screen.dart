import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agri_connect/providers/auth_provider.dart';
import 'package:agri_connect/screens/farmer/farmer_dashboard.dart';
import 'package:agri_connect/screens/consumer/consumer_dashboard.dart';
import 'package:agri_connect/screens/onboarding/signup_screen.dart';
import 'package:agri_connect/utils/constants.dart';
import 'package:agri_connect/utils/localization_helper.dart';
import '../../l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success) {
        // Navigate to the appropriate dashboard based on user role
        if (authProvider.currentUser!.role == UserRole.farmer) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const FarmerDashboard()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ConsumerDashboard()),
          );
        }
      } else {
        setState(() {
          _errorMessage =
              AppLocalizations.of(context).translate('invalidCredentials');
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            '${AppLocalizations.of(context).translate('errorOccurred')}: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = Provider.of<AuthProvider>(context).selectedRole;
    final isCustomer = role == UserRole.consumer;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          LocalizedStrings.login(context),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // User role icon
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Image.network(
                      isCustomer
                          ? 'https://cdn-icons-png.flaticon.com/512/1077/1077063.png'
                          : 'https://cdn-icons-png.flaticon.com/512/1146/1146869.png',
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Role text
                Center(
                  child: Text(
                    isCustomer
                        ? LocalizedStrings.consumer(context)
                        : LocalizedStrings.farmer(context),
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: LocalizedStrings.email(context),
                    hintText:
                        AppLocalizations.of(context).translate('enterEmail'),
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)
                          .translate('pleaseEnterEmail');
                    }
                    if (!value.contains('@')) {
                      return AppLocalizations.of(context)
                          .translate('pleaseEnterValidEmail');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: LocalizedStrings.password(context),
                    hintText:
                        AppLocalizations.of(context).translate('enterPassword'),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)
                          .translate('pleaseEnterPassword');
                    }
                    if (value.length < 6) {
                      return AppLocalizations.of(context)
                          .translate('passwordMinLength');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // Forgot password link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // For prototype, we won't implement this
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)
                              .translate('forgotPasswordNotImplemented')),
                        ),
                      );
                    },
                    child: Text(
                      AppLocalizations.of(context).translate('forgotPassword'),
                      style: TextStyle(color: AppColors.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Error message
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: AppColors.errorColor),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Login button
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(LocalizedStrings.login(context)),
                ),
                const SizedBox(height: 16),

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      LocalizedStrings.dontHaveAccount(context),
                      style: TextStyle(color: AppColors.textColor),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      child: Text(
                        LocalizedStrings.register(context),
                        style: TextStyle(color: AppColors.primaryColor),
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
