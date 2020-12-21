
import 'package:flutter/material.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flappy_search_bar/search_bar_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rofl/home_page.dart';
import 'package:rofl/search_service.dart';
import 'my_popup_menu.dart' as mypopup;

class AddFriends extends StatefulWidget {
  @override
  _AddFriends createState() => new _AddFriends();
}

enum WhyFarther { addFriend }

class _AddFriends extends State<AddFriends> {
  final firestoreInstance = Firestore.instance;
  var queryResultSet = [];
  var tempSearchStore = [];

  initiateSearch(value) {
    if (value.length == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    }

    var capitalizedValue = value.substring(0, 1) + value.substring(1);

    if (queryResultSet.length == 0 && value.length == 1) {
      SearchService().searchByName(value).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.documents.length; ++i) {
          queryResultSet.add(docs.documents[i]);
        }
      });
    } else {
      tempSearchStore = [];
      queryResultSet.forEach((element) {
        if (element.data['name'].contains(capitalizedValue)) {
          setState(() {
            print(element.data['name']);
            tempSearchStore.add(element);
          });
        }
        if (!(element.data['name'].startsWith(capitalizedValue))) {
          setState(() {
            tempSearchStore.remove(element.data['name']);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          iconTheme: IconThemeData(
            color: Colors.deepOrange, //change your color here
          ),
          backgroundColor: Colors.yellow[100],
          centerTitle: true,
          title: Text('Search Friends',
              style: TextStyle(
                color: Colors.deepOrange,
              )),
        ),
        body: ListView(children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              onChanged: (val) {
                initiateSearch(val);
              },
              decoration: InputDecoration(
                prefixIcon: IconButton(
                  color: Colors.black,
                  icon: Icon(Icons.search),
                  iconSize: 20.0,
                ),
                contentPadding: EdgeInsets.only(left: 25.0),
                hintText: 'Search by name',
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.yellow)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepOrange)),
                border: OutlineInputBorder(borderSide: BorderSide()),
              ),
            ),
          ),
          SizedBox(height: 10.0),
          ListView(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              primary: false,
              shrinkWrap: true,
              children: tempSearchStore.map((element) {
                return buildResultCard(element);
              }).toList())
        ]));
  }

  Widget buildResultCard(data) {
    return Card(
      color: Colors.yellow[100],
      child: ListTile(
        leading: Text(
          "rofl",
          textAlign: TextAlign.center,
        ),
        subtitle: Text(
          'Loctaion: ',
        ),
        title: Text(data['name'],
            textAlign: TextAlign.left, style: TextStyle(fontSize: 20.0)),
        trailing: mypopup.PopupMenuButton<WhyFarther>(
          onSelected: (WhyFarther result) {
            String id = data.documentID;
            firestoreInstance.collection("userFriends").document(userid).setData({
            }, merge: true);
            print(userid);
            print("id" + id);
            DocumentReference documentReference = Firestore.instance
                .collection("Users").document(id);
            List idlist = [documentReference];
            firestoreInstance
                .collection("userFriends")
                .document(userid)
                .updateData({
              "counter": FieldValue.increment(1),
              "friendslist": FieldValue.arrayUnion(idlist),
            });
          },
          itemBuilder: (BuildContext context) => [
            mypopup.PopupMenuItem<WhyFarther>(
              value: WhyFarther.addFriend,
              child: Container(
                height: double.infinity,
                width: double.infinity,
                color: Colors.lightGreen,
                // i use this to change the bgColor color right now
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.check),
                    SizedBox(width: 5.0),
                    Text(
                      "  AddFriend",
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(width: 5.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
