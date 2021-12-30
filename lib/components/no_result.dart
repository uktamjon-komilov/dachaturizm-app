import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class NoResult extends StatelessWidget {
  const NoResult({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      width: 100.w,
      child: Column(
        children: [
          Image.asset(
            "assets/images/thinking-face.png",
            height: 50,
            width: 50,
          ),
          SizedBox(height: 30),
          Text(
            "Natija topilmadi",
            style: TextStyle(
              color: Colors.black,
              height: 1.25,
              fontSize: 16,
              letterSpacing: 0.2,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Mahsulot nomini topish uchun boshqa kalit so'zlarni ishlatishga harakat qiling",
            style: TextStyle(
                fontSize: 14,
                height: 1.42,
                fontWeight: FontWeight.w300,
                color: Color(0xFF838589)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
