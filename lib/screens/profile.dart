import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:panigale/custom.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser!;
  String? _name;
  @override
  void initState(){
    super.initState();
    _getCurrentUserName();
  }

  Future<void> _getCurrentUserName() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid.toString();

    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    String name = userSnapshot.get('Name');

    setState(() {
      _name = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text('User Details',style: TextStyle(color:blacksavvy,fontSize: 30,fontWeight: FontWeight.bold),),
            const SizedBox(height: 20,),
            Row(
              children: [
                Text("Name :",style: TextStyle(color:greensavvy,fontWeight: FontWeight.bold,fontSize: 25),),
                const SizedBox(width: 5,),
                Text(_name.toString(),style: TextStyle(color: blacksavvy,fontWeight: FontWeight.bold,fontSize: 20),),
              ],
            ),
            const SizedBox(height: 10,),
            Row(
              children: [
                Text("Email :",style: TextStyle(color:greensavvy,fontWeight: FontWeight.bold,fontSize: 25),),
                const SizedBox(width: 5),
                Text(user.email!,style: TextStyle(color: blacksavvy,fontWeight: FontWeight.bold,fontSize: 20),),
              ],
            ),
          ],
        ),
      ),
    );
  }
}