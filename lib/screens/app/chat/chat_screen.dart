import 'dart:async';

import 'package:dachaturizm/components/small_grey_text.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/helpers/call_with_auth.dart';
import 'package:dachaturizm/helpers/parse_datetime.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/models/user_model.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/providers/navigation_screen_provider.dart';
import 'package:dachaturizm/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
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
  Map<String, dynamic> _data = {};
  TextEditingController _textController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  _sendMessage() async {
    String text = _textController.text;
    _textController.text = "";
    Provider.of<AuthProvider>(context, listen: false)
        .sendMessage(estate!.id, sender!.id, text)
        .then((data) {
      if (data["estate"] == null) {
        callWithAuth(context, () {
          Navigator.of(context).pushNamed(LoginScreen.routeName);
        });
      } else {
        setState(() {
          _data = data;
        });
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
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

  Widget _buildDateAndViews(EstateModel estate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 15,
              color: normalGrey,
            ),
            SizedBox(width: 5),
            SmallGreyText(
              text: Locales.string(context, "placed") +
                  " " +
                  parseDateTime(
                    estate.created as DateTime,
                  ),
            ),
          ],
        ),
        Row(
          children: [
            Icon(
              Icons.remove_red_eye,
              size: 15,
              color: normalGrey,
            ),
            SizedBox(width: 5),
            SmallGreyText(
              text: "${Locales.string(context, "views")} ${estate.views}",
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocation(EstateModel estate) {
    return Row(
      children: [
        Icon(
          Icons.location_city,
          size: 15,
          color: normalGrey,
        ),
        SizedBox(width: 5),
        SmallGreyText(text: estate.address),
      ],
    );
  }

  Widget _buildEstateBox() {
    return Card(
      shadowColor: Colors.transparent,
      color: Colors.white,
      child: Container(
        width: 100.w,
        height: 100,
        padding: EdgeInsets.all(defaultPadding / 2),
        child: Stack(
          children: [
            Row(
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
                      _buildDateAndViews(estate as EstateModel),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBox() {
    return Container(
      padding: EdgeInsets.fromLTRB(5, 1, 1, 1),
      child: TextFormField(
        controller: _textController,
        style: TextStyle(fontSize: 18),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          border: null,
          hintText: "Write a message",
          suffix: Padding(
            padding: const EdgeInsets.only(right: 15),
            child: SizedBox(
              width: 20,
              height: 20,
              child: IconButton(
                onPressed: () async {
                  await _sendMessage();
                },
                icon: Icon(Icons.send),
                iconSize: 20,
                padding: EdgeInsets.all(0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return Expanded(
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            ..._data["messages"].map((message) {
              return MessageItem(
                text: message.text,
                isSent: message.sender.id == _userId,
              );
            }).toList(),
          ],
        ),
      ),
    );
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
          callWithAuth(context, () {
            Navigator.of(context).pushNamed(LoginScreen.routeName);
          });
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
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      Timer.periodic(Duration(seconds: 5), (timer) {
        Provider.of<AuthProvider>(context, listen: false)
            .getMessages(estate!.id, sender!.id)
            .then((value) {
          setState(() {
            _data = value;
          });
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        });
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Provider.of<NavigationScreenProvider>(context, listen: false)
            .refreshChatsScreen = true;
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          body: _isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Container(
                  padding: EdgeInsets.fromLTRB(
                    defaultPadding / 2,
                    defaultPadding / 2,
                    defaultPadding / 2,
                    0,
                  ),
                  child: Column(
                    children: [
                      _buildEstateBox(),
                      _buildMessagesList(),
                      _buildInputBox()
                    ],
                  ),
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
  }) : super(key: key);

  final bool isSent;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSent ? Alignment.topRight : Alignment.topLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 70.w),
        child: Container(
          decoration: BoxDecoration(
            color: isSent ? darkPurple : normalOrange,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.symmetric(vertical: 2),
          child: Text(
            text,
            style: TextStyle(color: Colors.white, height: 1.5),
          ),
        ),
      ),
    );
  }
}
