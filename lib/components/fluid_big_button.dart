import 'package:dachaturizm/constants.dart';
import 'package:flutter/material.dart';

class FluidBigButton extends StatelessWidget {
  const FluidBigButton({
    Key? key,
    required this.onPress,
    this.text,
    this.disabled = false,
    this.size,
    this.child,
    this.shape,
    this.loading = false,
  }) : super(key: key);

  final String? text;
  final void Function()? onPress;
  final bool disabled;
  final Size? size;
  final Widget? child;
  final OutlinedBorder? shape;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (disabled || loading) ? () {} : onPress,
      child: child ??
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text ?? "",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                  height: 1.28,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
              ),
              Visibility(
                visible: loading,
                child: Container(
                  width: 15,
                  height: 15,
                  margin: EdgeInsets.only(left: 10),
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ],
          ),
      style: ElevatedButton.styleFrom(
        primary: loading ? Colors.grey[400] : normalOrange,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: shape ??
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
        minimumSize: size ?? Size(double.infinity, 48),
      ),
    );
  }
}
