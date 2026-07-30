import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.bottom,
    this.showBack = true,
    this.padding = const EdgeInsets.fromLTRB(24, 12, 24, 24),
  });

  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final Widget? bottom;
  final bool showBack;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title != null || showBack
          ? AppBar(
              automaticallyImplyLeading: showBack,
              title: title == null
                  ? null
                  : Text(title!,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
              actions: actions,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
      bottomNavigationBar: bottom == null
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: bottom!,
            ),
    );
  }
}
