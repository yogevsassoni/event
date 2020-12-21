import 'package:flushbar/flushbar.dart';
import 'package:flushbar/flushbar_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'primary_button.dart';
import 'auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class Invite extends StatefulWidget {
  Invite({Key key, this.name, this.time, this.date, this.location, this.uid})
      : super(key: key);

  final String name;
  final String uid;
  final String time;
  final String date;
  final String location;



  @override
  _Invite createState() => new _Invite();
}

enum FormType { login, register }

class PasswordsException implements Exception {
  String code = "ERROR_NOT_MATCHING_PASSWORDS";
}

class _Invite extends State<Invite> {
  final firestoreInstance = Firestore.instance;
  static final formKey = new GlobalKey<FormState>();
  List<String> _listgroups = ['bhood', 'dabs', 'rofls'];
  List<bool> _groupschecked = List.filled(3, false);
  List<String> _listfriends = ['shlomi', 'yojev'];
  List<bool> _friendschecked = List.filled(3, false);
  List<String> invited_groups = [];
  List<String> invited_friends = [];
  bool _isChecked = false;



  final tab = new TabBar(
      labelColor: Colors.deepOrange,
      indicatorColor: Colors.deepOrange,
      tabs: <Tab>[
        new Tab(
          icon: new Icon(Icons.group, color: Colors.deepOrange),
          text: "Groups",
        ),
        new Tab(
          icon: new Icon(Icons.account_circle, color: Colors.deepOrange),
          text: "Friends",
        ),
      ]);

  void showFloatingFlushbar(BuildContext context, var message) {
    Flushbar(
      duration: new Duration(seconds: 4),
      borderRadius: 8,
      backgroundGradient: LinearGradient(
        colors: [Colors.deepOrange.shade300, Colors.yellow.shade300],
        stops: [0.6, 1],
      ),
      boxShadows: [
        BoxShadow(
          color: Colors.black45,
          offset: Offset(3, 3),
          blurRadius: 3,
        ),
      ],
      // All of the previous Flushbars could be dismissed by swiping down
      // now we want to swipe to the sides
      dismissDirection: FlushbarDismissDirection.VERTICAL,
      // The default curve is Curves.easeOut
      forwardAnimationCurve: Curves.easeOutQuad,

      message: message,
    )..show(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: new AppBar(
            centerTitle: true,
            title: new Text(
              'Invite ',
              style: TextStyle(
                fontSize: 40,
                foreground: Paint()
                  ..style = PaintingStyle.fill
                  ..strokeWidth = 1
                  ..color = Colors.red[700],
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }

                Navigator.of(context).pop();},
            ),
            iconTheme: new IconThemeData(color: Colors.deepOrange),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.topLeft,
                      colors: <Color>[Colors.yellow[100], Colors.yellow[100]])),
            ),
            bottom: tab,
          ),
          body: new TabBarView(
            children: [
              new ListView(
                children: _listgroups
                    .map((text) => CheckboxListTile(
                          activeColor: Colors.deepOrange,
                          title: Text(text),
                          value: _groupschecked[_listgroups.indexOf(text)],
                          onChanged: (val) {
                            setState(() {
                              _groupschecked[_listgroups.indexOf(text)] = val;
                            });
                          },
                        ))
                    .toList(),
              ),
              new ListView(
                children: _listfriends
                    .map((text) => CheckboxListTile(
                          activeColor: Colors.deepOrange,
                          title: Text(text),
                          value: _friendschecked[_listfriends.indexOf(text)],
                          onChanged: (val) {
                            setState(() {
                              _friendschecked[_listfriends.indexOf(text)] = val;
                            });
                          },
                        ))
                    .toList(),
              ),
            ],
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.deepOrangeAccent,
            child: Icon(Icons.add_circle, color: Colors.yellow[100]),
            onPressed: () {
              for (int i = 0; i < _friendschecked.length; i++) {
                if (_friendschecked[i]) {
                  invited_friends.add(_listfriends[i]);
                }
              }
              for (int i = 0; i < _groupschecked.length; i++) {
                if (_groupschecked[i]) {
                  invited_groups.add(_listgroups[i]);
                }
              }
              if (invited_friends.length == 0 && invited_groups.length == 0) {
                showFloatingFlushbar(context, "You have to invite someone");
              } else {

                firestoreInstance.collection("Events").add({
                  "groups": invited_groups,
                  "friends": invited_friends,
                  "name": widget.name,
                  "location": widget.location,
                  "date": widget.date,
                  "time": widget.time,
                }).then((value) {
                  String id = value.documentID;
                  firestoreInstance.collection("userEvents").document(widget.uid).setData({

                  }, merge: true);
                  DocumentReference documentReference =
                  Firestore.instance.collection("Events").document(id);
                  List idlist = [documentReference];
                  firestoreInstance.collection("userEvents").document(widget.uid).updateData({
                    "counter": FieldValue.increment(1),
                    "eventlist": FieldValue.arrayUnion(idlist),
                  });
                  int count = 0;
                  Navigator.of(context).popUntil((_) => count++ >= 2);
                });
              }
            },
          ),
        ),
      ),
    );
  }
}

Widget padded({Widget child}) {
  return new Padding(
    padding: EdgeInsets.symmetric(vertical: 8.0),
    child: child,
  );
}
