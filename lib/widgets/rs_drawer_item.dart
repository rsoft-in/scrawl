import 'package:flutter/material.dart';

import '../helpers/constants.dart';

class RSDrawerItem extends StatefulWidget {
  final Widget? icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  const RSDrawerItem(
      {Key? key,
      this.icon,
      required this.label,
      required this.onTap,
      this.trailing})
      : super(key: key);

  @override
  State<RSDrawerItem> createState() => _RSDrawerItemState();
}

class _RSDrawerItemState extends State<RSDrawerItem> {
  @override
  Widget build(BuildContext context) {
    /**
     * The InkWell Widget does not show splash if parent widget has
     * a background color set. Hence Material Widget with transparent
     * background is used as its parent.
     */
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onTap(),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              widget.icon ?? Container(),
              kHSpace,
              Expanded(
                child: Text(widget.label),
              ),
              widget.trailing ?? Container(),
            ],
          ),
        ),
      ),
    );
  }
}
