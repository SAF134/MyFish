import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_tokens.dart';
import 'app_button.dart';
import 'password_field.dart';

/// Fungsi verifikasi password. Kembalikan `null` jika benar, atau pesan error.
typedef PasswordVerifier = Future<String?> Function(String password);

/// Dialog password untuk re-autentikasi sebelum aksi sensitif
/// (reset/matikan ESP32, simpan kalibrasi).
///
/// Mengembalikan `true` jika password terverifikasi. Biasanya `verify`
/// diisi `AuthRepository().reauthenticate`.
/// State: default, error, loading.
Future<bool> showPasswordDialog(
  BuildContext context, {
  required PasswordVerifier verify,
  String title = 'Konfirmasi Password',
  String message = 'Masukkan password akun untuk melanjutkan.',
  String confirmLabel = 'Lanjut',
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _PasswordDialog(
      verify: verify,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
    ),
  );
  return result ?? false;
}

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog({
    required this.verify,
    required this.title,
    required this.message,
    required this.confirmLabel,
  });

  final PasswordVerifier verify;
  final String title;
  final String message;
  final String confirmLabel;

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _controller = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final password = _controller.text;
    if (password.isEmpty) {
      setState(() => _error = 'Password wajib diisi');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final error = await widget.verify(password);
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _loading = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AlertDialog(
      icon: const Icon(
        Icons.lock_rounded,
        color: AppColors.primary,
        semanticLabel: 'Keamanan',
      ),
      title: Semantics(header: true, child: Text(widget.title)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.message,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.lg),
            PasswordField(
              controller: _controller,
              autofocus: true,
              enabled: !_loading,
              errorText: _error,
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        0,
        AppSpacing.xxl,
        AppSpacing.xxl,
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: AppButton.secondary(
                label: 'Batal',
                onPressed: _loading
                    ? null
                    : () => Navigator.of(context).pop(false),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppButton.primary(
                label: widget.confirmLabel,
                isLoading: _loading,
                loadingLabel: 'Memeriksa password…',
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
