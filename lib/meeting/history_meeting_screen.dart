import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


import 'meeting_firestore.dart';

class HistoryMeetingScreen extends StatelessWidget {
  const HistoryMeetingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirestoreMethods().externalMeetingsHistory,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No meetings yet"),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final data = snapshot.data!.docs[index].data();

            final isHost = data['hostId'] == uid;
            final createdAt =
            (data['createdAt'] as Timestamp).toDate();

            final endedAt = data['endedAt'] != null
                ? (data['endedAt'] as Timestamp).toDate()
                : null;

            final duration = endedAt != null
                ? endedAt.difference(createdAt).inMinutes
                : null;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  data['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Host: ${data['hostName']}"),
                    Text(
                      "Date: ${DateFormat.yMMMd().format(createdAt)}",
                    ),
                    if (duration != null)
                      Text("Duration: $duration mins"),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isHost ? "Host" : "Participant",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isHost
                            ? Colors.green
                            : Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data['status'] == 'ended'
                          ? "Ended"
                          : "Active",
                      style: TextStyle(
                        color: data['status'] == 'ended'
                            ? Colors.red
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
