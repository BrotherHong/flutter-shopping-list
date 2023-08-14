import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SlidableDelete extends StatefulWidget {
  final Widget child;
  final Function() onDeletePressed;
  final bool enabled;
  final bool fadeOut;

  const SlidableDelete({
    super.key,
    required this.child,
    required this.onDeletePressed,
    this.enabled = true,
    this.fadeOut = true,
  });

  @override
  State<SlidableDelete> createState() => _SlidableDeleteState();
}

class _SlidableDeleteState extends State<SlidableDelete> {
  double opacity = 1;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 600),
      curve: Curves.fastOutSlowIn,
      onEnd: () => widget.onDeletePressed(),
      child: Slidable(
        enabled: widget.enabled,
        endActionPane: ActionPane(
          extentRatio: 0.3,
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => setState(() {
                opacity = widget.fadeOut ? 0 : 0.99;
              }),
              icon: Icons.delete,
              backgroundColor: Colors.red.shade400,
              spacing: 2,
            )
          ],
        ),
        child: widget.child,
      ),
    );
  }
}
