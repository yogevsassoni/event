import 'package:flushbar/flushbar.dart';
import 'package:flushbar/flushbar_route.dart';
import 'package:flutter/material.dart';
import 'primary_button.dart';
import 'auth.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title, this.auth, this.onSignIn}) : super(key: key);

  final String title;
  final BaseAuth auth;
  final VoidCallback onSignIn;
  String uid;

  @override
  _LoginPageState createState() => new _LoginPageState();
}

enum FormType { login, register }

class PasswordsException implements Exception {
  String code = "ERROR_NOT_MATCHING_PASSWORDS";
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
    title: 'Wrong information entered:',
    message: message,
  )..show(context);
}

class _LoginPageState extends State<LoginPage> {
  static final formKey = new GlobalKey<FormState>();

  String _email;
  String _password;
  String _confirmpassword;
  String _name;

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
        if (_formType == FormType.login) {
          print(_email);
          userId = await widget.auth.signIn(_email, _password);
        } else {
          if (_password != _confirmpassword) {
            throw new PasswordsException();
          }
          userId = await widget.auth.createUser(_email, _password, _name);
        }
        setState(() {
          _authHint = 'Signed In\n\nUser id: $userId';
        });
        widget.onSignIn();
      } catch (e) {
        switch (e.code) {
          case "ERROR_INVALID_EMAIL":
            errorMessage = "Your email address appears to be malformed.";
            break;
          case "ERROR_WRONG_PASSWORD":
            errorMessage = "Bad Email or Password";
            break;
          case "ERROR_USER_NOT_FOUND":
            errorMessage = "Bad Email or Password";
            break;
          case "ERROR_USER_DISABLED":
            errorMessage = "User with this email has been disabled.";
            break;
          case "ERROR_TOO_MANY_REQUESTS":
            errorMessage = "Too many requests. Try again later.";
            break;
          case "ERROR_OPERATION_NOT_ALLOWED":
            errorMessage = "Signing in with Email and Password is not enabled.";
            break;
          case "ERROR_OPERATION_NOT_ALLOWED":
            errorMessage = "Signing in with Email and Password is not enabled.";
            break;
          case "ERROR_NOT_MATCHING_PASSWORDS":
            errorMessage = "Passwords don't match.";
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

  void moveToRegister() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.register;
      _authHint = '';
    });
  }

  void moveToLogin() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.login;
      _authHint = '';
    });
  }

  List<Widget> usernameAndPassword() {
    switch (_formType) {
      case FormType.login:
        return [
          padded(
            child: new TextFormField(
                style: TextStyle(color: Colors.redAccent),
                key: new Key('email'),
                onSaved: (val) => _email = val,
                cursorColor: Colors.deepOrange,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  fillColor: Colors.deepOrange,
                  labelText: 'Email',
                  labelStyle: new TextStyle(color: Colors.deepOrange),
                  hintText: 'Enter an email address',
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
                obscureText: true,
                key: new Key('password'),
                onSaved: (val) => _password = val,
                cursorColor: Colors.deepOrangeAccent,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: new TextStyle(color: Colors.deepOrange),
                  hintText: 'Enter Password',
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.yellow)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepOrange)),
                  border: OutlineInputBorder(borderSide: BorderSide()),
                )),
          ),
        ];
      case FormType.register:
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
          padded(
            child: new TextFormField(
                style: TextStyle(color: Colors.redAccent),
                key: new Key('email'),
                onSaved: (val) => _email = val,
                cursorColor: Colors.deepOrange,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  fillColor: Colors.deepOrange,
                  labelText: 'Email',
                  labelStyle: new TextStyle(color: Colors.deepOrange),
                  hintText: 'Enter an email address',
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
                obscureText: true,
                key: new Key('password'),
                onSaved: (val) => _password = val,
                cursorColor: Colors.deepOrangeAccent,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: new TextStyle(color: Colors.deepOrange),
                  hintText: 'Enter Password',
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
                obscureText: true,
                key: new Key('confirm password'),
                onSaved: (val) => _confirmpassword = val,
                cursorColor: Colors.deepOrangeAccent,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Confirm password',
                  labelStyle: new TextStyle(color: Colors.deepOrange),
                  hintText: 'Confirm Password',
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.yellow)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepOrange)),
                  border: OutlineInputBorder(borderSide: BorderSide()),
                )),
          ),
        ];
    }
  }

  List<Widget> submitWidgets(BuildContext context) {
    switch (_formType) {
      case FormType.login:
        return [
          new PrimaryButton(
            key: new Key('login'),
            text: 'Login',
            height: 44.0,
            onPressed: () => validateAndSubmit(context),
          ),
          new FlatButton(
              key: new Key('need-account'),
              child: new Text("Need an account? Register"),
              onPressed: moveToRegister),
        ];
      case FormType.register:
        return [
          new PrimaryButton(
            key: new Key('register'),
            text: 'Create an account',
            height: 44.0,
            onPressed: () => validateAndSubmit(context),
          ),
          new FlatButton(
              key: new Key('need-login'),
              child: new Text("Have an account? Login"),
              onPressed: moveToLogin),
        ];
    }
    return null;
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
            widget.title,
            style: TextStyle(
              fontSize: 40,
              foreground: Paint()
                ..style = PaintingStyle.fill
                ..strokeWidth = 1
                ..color = Colors.red[700],
            ),
          ),
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
                            decoration:
                            BoxDecoration(
                              border: Border.all(
                                color: Colors.red
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(5.0)
                              )
                            ),
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
