import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guest_notification/utils/shared_pref_helper.dart';

import 'main_drawer.dart';
import 'models/guest_model.dart';

class NotificationScreen extends StatefulWidget {
  NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  GuestModel? guest;

  @override
  void initState() {
    super.initState();
    fetchGuestDetails();
  }

  // Fetch guest details from Firestore
  Future<void> fetchGuestDetails() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('guests')
        .doc(SharedPrefHelper.getUserId())
        .get();

    if (doc.exists) {
      setState(() {
        guest = GuestModel.fromFirestore(doc.data() as Map<String, dynamic>);
      });
    }
  }

  // Store the user response (Allow, Decline, Always Allow) in Firestore
  void storeResponse(String response) {
    FirebaseFirestore.instance.collection('logs').add({
      'guestId': SharedPrefHelper.getUserId(),
      'timestamp': DateTime.now(),
      'status': response,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Guest Notification")),
      drawer: MainDrawer(),
      body: guest == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Guest Details
                Center(
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(guest!.profilePictureUrl),
                    radius: 50,
                  ),
                ),
                Text(guest!.name, style: TextStyle(fontSize: 24)),
                Text(guest!.email, style: TextStyle(fontSize: 16)),
                Text(guest!.mobile, style: TextStyle(fontSize: 16)),

                SizedBox(height: 40),

                // Allow, Decline, Always Allow Buttons
                ElevatedButton(
                  onPressed: () {
                    storeResponse('Allow');
                  },
                  child: Text("Allow"),
                ),
                ElevatedButton(
                  onPressed: () {
                    storeResponse('Decline');
                  },
                  child: Text("Decline"),
                ),
                ElevatedButton(
                  onPressed: () {
                    storeResponse('Always Allow');
                  },
                  child: Text("Always Allow"),
                ),
              ],
            ),
    );
  }
}
