import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatFirestore{
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  //generating chatId for 1 to 1 chat

  String generateChatId(String otherUserId){
    final ids = [_uid,otherUserId] .. sort();
    return ids.join('_');
  }

  // create or get existing chat
  // Future<String> createOrGetChat(String otherUserId) async{
  //   final chatId = generateChatId(otherUserId);
  //   final chatRef = _firestore.collection('chats').doc(chatId);
  //
  //   final doc = await chatRef.get();
  //   if(!doc.exists){
  //     await chatRef.set({
  //       'participants':[_uid,otherUserId],
  //       'isGroup':false,
  //       'createdAt': FieldValue.serverTimestamp(),
  //       'lastMessage':  '',
  //       'lastMessageAt': FieldValue.serverTimestamp(),
  //     });
  //   }
  //   return chatId;
  // }

  Future<String> createOrGetChat(String otherUserId) async {
    final chatId = generateChatId(otherUserId);
    final chatRef = _firestore.collection('chats').doc(chatId);

    final doc = await chatRef.get();
    if (!doc.exists) {
      await chatRef.set({
        'participants': [_uid, otherUserId],
        'isGroup': false,
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'unreadCount': {
          _uid: 0,
          otherUserId: 0,
        },
      });
    }
    return chatId;
  }


  // create group chat
//   Future<String> createGroupChat({
//     required String groupName,
//     required List<String> memberIds,
// }) async{
//     final chatRef = _firestore.collection('chats').doc();
//
//     await chatRef.set({
//       'participants': [...memberIds, _uid],
//       'isGroup': true,
//       'groupName': groupName,
//       'createdBy': _uid,
//       'createdAt': FieldValue.serverTimestamp(),
//       'lastMessage': '',
//       'lastMessageAt': FieldValue.serverTimestamp(),
//     });
//     return chatRef.id;
//   }

  // Future<String> createGroupChat({
  //   required String groupName,
  //   required List<String> memberIds,
  // }) async {
  //   final chatRef = _firestore.collection('chats').doc();
  //
  //   // 🔥 Build unreadCount map dynamically
  //   final Map<String, int> unreadCount = {
  //     for (final uid in [...memberIds, _uid]) uid: 0,
  //   };
  //
  //   await chatRef.set({
  //     'participants': [...memberIds, _uid],
  //     'isGroup': true,
  //     'groupName': groupName,
  //     'createdBy': _uid,
  //     'createdAt': FieldValue.serverTimestamp(),
  //     'lastMessage': '',
  //     'lastMessageAt': FieldValue.serverTimestamp(),
  //     'unreadCount': unreadCount,
  //   });
  //
  //   return chatRef.id;
  // }


//   //send message
//   Future<void> sendMessage({
//     required String chatId,
//     required String text,
// })async {
//     final msgRef = _firestore
//         .collection('chats')
//         .doc(chatId)
//         .collection('messages')
//         .doc();
//
//     await msgRef.set({
//       'senderId':_uid,
//       'text':text,
//       'createdAt':FieldValue.serverTimestamp()
//     });
//
//     await _firestore.collection('chats').doc(chatId).update({
//       'lastMessage':text,
//       'lastMessageAt':FieldValue.serverTimestamp()
//     });
//   }
  Future<void> sendMessage({
    required String chatId,
    required String message,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    // 🔹 Fetch chat document
    final chatDoc = await firestore.collection('chats').doc(chatId).get();
    final data = chatDoc.data()!;

    final List participants = data['participants'];

    // 🔹 Derive receiver UID SAFELY
    final receiverUid =
    participants.firstWhere((uid) => uid != currentUid);

    // 🔹 Add message
    await firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': currentUid,
      'text': message,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 🔹 Update chat metadata + unread count
    await firestore.collection('chats').doc(chatId).update({
      'lastMessage': message,
      'lastMessageAt': FieldValue.serverTimestamp(),

      // 🔥 increment receiver unread count safely
      'unreadCount.$receiverUid': FieldValue.increment(1),
    });
  }

  Future<void> markChatAsRead(String chatId) async{
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
    .collection('chats')
    .doc(chatId)
    .update({'unreadCount.$uid':0});
  }

  //Stream messages
  Stream<QuerySnapshot> streamMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots();
  }

  //Stream user chats
  Stream<QuerySnapshot> streamUserChats(){
    return _firestore
        .collection('chats')
        .where('participants',arrayContains: _uid)
        .orderBy('lastMessageAt',descending: true)
        .snapshots();
  }

}