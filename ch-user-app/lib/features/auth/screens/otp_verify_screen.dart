import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../auth_notifier.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String phone;
  const OtpVerifyScreen({super.key, required this.phone});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = context.read<AuthNotifier>();
    final ok = await notifier.verifyOtp(
      phone: widget.phone,
      token: _otpController.text.trim(),
    );
    if (ok && mounted) {
      context.go('/map');
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<AuthNotifier>();

    return Scaffold(
      appBar: AppBar(title: const Text('Verify code')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'We sent a 6-digit code to\n${widget.phone}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Verification code',
                    counterText: '',
                  ),
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Enter the 6-digit code'
                      : null,
                ),
                if (notifier.error != null) ...[
                  const SizedBox(height: 12),
                  Text(notifier.error!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: notifier.loading ? null : _verify,
                  child: notifier.loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Verify'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Change number'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
