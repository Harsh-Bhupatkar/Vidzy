import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chat_firestore.dart';
import 'chat_screen.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({Key? key}) : super(key: key);

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ChatFirestore _chatFirestore = ChatFirestore();
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;

  String searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Start new chat"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: "Search by username",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value.trim();
                });
              },
            ),
          ),

          Expanded(
            child: searchText.isEmpty
                ? const Center(
              child: Text("Type a name to search"),
            )
                : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('username', isGreaterThanOrEqualTo: searchText)
                  .where('username', isLessThan: searchText + 'z')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                final users = snapshot.data!.docs
                    .where((doc) => doc.id != currentUid)
                    .toList();

                if (users.isEmpty) {
                  return const Center(
                    child: Text("No users found"),
                  );
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final data =
                    users[index].data() as Map<String, dynamic>;
                    final uid = users[index].id;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: data['profilePhoto'] != null
                            ? NetworkImage(data['profilePhoto'])
                            : null,
                        child: data['profilePhoto'] == null
                            ? Text(data['username'][0])
                            : null,
                      ),
                      title: Text(data['username']),
                      subtitle: Text(data['email'] ?? ''),
                      onTap: () async {
                        final chatId =
                        await _chatFirestore.createOrGetChat(uid);

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              chatId: chatId,
                              isGroup: false,
                              title: data['username'],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
