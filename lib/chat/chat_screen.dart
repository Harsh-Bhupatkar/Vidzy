import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../meeting/video_call_screen.dart';
import 'call_signaling.dart';
import 'chat_firestore.dart';
import 'chat_waiting_screen.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final bool isGroup;
  final String title;
  final String? otherUserId;

  const ChatScreen({
    Key? key,
    required this.chatId,
    required this.isGroup,
    required this.title,
    this.otherUserId,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatFirestore _chatFirestore = ChatFirestore();
  final TextEditingController _messageController = TextEditingController();
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;
  final CallSignaling _callSignaling = CallSignaling();


  @override
  void initState() {
    super.initState();
    _ensureChatExists();
    _chatFirestore.markChatAsRead(widget.chatId);
  }

  Future<void> _ensureChatExists() async {
    if (!widget.isGroup && widget.otherUserId != null) {
      await ChatFirestore().createOrGetChat(widget.otherUserId!);
    }
  }


  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    await _chatFirestore.sendMessage(
      chatId: widget.chatId,
      message: text,

    );

    _messageController.clear();
  }

  void _listenForCallAccepted(String callId) {
    FirebaseFirestore.instance
        .collection('calls')
        .doc(callId)
        .snapshots()
        .listen((doc) {
      if (!doc.exists) return;

      final status = doc['status'];
      if (status == 'accepted') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoCallScreen(
              meetingId: callId,
              isHost: true,
            ),
          ),
        );
      }
    });
  }


  Future<void> _startCall() async{
    final chatDoc = await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .get();

    final data = chatDoc.data()!;
    final List<String> participants =
    List<String>.from(data['participants']);

    // Remove self from receivers
    final receiverIds =
    participants.where((id) => id != currentUid).toList();

    if (receiverIds.isEmpty) return;

    final callId = await _callSignaling.startCall(
      chatId: widget.chatId,
      receiverIds: receiverIds,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallWaitingScreen(callId: callId),
      ),
    );


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () async{
              await _startCall();
            },
          )
        ],
      ),
      body: Column(
        children: [
          /// Messages list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatFirestore.streamMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No messages yet"),
                  );
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data =
                    messages[index].data() as Map<String, dynamic>;

                    final isMe = data['senderId'] == currentUid;

                    return Align(
                      alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.blueAccent
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          data['text'],
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          /// Message input
          SafeArea(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


