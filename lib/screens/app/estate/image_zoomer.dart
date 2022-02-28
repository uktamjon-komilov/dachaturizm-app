import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sizer/sizer.dart';

class ImageZoomer extends StatefulWidget {
  const ImageZoomer({Key? key}) : super(key: key);

  @override
  State<ImageZoomer> createState() => _ImageZoomerState();
}

class _ImageZoomerState extends State<ImageZoomer> {
  bool _isInit = true;
  List<String> photos = [];
  int _currentIndex = 0;
  PageController? controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _isInit = false;
      Map<String, dynamic>? data =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (data!.containsKey("photos")) {
        int index = photos.indexOf(data["current"]);
        setState(() {
          photos = data["photos"];
          _currentIndex = index;
          controller = PageController(initialPage: _currentIndex);
        });
        // controller!.jumpToPage(_currentIndex);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: 100.h,
        width: 100.w,
        // decoration: BoxDecoration(color: Colors.black),
        child: Stack(
          children: [
            Container(
              height: 100.h,
              width: 100.w,
              child: PageView.builder(
                  itemCount: photos.length,
                  controller: controller,
                  itemBuilder: (context, index) {
                    return PhotoView(
                      tightMode: true,
                      imageProvider: NetworkImage(
                        photos[index],
                      ),
                    );
                  }),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
