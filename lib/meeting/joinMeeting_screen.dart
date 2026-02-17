import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../common/video/zego_meeting_methods.dart';

class InMeetingWrapper extends StatelessWidget {
  final BuildContext context;
  final String meetingId;
  final String uid;
  const InMeetingWrapper({super.key, required this.context, required this.meetingId, required this.uid});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12,vertical: 8),
              height: 35,
              color: Colors.black87,
              child: Row(
                children: [
                  Expanded(child: Text("Meeting Id: ${meetingId}",style: TextStyle(color: Colors.white),)),
                  IconButton(onPressed: (){
                    Clipboard.setData(ClipboardData(text: meetingId.toString()));
                  }, icon: Icon(Icons.copy,color: Colors.white,size: 18,)),
                  IconButton(onPressed: (){
                    SharePlus.instance.share(ShareParams(text: "Join meeting \n Meeting Id: ${meetingId}"));
                  }, icon: Icon(Icons.share,color: Colors.white,size: 18,)),



                ],
              ),
            ),
            Expanded(
              child: ZegoMeetingMethods().startMeeting(
                context: context,
                meetingId: meetingId,
                userId: uid,
                userName:
                FirebaseAuth.instance.currentUser!
                    .displayName ??
                    "User",
                isHost: false,
              ),
            )
          ],
        ),
      ),
    );
  }
}
