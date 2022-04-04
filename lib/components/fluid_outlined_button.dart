import 'package:dachaturizm/constants.dart';
import 'package:flutter/material.dart';

class FluidOutlinedButton extends StatelessWidget {
  const FluidOutlinedButton({
    required this.onPress,
    Key? key,
    this.text,
    this.disabled = false,
    this.size,
    this.child,
    this.shape,
  }) : super(key: key);

  final String? text;
  final void Function()? onPress;
  final bool disabled;
  final Size? size;
  final Widget? child;
  final OutlinedBorder? shape;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: disabled ? () {} : onPress,
      child: child ??
          Text(
            text ?? "",
            style: const TextStyle(
              fontSize: 14,
              color: normalOrange,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
              height: 1.28,
            ),
          ),
      style: ElevatedButton.styleFrom(
        primary: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        onPrimary: normalOrange,
        shape: shape ??
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                color: normalOrange,
                width: 1,
              ),
            ),
        minimumSize: size ?? Size(double.infinity, 48),
      ),
    );
  }
}
