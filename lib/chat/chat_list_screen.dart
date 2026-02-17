import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vidzy_app/chat/user_search_screen.dart';
import 'user_repository.dart';
import 'chat_firestore.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  ChatListScreen({Key? key}) : super(key: key);

  final ChatFirestore _chatFirestore = ChatFirestore();
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;
  final UserRepository _userRepo = UserRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const UserSearchScreen(),
                ),
              );
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _chatFirestore.streamUserChats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No chats yet",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chatDoc = chats[index];
              final data = chatDoc.data() as Map<String, dynamic>;

              final bool isGroup = data['isGroup'] ?? false;
              final List participants =
              List<String>.from(data['participants']);

              /// For 1-to-1 chat, find the other user
              String title;
              if (isGroup) {
                title = data['groupName'] ?? "Group";
              } else {
                title = participants.firstWhere(
                      (id) => id != currentUid,
                  orElse: () => "Unknown",
                );
              }

              final lastMessage = data['lastMessage'] ?? '';
              final Timestamp? timeStamp = data['lastMessageAt'];

              return FutureBuilder(
                future: isGroup
                    ? Future.value({'username': title})
                    : _userRepo.getUser(
                  participants.firstWhere((id) => id != currentUid),
                ),
                builder: (context, userSnapshot) {
                  final name = userSnapshot.data?['username'] ?? "User";

                  final unread =
                  (data['unreadCount'] != null)
                      ? (data['unreadCount'][currentUid] ?? 0)
                      : 0;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: userSnapshot.data?['profilePhoto'] != null
                          ? NetworkImage(userSnapshot.data!['profilePhoto'])
                          : null,
                      child: userSnapshot.data?['profilePhoto'] == null
                          ? Text(name[0])
                          : null,
                    ),
                    title: Text(name),
                    subtitle: Text(lastMessage),
                    trailing: unread > 0
                        ? CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.green,
                      child: Text(
                        unread.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    )
                        : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            chatId: chatDoc.id,
                            isGroup: isGroup,
                            title: name,
                            otherUserId: isGroup
                                ? null
                                : participants.firstWhere((id) => id != currentUid),
                          ),
                        ),
                      );
                    },
                  );

                  // return ListTile(
                  //   leading: CircleAvatar(
                  //     backgroundImage: userSnapshot.data?['profilePhoto'] != null
                  //         ? NetworkImage(userSnapshot.data!['profilePhoto'])
                  //         : null,
                  //     child: userSnapshot.data?['profilePhoto'] == null
                  //         ? Text(name[0])
                  //         : null,
                  //   ),
                  //   title: Text(name),
                  //   subtitle: Text(lastMessage),
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (_) => ChatScreen(
                  //           chatId: chatDoc.id,
                  //           isGroup: isGroup,
                  //           title: name,
                  //         ),
                  //       ),
                  //     );
                  //   },
                  // );
                },
              );


              // return ListTile(
              //   leading: CircleAvatar(
              //     child: Icon(isGroup ? Icons.group : Icons.person),
              //   ),
              //   title: Text(
              //     title,
              //     maxLines: 1,
              //     overflow: TextOverflow.ellipsis,
              //   ),
              //   subtitle: Text(
              //     lastMessage,
              //     maxLines: 1,
              //     overflow: TextOverflow.ellipsis,
              //   ),
              //   trailing: timeStamp != null
              //       ? Text(
              //     _formatTime(timeStamp),
              //     style: const TextStyle(fontSize: 12),
              //   )
              //       : null,
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (_) => ChatScreen(
              //           chatId: chatDoc.id,
              //           isGroup: isGroup,
              //           title: title,
              //         ),
              //       ),
              //     );
              //   },
              // );
            },
          );
        },
      ),
    );
  }

  String _formatTime(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();

    if (now.difference(date).inDays == 0) {
      return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } else {
      return "${date.day}/${date.month}/${date.year}";
    }
  }
}
