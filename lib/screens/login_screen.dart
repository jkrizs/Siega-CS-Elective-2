import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/session_state.dart';
import '../theme/app_theme.dart';

enum _Mode { login, register }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  _Mode _mode = _Mode.login;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final session = context.read<SessionState>();
    final email = _email.text.trim();
    if (_mode == _Mode.login) {
      session.login(email, _password.text);
    } else {
      session.register(email, _password.text);
    }
  }

  void _switchMode(_Mode mode) {
    context.read<SessionState>().dismissMessages();
    setState(() => _mode = mode);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    final form = Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: _buildForm(context),
        ),
      ),
    );

    if (isWide) {
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              Expanded(child: _heroImage('assets/hero_banner_desktop.png')),
              Expanded(child: form),
            ],
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _heroImage('assets/hero_banner_mobile.png'),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.55),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Card(
                    elevation: 8,
                    color: theme.colorScheme.surface.withValues(alpha: 0.96),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
                      child: _buildForm(context),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroImage(String path) {
    return Image.asset(
      path,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) => Container(color: AppColors.primary),
    );
  }

  Widget _buildForm(BuildContext context) {
    final session = context.watch<SessionState>();
    final theme = Theme.of(context);
    final isLogin = _mode == _Mode.login;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Hydro Flask',
            textAlign: TextAlign.center,
            style: AppTextStyles.appBarTitle.copyWith(
              fontSize: 30,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isLogin ? 'Log in to start shopping' : 'Create your store account',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          SegmentedButton<_Mode>(
            segments: const [
              ButtonSegment(value: _Mode.login, label: Text('Log in')),
              ButtonSegment(value: _Mode.register, label: Text('Register')),
            ],
            selected: {_mode},
            showSelectedIcon: false,
            onSelectionChanged: session.loading
                ? null
                : (selection) => _switchMode(selection.first),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(
              labelText: 'Email address',
              prefixIcon: Icon(Icons.alternate_email),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              final text = value?.trim() ?? '';
              final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text);
              return valid ? null : 'Please enter a valid email address';
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _password,
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            autofillHints: [
              isLogin ? AutofillHints.password : AutofillHints.newPassword,
            ],
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.password),
              border: const OutlineInputBorder(),
              helperText: isLogin ? null : 'At least 6 characters',
              suffixIcon: IconButton(
                tooltip: _obscure ? 'Show password' : 'Hide password',
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: (value) => (value ?? '').length >= 6
                ? null
                : 'Password must be at least 6 characters',
          ),
          if (session.error != null)
            _Banner(
              message: session.error!,
              icon: Icons.error_outline,
              color: theme.colorScheme.error,
            ),
          if (session.info != null)
            _Banner(
              message: session.info!,
              icon: Icons.mark_email_read_outlined,
              color: AppColors.success,
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: session.loading ? null : _submit,
            child: session.loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(isLogin ? 'LOG IN' : 'CREATE ACCOUNT'),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'OR CONTINUE WITH',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 22),
          OutlinedButton.icon(
            onPressed: session.loading ? null : session.loginWithGitHub,
            icon: const Icon(Icons.terminal),
            label: const Text('GitHub'),
          ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.message,
    required this.icon,
    required this.color,
  });

  final String message;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: TextStyle(color: color))),
        ],
      ),
    );
  }
}
