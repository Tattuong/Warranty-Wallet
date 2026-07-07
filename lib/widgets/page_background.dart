import 'package:flutter/material.dart';

import 'vault_ui.dart';

/// Full-screen ambient background wrapper.
class PageBackground extends StatelessWidget {
  final Widget child;

  const PageBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return VaultMeshBackground(child: child);
  }
}
