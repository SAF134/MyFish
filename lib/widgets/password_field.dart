import 'package:flutter/material.dart';

/// Input password dengan ikon mata (tampil/sembunyi).
///
/// State: default, focus, error (`errorText`), disabled (`enabled: false`).
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    this.controller,
    this.label = 'Password',
    this.errorText,
    this.enabled = true,
    this.autofocus = false,
    this.onSubmitted,
    this.onChanged,
    this.textInputAction = TextInputAction.done,
  });

  final TextEditingController? controller;
  final String label;
  final String? errorText;
  final bool enabled;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final TextInputAction textInputAction;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final toggleLabel = _obscure
        ? 'Tampilkan password'
        : 'Sembunyikan password';
    return TextField(
      controller: widget.controller,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      obscureText: _obscure,
      enableSuggestions: false,
      autocorrect: false,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      autofillHints: const [AutofillHints.password],
      onSubmitted: widget.onSubmitted,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: widget.errorText,
        errorMaxLines: 2,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          tooltip: toggleLabel,
          onPressed: widget.enabled
              ? () => setState(() => _obscure = !_obscure)
              : null,
          icon: Icon(
            _obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            semanticLabel: toggleLabel,
          ),
        ),
      ),
    );
  }
}
