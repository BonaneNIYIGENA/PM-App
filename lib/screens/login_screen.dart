import 'package:flutter/material.dart';

import '../components/components.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import 'main_shell.dart';

/// Sign-in screen: unDraw hero, credentials form and a sign-up link.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  Future<void> _signIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isLoading = true);
    // The app has no backend yet, so any non-empty credentials are accepted
    // after a short delay that gives the loading state a chance to show.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) {
      return;
    }
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const MainShell(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.xl,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const UndrawIllustration(
                  'assets/illustrations/team_collaboration.svg',
                  height: 200,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Project & SLA Task Tracker',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h1,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Plan. Track. Deliver Together.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.subtitle,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppTextField(
                  hint: 'Email',
                  prefixIcon: Icons.mail_outline,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: _required,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  hint: 'Password',
                  prefixIcon: Icons.lock_outline,
                  controller: _passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  validator: _required,
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: 'Sign In',
                  isLoading: _isLoading,
                  onPressed: _signIn,
                ),
                const SizedBox(height: AppSpacing.lg),
                const _SignUpFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SignUpFooter extends StatelessWidget {
  const _SignUpFooter();

  @override
  Widget build(BuildContext context) {
    // A [Wrap] lets the prompt and the link flow onto a second line instead of
    // overflowing when the text grows, for example under a large text scale.
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Text("Don't have an account? ", style: AppTextStyles.subtitle),
        GestureDetector(
          // TODO: open the sign-up screen once it exists.
          onTap: () {},
          child: Text(
            'Sign Up',
            style: AppTextStyles.subtitle.copyWith(
              color: AppColors.primaryAction,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
