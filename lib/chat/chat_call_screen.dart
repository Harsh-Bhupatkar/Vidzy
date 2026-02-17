import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


import '../chat/call_signaling.dart';
import '../common/video/zego_meeting_methods.dart';

class ChatCallScreen extends StatefulWidget {
  final String callId;

  const ChatCallScreen({
    super.key,
    required this.callId,
  });

  @override
  State<ChatCallScreen> createState() => _ChatCallScreenState();
}

class _ChatCallScreenState extends State<ChatCallScreen> {
  final CallSignaling _callSignaling = CallSignaling();
  final user = FirebaseAuth.instance.currentUser!;

  @override
  void dispose() {
    // 🔥 Cleanup call when user leaves call screen
    _callSignaling.endCall(widget.callId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ZegoMeetingMethods().startMeeting(
          context: context,
          meetingId: widget.callId, // 🔑 callId = roomId
          userId: user.uid,
          userName: user.displayName ?? "User",
          isHost: false, // host logic not needed for Part 1
        ),
      ),
    );
  }
}
