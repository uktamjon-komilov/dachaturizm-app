import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/helpers/url_helper.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/models/message_model.dart';
import 'package:dachaturizm/models/user_model.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/providers/navigation_screen_provider.dart';
import 'package:dachaturizm/screens/app/chat/chat_screen.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  static String routeName = "/chat-list";

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<MessageModel> _chats = [];
  bool _isLoading = false;

  _refreshMyChats() async {
    Future.delayed(Duration.zero).then((_) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<AuthProvider>(context, listen: false)
          .getMyChats()
          .then((value) {
        setState(() {
          _chats = value;
          _isLoading = false;
        });
      });
    });
  }

  @override
  void didChangeDependencies() async {
    bool shouldRefresh =
        Provider.of<NavigationScreenProvider>(context).refreshChatsScreen;
    if (shouldRefresh) {
      Provider.of<NavigationScreenProvider>(context, listen: false)
          .refreshChatsScreen = false;
      await _refreshMyChats();
    }
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) async {
      await _refreshMyChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () {
          return _refreshMyChats();
        },
        child: Container(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  itemCount: _chats.length,
                  itemBuilder: (context, index) {
                    UserModel sender = _chats[index].sender;
                    EstateModel estate = _chats[index].estateDetail;
                    return ListTile(
                      onTap: () {
                        Navigator.of(context).pushNamed(ChatScreen.routeName,
                            arguments: {"estate": estate, "sender": sender});
                      },
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: defaultPadding / 1.5,
                        vertical: defaultPadding / 6,
                      ),
                      title: Text(
                        sender.fullname,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        estate.title,
                        maxLines: 1,
                        style: TextStyle(
                          color: normalGrey,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      trailing: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                        decoration: BoxDecoration(
                          color: normalOrange,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          _chats[index].count.toString(),
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                      leading: sender.photo == null
                          ? Container(
                              width: 60,
                              height: 60,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.asset(
                                  "assets/images/user.png",
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : Container(
                              width: 60,
                              height: 60,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.network(
                                  fixMediaUrl(sender.photo),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                    );
                  }),
        ),
      ),
    );
  }
}
