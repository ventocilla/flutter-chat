import 'package:flutter/material.dart';
import 'package:flutter_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat/screens/welcome_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = Firestore.instance;

class ChatScreen extends StatefulWidget {
  static const routeName = '/chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  FirebaseUser loggedInUser;
  String messageText;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    //getMessages();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        //print('User: $loggedInUser');
        //print(loggedInUser.email);
        //print(Email: ${loggedInUser.email}');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  /*
  void getMessages() async {
    final messages = await _firestore.collection('messages').getDocuments();
    for (var message in messages.documents) {
      print(message.data);
    }
  } */

  void messagesStream() async {
    await for (var snapshot in _firestore.collection('messages').snapshots()) {
      for (var message in snapshot.documents) {
        print(message.data);
        print(message.data['text']);
        print(message.data['sender']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
                //_auth.signOut();
                //print(user.uid);
                //Navigator.pushNamed(context, WelcomeScreen.routeName);
                // ---
                //getMessages();
                //messagesStream();
                _auth.signOut();
                Navigator.pushNamed(context, WelcomeScreen.routeName);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            /*
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('messages').snapshots(),
              builder: (context, snapshot){
                if(!snapshot.hasData){
                  return Center(child: CircularProgressIndicator(
                    backgroundColor: Colors.blueAccent,
                  ),
                  );
                }
                final messages = snapshot.data.documents;
                List<MessageBubble> messageBubbles = [];
                for(var message in messages) {
                  final messageText = message.data['text'];
                  final messageSender = message.data['sender'];

                  final messageBubble =
                      MessageBubble(text: messageText, sender: messageSender);
//                  Text('$messageText from $messageSender',
//                    style: TextStyle(color: Colors.white, fontSize: 20)
//                  );
                  messageBubbles.add(messageBubble);
                }
                return Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    children: messageBubbles,
                  ),
                );
                //}
              },
            ),
            */
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      //Implement send functionality.
                      _firestore.collection('messages').add(
                          {"text": messageText, "sender": loggedInUser.email});
                      messageTextController.text = '';
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//
class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.blueAccent,
            ),
          );
        }
        final messages = snapshot.data.documents;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          final messageText = message.data['text'];
          final messageSender = message.data['sender'];

          final messageBubble =
              MessageBubble(text: messageText, sender: messageSender);
          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final String sender;

  const MessageBubble({this.text, this.sender});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(sender, style: TextStyle(fontSize: 12, color: Colors.white54)),
            Material(
              borderRadius: BorderRadius.circular(30),
              elevation: 5.0,
              color: Colors.lightBlueAccent,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  text,
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ),
          ],
        ));
  }
}
