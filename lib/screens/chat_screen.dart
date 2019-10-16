import 'package:flutter/material.dart';
import 'package:flutter_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat/screens/welcome_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = '/chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _firestore = Firestore.instance;
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
      if(user != null) {
        loggedInUser = user;
        print('User: $loggedInUser');
        print(loggedInUser.email);
        //print(Email: ${loggedInUser.email}');
      }
    } catch(e) {
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
    await for( var snapshot in _firestore.collection('messages').snapshots() ) {
      for( var message in snapshot.documents) {
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
                List<Text> messageWidgets = [];
                for(var message in messages) {
                  final messageText = message.data['text'];
                  final messageSender = message.data['sender'];

                  final messageWidget =
                  Text('$messageText from $messageSender',
                    style: TextStyle(color: Colors.white, fontSize: 20));
                  messageWidgets.add(messageWidget);
                }
                return Column(
                  children: messageWidgets,
                );
                //}
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
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
                      _firestore.collection('messages').add({
                        "text": messageText,
                        "sender": loggedInUser.email
                      });
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
