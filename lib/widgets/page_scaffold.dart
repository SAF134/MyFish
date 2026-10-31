import 'package:flutter/material.dart';

import '../core/theme/app_tokens.dart';

/// Kerangka halaman tab: judul besar + konten bergulir dengan margin 16,
/// lebar maks 560dp dan dipusatkan (DESIGN.md §9).
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.title,
    required this.children,
    this.trailing,
  });

  final String title;
  final List<Widget> children;

  /// Aksi di kanan judul (mis. tombol "+ Tambah").
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSpacing.maxContentWidth,
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.lg,
              AppSpacing.screen,
              AppSpacing.xxxl,
            ),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(title, style: textTheme.titleLarge),
                    ),
                  ),
                  ?trailing,
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
