import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vidzy_app/meeting/video_call_screen.dart';
import '../widgets/home_meeting_button.dart';
import 'meeting_firestore.dart';

class MeetingScreen extends StatelessWidget {
  MeetingScreen({super.key});

  void createNewMeeting(BuildContext context) async {
    final meetingId =
    (Random().nextInt(90000000) + 10000000).toString();

    await FirestoreMethods().createMeeting(
      meetingId: meetingId,
      title: "External Meeting",
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoCallScreen(
          meetingId: meetingId,
          isHost: true,
        ),
      ),
    );
  }


  void joinMeeting(BuildContext context)
  {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VideoCallScreen(),)
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            HomeMeetingButton(
                onPressed: () {
                  createNewMeeting(context);
                },
                icon: Icons.videocam,
                text: "New Meeting"),
            HomeMeetingButton(
                onPressed: ()=>joinMeeting(context),
                icon: Icons.add_box_rounded,
                text: "Join Meeting"),
            // HomeMeetingButton(
            //     onPressed: () {
            //
            //     },
            //     icon: Icons.arrow_upward,
            //     text: "Share Screen"),

          ],
        ),
        const Expanded(
            child: Center(
              child: Text("Create/Join a meeting with just a click!", style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18
              )),
            ))

      ],
    );
  }
}
