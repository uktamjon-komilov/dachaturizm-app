import 'dart:async';

import 'package:dachaturizm/components/app_bar.dart';
import 'package:dachaturizm/components/small_grey_text.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/helpers/call_with_auth.dart';
import 'package:dachaturizm/helpers/url_helper.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/models/user_model.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/providers/navigation_screen_provider.dart';
import 'package:dachaturizm/screens/app/estate/estate_detail_screen.dart';
import 'package:dachaturizm/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  static String routeName = "/chat";

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isInit = false;
  bool _isLoading = false;
  int _userId = 0;
  EstateModel? estate;
  UserModel? sender;
  Timer? _timer;
  Map<String, dynamic> _data = {};
  TextEditingController _textController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  _sendMessage() async {
    String text = _textController.text;
    _textController.text = "";
    if (text == "") return;
    Provider.of<AuthProvider>(context, listen: false)
        .sendMessage(estate!.id, sender!.id, text)
        .then((data) {
      if (data["estate"] == null) {
        callWithAuth(context, () {
          Navigator.of(context).pushNamed(LoginScreen.routeName);
        });
      } else {
        _data = data;
        setState(() {});
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      Map<String, dynamic> data =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      setState(() {
        estate = data["estate"];
        sender = data["sender"];
        _isInit = true;
        _isLoading = true;
      });
      Provider.of<AuthProvider>(context).getUserId().then((value) {
        if (value == null) {
          Navigator.of(context).pushNamed(LoginScreen.routeName);
        } else {
          setState(() {
            _userId = value;
          });
          Provider.of<AuthProvider>(context, listen: false)
              .getMessages(estate!.id, sender!.id)
              .then((value) {
            setState(() {
              _data = value;
              _isLoading = false;
            });
            // _scrollController
            //     .jumpTo(_scrollController.position.maxScrollExtent);
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      _timer = Timer.periodic(Duration(seconds: 5), (timer) {
        Provider.of<AuthProvider>(context, listen: false)
            .getMessages(estate!.id, sender!.id)
            .then((value) {
          setState(() {
            _data = value;
          });
          // _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        });
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Provider.of<NavigationScreenProvider>(context, listen: false)
            .refreshChatsScreen = true;
        Provider.of<NavigationScreenProvider>(context, listen: false)
            .changePageIndex(3);
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: buildNavigationalAppBar(context, sender!.fullname, () {
            Navigator.of(context).pop();
          }, [
            sender!.photo == ""
                ? IconButton(
                    onPressed: () {},
                    icon: Container(
                      width: 30,
                      height: 30,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          "assets/images/user.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                : IconButton(
                    onPressed: () {},
                    icon: Container(
                      width: 30,
                      height: 30,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(
                          fixMediaUrl(sender!.photo),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
          ]),
          body: _isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: [
                    _buildEstateBox(),
                    _buildMessagesList(),
                    _buildInputBox()
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildImageBox(EstateModel estate) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 80,
        height: 80,
        child: Image.network(
          estate.photo,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTitleWithStars(EstateModel estate) {
    return Padding(
      padding: const EdgeInsets.only(
        right: defaultPadding * 1.2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            estate.title,
            style: TextStyle(
              color: darkPurple,
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
            ),
            maxLines: 1,
          ),
          SizedBox(height: 5),
          RatingBar.builder(
            ignoreGestures: true,
            initialRating: estate.rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 15,
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {},
          ),
        ],
      ),
    );
  }

  Widget _buildLocation(EstateModel estate) {
    return Row(
      children: [
        Icon(
          Icons.location_on,
          size: 15,
          color: normalGrey,
        ),
        SizedBox(width: 5),
        SmallGreyText(text: estate.address),
      ],
    );
  }

  Widget _buildEstateBox() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          EstateDetailScreen.routeName,
          arguments: {
            "id": estate!.id,
            "typeId": estate!.typeId,
            "fromChat": true
          },
        );
      },
      child: Container(
        width: 100.w,
        height: 100,
        decoration: BoxDecoration(
          color: disabledOrange,
          border: Border(
            bottom: BorderSide(
              color: greyishLight.withOpacity(0.5),
            ),
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        margin: EdgeInsets.only(bottom: 5),
        child: Row(
          children: [
            _buildImageBox(estate as EstateModel),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleWithStars(estate as EstateModel),
                  _buildLocation(estate as EstateModel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBox() {
    return Container(
      width: 100.w,
      decoration: BoxDecoration(color: chatInputBackground),
      padding: EdgeInsets.fromLTRB(
        defaultPadding,
        defaultPadding / 2,
        defaultPadding,
        defaultPadding / 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextFormField(
              controller: _textController,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.29,
                letterSpacing: 0.2,
              ),
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                hintText: Locales.string(context, "write_a_message"),
                hintStyle: TextStyle(color: greyishLight),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.5),
                  borderSide: BorderSide(color: greyishLight, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.5),
                  borderSide: BorderSide(color: greyishLight, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.5),
                  borderSide: BorderSide(color: greyishLight, width: 1),
                ),
              ),
            ),
          ),
          Container(
            child: ElevatedButton(
              onPressed: _sendMessage,
              style: ElevatedButton.styleFrom(
                primary: normalOrange,
                elevation: 0,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.zero,
                minimumSize: Size(36, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(36),
                ),
              ),
              child: Container(
                width: 12,
                height: 12,
                child: SvgPicture.asset(
                  "assets/icons/arrow-top.svg",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              ..._data["messages"].map((message) {
                return MessageItem(
                  text: message.text,
                  time: message.time,
                  isSent: message.sender.id == _userId,
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageItem extends StatelessWidget {
  const MessageItem({
    Key? key,
    this.isSent = false,
    required this.text,
    required this.time,
  }) : super(key: key);

  final bool isSent;
  final String text;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSent ? Alignment.topRight : Alignment.topLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 70.w),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isSent ? sentMessageColor : inputGrey,
                borderRadius: BorderRadius.circular(15),
              ),
              padding: EdgeInsets.fromLTRB(12, 7, 45, 7),
              margin: EdgeInsets.symmetric(vertical: 6),
              child: Text(
                text,
                style: TextStyle(color: darkPurple, fontSize: 17),
              ),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: Text(
                time,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w400,
                  color: normalOrange,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
