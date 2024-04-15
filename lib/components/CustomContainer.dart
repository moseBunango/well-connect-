import 'package:flutter/material.dart';
class CustomOverflowContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color backgroundColor;
  final double borderRadius;

  const CustomOverflowContainer({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.backgroundColor = Colors.white,
    this.borderRadius = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView( // Wrap child in SingleChildScrollView
            scrollDirection: Axis.vertical, // Allow vertical scrolling
            physics: const ClampingScrollPhysics(), // Prevent overscrolling
            child: ConstrainedBox( // Constrain child's width
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth, // Use available width
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }
}