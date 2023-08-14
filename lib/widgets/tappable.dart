import 'package:flutter/material.dart';

class Tappable extends StatelessWidget {
  final Widget child;
  final Function()? onTap;
  final Function(TapDownDetails)? onTapDown;
  final Function(TapUpDetails)? onTapUp;

  const Tappable({
    super.key,
    required this.child,
    this.onTap,
    this.onTapDown,
    this.onTapUp,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      child: child,
    );
  }
}
