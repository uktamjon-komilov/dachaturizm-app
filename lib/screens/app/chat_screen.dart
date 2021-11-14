import "package:flutter/material.dart";

class ChatPageScreen extends StatefulWidget {
  const ChatPageScreen({Key? key}) : super(key: key);

  @override
  _ChatPageScreenState createState() => _ChatPageScreenState();
}

class _ChatPageScreenState extends State<ChatPageScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text("Chat Page"),
      ),
    );
  }
}
