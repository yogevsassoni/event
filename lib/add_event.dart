import 'package:flushbar/flushbar.dart';
import 'package:flushbar/flushbar_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:rofl/create_event.dart';
import 'primary_button.dart';
import 'auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class CreateEvent extends StatefulWidget {
  CreateEvent({Key key, this.title, this.auth, this.onSignIn, this.uid})
      : super(key: key);

  final String title;
  final String uid;
  final BaseAuth auth;
  final VoidCallback onSignIn;

  @override
  _CreateEventState createState() => new _CreateEventState();
}

class FieldException implements Exception {
  String code = "ERROR_EMPTY_FIELD";
}

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

class _CreateEventState extends State<CreateEvent> {
  static final formKey = new GlobalKey<FormState>();
  final firestoreInstance = Firestore.instance;

  String _name = "";
  String _Location = "";
  String _date = "";
  String _time = "";

  FormType _formType = FormType.login;
  String _authHint = '';

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit(BuildContext context) async {
    var errorMessage = "";
    String userId = "";

    if (validateAndSave()) {
      try {
        if (_name == "" || _Location == "" || _date == "" || _time == "") {
          throw FieldException();
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Invite(
                        name: _name,
                        date: _date,
                        location: _Location,
                        time: _time,
                        uid: widget.uid,
                      )));
        }
      } catch (e) {
        switch (e.code) {
          case "ERROR_EMPTY_FIELD":
            errorMessage = "Can't leave empty fields";
            break;

          default:
            errorMessage = "Error";
        }
        setState(() {
          _authHint = 'Sign In Error\n\n${e.toString()}';
          print(e);
          showFloatingFlushbar(context, errorMessage);
        });
      }
    } else {
      setState(() {
        _authHint = '';
      });
    }
  }

  List<Widget> usernameAndPassword() {
    return [
      padded(
        child: new TextFormField(
            style: TextStyle(color: Colors.redAccent),
            key: new Key('name'),
            onSaved: (val) => _name = val,
            cursorColor: Colors.deepOrange,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              fillColor: Colors.deepOrange,
              labelText: 'Event name',
              labelStyle: new TextStyle(color: Colors.deepOrange),
              hintText: 'What?',
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.yellow)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepOrange)),
              border: OutlineInputBorder(borderSide: BorderSide()),
            )),
      ),
      padded(
        child: new TextFormField(
            style: TextStyle(color: Colors.redAccent),
            obscureText: false,
            key: new Key('location'),
            onSaved: (val) => _Location = val,
            cursorColor: Colors.deepOrangeAccent,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: 'Location',
              labelStyle: new TextStyle(color: Colors.deepOrange),
              hintText: 'Where?',
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.yellow)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepOrange)),
              border: OutlineInputBorder(borderSide: BorderSide()),
            )),
      ),
      padded(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  elevation: 4.0,
                  onPressed: () {
                    DatePicker.showDatePicker(context,
                        theme: DatePickerTheme(
                          containerHeight: 210.0,
                        ),
                        showTitleActions: true,
                        minTime: DateTime.now(),
                        maxTime: DateTime(
                            DateTime.now().year + 100,
                            DateTime.now().month,
                            DateTime.now().day), onConfirm: (date) {
                      print('confirm $date');
                      _date = ' ${date.day}/${date.month}/${date.year}';
                      setState(() {});
                    }, currentTime: DateTime.now(), locale: LocaleType.en);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 50.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.date_range,
                                    size: 18.0,
                                    color: Colors.deepOrange,
                                  ),
                                  Text(
                                    " $_date",
                                    style: TextStyle(
                                        color: Colors.deepOrange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        Text(
                          "  Change",
                          style: TextStyle(
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0),
                        ),
                      ],
                    ),
                  ),
                  color: Colors.yellow[100],
                ),
                SizedBox(
                  height: 20.0,
                ),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  elevation: 4.0,
                  onPressed: () {
                    DatePicker.showTimePicker(context,
                        theme: DatePickerTheme(
                          containerHeight: 210.0,
                        ),
                        showTitleActions: true,
                        showSecondsColumn: false, onConfirm: (time) {
                      print('confirm $time');
                      if (time.minute > 9) {
                        _time = '${time.hour}:${time.minute}';
                      } else {
                        _time = '${time.hour}:0${time.minute}';
                      }
                      setState(() {});
                    }, currentTime: DateTime.now(), locale: LocaleType.en);
                    setState(() {});
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 50.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.access_time,
                                    size: 18.0,
                                    color: Colors.deepOrange,
                                  ),
                                  Text(
                                    " $_time",
                                    style: TextStyle(
                                        color: Colors.deepOrange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        Text(
                          "  Change",
                          style: TextStyle(
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0),
                        ),
                      ],
                    ),
                  ),
                  color: Colors.yellow[100],
                )
              ],
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> submitWidgets(BuildContext context) {
    return [
      new PrimaryButton(
        key: new Key('invite'),
        text: 'INVITE OTHERS',
        height: 44.0,
        onPressed: () => validateAndSubmit(context),
      ),
    ];
  }

  Widget hintText() {
    return new Container(
        //height: 80.0,
        padding: const EdgeInsets.all(32.0),
        child: new Text(_authHint,
            key: new Key('hint'),
            style: new TextStyle(fontSize: 18.0, color: Colors.grey),
            textAlign: TextAlign.center));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          centerTitle: true,
          title: new Text(
            'Create an event ',
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
        ),
        backgroundColor: Colors.yellow[100],
        body: new SingleChildScrollView(
            child: new Container(
                padding: const EdgeInsets.all(16.0),
                child: new Column(children: [
                  new Card(
                      child: new Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                        new Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.red),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0))),
                            child: new Form(
                                key: formKey,
                                child: new Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: usernameAndPassword() +
                                      submitWidgets(context),
                                ))),
                      ])),
                ]))));
  }

  Widget padded({Widget child}) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: child,
    );
  }
}
