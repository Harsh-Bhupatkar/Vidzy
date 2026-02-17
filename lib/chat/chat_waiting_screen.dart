import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vidzy_app/chat/call_signaling.dart';
import 'package:vidzy_app/meeting/video_call_screen.dart';

import 'chat_call_screen.dart';

class CallWaitingScreen extends StatefulWidget {
  final String callId;

  const CallWaitingScreen({
    super.key,
    required this.callId,
  });

  @override
  State<CallWaitingScreen> createState() => _CallWaitingScreenState();
}

class _CallWaitingScreenState extends State<CallWaitingScreen> {
  final CallSignaling _callSignaling = CallSignaling();
  late final Stream<DocumentSnapshot> _callStream;

  @override
  void initState() {
    super.initState();
    _callStream = FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.callId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<DocumentSnapshot>(
        stream: _callStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return _waitingUI("Calling…");
          }

          // Call rejected / ended
          if (!snapshot.data!.exists) {
            Future.microtask(() {
              Navigator.pop(context);
            });
            return const SizedBox.shrink();
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final status = data['status'];

          if (status == 'accepted') {
            Future.microtask(() {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatCallScreen(callId: widget.callId),
                ),
              );
            });
          }

          return _waitingUI("Waiting for user to accept…");
        },
      ),
    );
  }

  Widget _waitingUI(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 24),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              await _callSignaling.endCall(widget.callId);
              Navigator.pop(context);
            },
            child: Icon(Icons.call_end,color: Colors.white,size: 20,),
          ),
        ],
      ),
    );
  }
}
