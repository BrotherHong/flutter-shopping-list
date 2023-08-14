import 'dart:math';

import 'package:flutter/material.dart';

class AmountSelector extends StatefulWidget {
  final TextEditingController controller;
  final Widget? title;

  const AmountSelector({super.key, required this.controller, this.title});

  @override
  State<AmountSelector> createState() => _AmountSelectorState();
}

class _AmountSelectorState extends State<AmountSelector> {
  @override
  Widget build(BuildContext context) {

    // build
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // title
        widget.title ?? Container(),
        // selector
        Expanded(
          child: TextField(
            controller: widget.controller,
            textAlign: TextAlign.center,
            enableInteractiveSelection: false,
            canRequestFocus: false,
            readOnly: true,
            style: const TextStyle(fontSize: 22),
            decoration: InputDecoration(
              prefixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    int amount = int.tryParse(widget.controller.text) ?? 1;
                    amount = max(amount-1, 1);
                    widget.controller.text = amount.toString();
                  });
                },
                icon: const Icon(Icons.remove),
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    int amount = int.tryParse(widget.controller.text) ?? 1;
                    amount = min(amount+1, 9);
                    widget.controller.text = amount.toString();
                  });
                },
                icon: const Icon(Icons.add),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
