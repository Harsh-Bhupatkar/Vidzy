import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../common/video/zego_meeting_methods.dart';
import 'joinMeeting_screen.dart';

class WaitingRoomScreen extends StatelessWidget {
  final String meetingId;

  const WaitingRoomScreen({
    super.key,
    required this.meetingId,
  });

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Waiting Room")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('meet')
            .doc(meetingId)
            .collection('waiting')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator());
          }
          if (!snapshot.data!.exists) {
            Future.microtask(() {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("You were rejected by the host")),
              );
              Navigator.pop(context);
            });
            return const SizedBox.shrink();
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final approved = data['approved'] ?? false;

          if (approved) {
            Future.microtask(() {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  InMeetingWrapper(context: context,meetingId: meetingId,uid: uid),
                )
              );
            });
          }

          return const Center(
            child: Text(
              "Waiting for host approval...",
              style: TextStyle(fontSize: 18),
            ),
          );
        },
      ),
    );
  }
}
