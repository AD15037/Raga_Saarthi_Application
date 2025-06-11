import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double height;
  final double spacing;
  final bool showText;
  final TextStyle? textStyle;

  const AppLogo({
    Key? key,
    this.height = 40,
    this.spacing = 8.0,
    this.showText = true,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/Icon.jpeg',
          height: height,
        ),
        if (showText) ...[
          SizedBox(width: spacing),
          Text(
            'Raga Saarthi',
            style: textStyle ?? TextStyle(
              fontSize: height * 0.5,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ],
      ],
    );
  }
}