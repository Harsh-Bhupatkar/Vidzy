import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vidzy_app/chat/call_signaling.dart';
import 'package:vidzy_app/chat/incoming_call_screen.dart';
import 'package:vidzy_app/chat/user_repository.dart';

class IncomingCallHandler extends StatelessWidget {
  final Widget child;
  IncomingCallHandler({super.key, required this.child});

  final CallSignaling _callSignaling = CallSignaling();
  final UserRepository _userRepo = UserRepository();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _callSignaling.listenIncomingCalls(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final callDoc = snapshot.data!.docs.first;
          final data = callDoc.data() as Map<String, dynamic>;
          final callerId = data['initiatorId'];

          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final user = await _userRepo.getUser(callerId);
            final callerName = user?['username'] ?? 'User';

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => IncomingCallScreen(
                  callId: callDoc.id,
                  callerName: callerName,
                ),
              ),
            );
          });
        }

        return child;
      },
    );
  }
}
