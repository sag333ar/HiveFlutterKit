import 'package:flutter/material.dart';

class InkWellWrapper extends StatelessWidget {
  const InkWellWrapper({super.key, required this.child, this.onTap, this.borderRadius});

  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            borderRadius: borderRadius,
            child: InkWell(
              onTap: onTap,
              borderRadius: borderRadius,
              child: const SizedBox(),
            ),
          ),
        )
      ],
    );
  }
}
