import 'package:flushbar/flushbar.dart';
import 'package:flushbar/flushbar_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:rofl/home_page.dart';
import 'primary_button.dart';
import 'auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';
final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class createGroup extends StatefulWidget {
  List<String> _listfriends;
  createGroup(List<String> friends,
      {
        Key key, this.name, this.time, this.date, this.location})

      : super(key: key){
    this._listfriends = friends;
  }

  final String name;
  final String time;
  final String date;
  final String location;
  String groupname = "";


  @override
  _createGroupState createState() => new _createGroupState();
}

enum FormType { login, register }

class PasswordsException implements Exception {
  String code = "ERROR_NOT_MATCHING_PASSWORDS";
}

class _createGroupState extends State<createGroup> {
  final firestoreInstance = Firestore.instance;
  static final formKey = new GlobalKey<FormState>();
  List<String> _listgroups = ['bhood', 'dabs', 'rofls','bhood', 'dabs', 'rofls','bhood', 'dabs', 'rofls','bhood', 'dabs', 'rofls','bhood', 'dabs', 'rofls'];
  List<bool> _groupschecked = List.filled(14, false);
  List<bool> _friendschecked = List.filled(14, false);
  List<String> invited_groups = [];
  List<String> invited_friends = [];
  bool _isChecked = false;


  bool validateAndSave(var str) {
    widget.groupname = str;
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void initState() {
    super.initState();
  }



  final tab = new TabBar(
      labelColor: Colors.deepOrange,
      indicatorColor: Colors.deepOrange,
      tabs: <Tab>[

        new Tab(
            icon: new Icon(Icons.dashboard, color: Colors.deepOrange),
            text: "Group details"
        ),
        new Tab(
          icon: new Icon(Icons.account_circle, color: Colors.deepOrange),
          text: "Invited friends",
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

  void voteUpB(var str) {
    print(str);
    setState(() => widget.groupname = str);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
    child: MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: new AppBar(
            centerTitle: true,
            title: new Text(
              'Create a group ',
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
          body:
          new TabBarView(

            children: [
              padded(child: TextFormField(
                  style: TextStyle(color: Colors.redAccent),
                  key: new Key('name'),
                  onChanged: (val) {
                    setState(() {
                      widget.groupname = val;
                    });
                  },
                  initialValue: widget.groupname,
                  cursorColor: Colors.deepOrange,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    fillColor: Colors.deepOrange,
                    labelText: 'Profile name',
                    labelStyle: new TextStyle(color: Colors.deepOrange),
                    hintText: 'Enter your profile name',
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.yellow)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.deepOrange)),
                    border: OutlineInputBorder(borderSide: BorderSide()),
                  )),
              ),
              new ListView(
                children: widget._listfriends
                    .map((text) => CheckboxListTile(
                  activeColor: Colors.deepOrange,
                  title: Text(text),
                  value: _friendschecked[widget._listfriends.indexOf(text)],
                  onChanged: (val) {
                    setState(() {
                      _friendschecked[widget._listfriends.indexOf(text)] = val;
                    });
                  },
                ))
                    .toList()
                ,
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
                  invited_friends.add(widget._listfriends[i]);
                }
              }

              if (invited_friends.length == 0 || widget.groupname.length == 0) {
                showFloatingFlushbar(context, "Group cant be empty");
              } else {
                firestoreInstance.collection("Groups").add({
                  "name": widget.groupname,
                  "friends": invited_friends,
                }).then((value) {
                  String id = value.documentID;
                  firestoreInstance.collection("userGroups").document(userid).setData({

                  }, merge: true);
                  DocumentReference documentReference =
                  Firestore.instance.collection("Groups").document(id);
                  List idlist = [documentReference];
                  firestoreInstance.collection("userGroups").document(userid).updateData({
                    "counter": FieldValue.increment(1),
                    "grouplist": FieldValue.arrayUnion(idlist),
                  });
                  int count = 0;
                  Navigator.of(context).popUntil((_) => count++ >= 1);
                });
              }
            },
          ),
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
