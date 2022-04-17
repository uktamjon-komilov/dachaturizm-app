import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
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
        decoration: const BoxDecoration(color: Colors.black),
        child: Stack(
          children: [
            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: CachedNetworkImageProvider(photos[index]),
                  initialScale: PhotoViewComputedScale.contained * 0.8,
                  heroAttributes: PhotoViewHeroAttributes(tag: photos[index]),
                );
              },
              itemCount: photos.length,
              loadingBuilder: (context, event) => Center(
                child: Container(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(
                    value: event == null
                        ? 0
                        : event.cumulativeBytesLoaded /
                            event.expectedTotalBytes!.toInt(),
                  ),
                ),
              ),
              // backgroundDecoration: widget.backgroundDecoration,
              pageController: controller,
              onPageChanged: (int number) {},
            ),
            Positioned(
              top: 40,
              left: 25,
              child: IconButton(
                icon: const Icon(
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
