import 'package:groupchat/Authenticate/Methods.dart';
import 'package:groupchat/Screens/ChatRoom.dart';
import 'package:groupchat/group_chats/group_chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {

  //IT IS FOR STORING THE VALUE WHICH WE SEARCH....
  Map<String, dynamic>? userMap;

  bool isLoading = false;
  final TextEditingController _search = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this); // this would be initialise in HomeScreenState
    setStatus("Online");  // THIS IS FOR WHEN USER OPEN APP...

    //SO FROM THIS WE GET WHEN THE APP IS OPEN IT SHOW ONLINE STATUS...
  }

  void setStatus(String status) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({   //HERE WE CHECK USER IS IN OUR FIRESTORE THEN CHCK CURRENTUSER'S UID AND UPDATE IT
      "status": status,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) { //THIS IS USE FOR CHECKING CURRENT STATE
    if (state == AppLifecycleState.resumed) { //resumed = IT REPRESENT FOR THE USER OPEN THE APP 2ND TIME AFTER BACKGROUND
      // online
      setStatus("ONLINE");
    } else {
      // offline
      setStatus("OFFLINE");
    }
  }

  //THIS ONE IS FOR MAKE ROOM FOR CHATTING FOR ONLY B/W TWO USERS IN THIS ANYBODY MSG IN SAME ROOM LIKE USER-1 & USER-2
  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
      //IN THIS USER-1 MSG TO USER-2 IN ROOM-ID:1
    } else {
      return "$user2$user1";
      //IN THIS USER-2 MSG TO USER-1 IN ROOM-ID:1
    }
  }

  void onSearch() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    setState(() {
      isLoading = true;
    });


    //WHERE = IS USE FOR SEARCHING USER'S EMAIL AND CHACKING EQUALITY FROM 'USERS' COLLECTION OF FIRESTORE
    //GET() = ITS FOR GETTING
    await _firestore
        .collection('users')
        .where("email", isEqualTo: _search.text)
        .get()
        .then((value) {
      //FROM THIS WE SEE THE CHANGES INTO OUR APP
      setState(() {
        //DOCS[0] = IT FIRST CONVERT INTO THE LIST AND [0] GIVE THE LISTS FIRST ELEMENT
        //data() = IT CONVERST HERE INTO MAP...
        userMap = value.docs[0].data();
        isLoading = false;
      });
      print(userMap);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    //UI OF HOME SCREEN IN WHICH WE SEARCH THE USERS
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("CHATTING")),
        actions: [
          IconButton(icon: Icon(Icons.logout), onPressed: () => logOut(context))
        ],
      ),
      body: isLoading
          ? Center(
              child: Container(
                height: size.height / 20,
                width: size.height / 20,
                child: CircularProgressIndicator(),
              ),
            )
          : Column(
              children: [
                SizedBox(
                  height: size.height / 20,
                ),
                Container(
                  height: size.height / 14,
                  width: size.width,
                  alignment: Alignment.center,
                  child: Container(
                    height: size.height / 14,
                    width: size.width / 1.15,
                    child: TextField(
                      controller: _search,
                      decoration: InputDecoration(
                        hintText: "Search",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height / 50,
                ),
                ElevatedButton(
                  onPressed: onSearch,
                  child: Text("SEARCH"),
                ),
                SizedBox(
                  height: size.height / 30,
                ),
                userMap != null
                    ? ListTile(
                        onTap: () {
                          String roomId = chatRoomId(
                              _auth.currentUser!.displayName!,
                              userMap!['name']);

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChatRoom(
                                chatRoomId: roomId,
                                //PASSING THE  USER INFO ....
                                userMap: userMap!,
                              ),
                            ),
                          );
                        },
                        leading: Icon(Icons.account_box, color: Colors.black),
                        title: Text(
                          userMap!['name'],
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(userMap!['email']),
                        trailing: Icon(Icons.chat, color: Colors.black),
                      )
                    : Container(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.group),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GroupChatHomeScreen(),
          ),
        ),
      ),
    );
  }
}
