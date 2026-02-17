import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  
  /*-------------host-----------
  * i have set meet as meeting collection.
  * meetings collection is used for history purpose.
  *  */
  Future<void> createMeeting({
    required String meetingId,
    required String title,
  }) async {
    final user = _auth.currentUser!;

    await _firestore.collection('meetings').doc(meetingId).set({
      'meetingId': meetingId,
      'title': title,
      'hostId': user.uid,
      'hostName': user.displayName ?? 'Host',
      "participants":[user.uid],
      'type': 'external',
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
      'participantsCount': 1,
    });
  }


  Future<void> endMeeting(String meetingId) async {
    await _firestore.collection('meetings').doc(meetingId).update({
      'status': 'ended',
      'endedAt': FieldValue.serverTimestamp(),
    });
  }


  Stream<QuerySnapshot> getJoinRequests(String meetingId){
    return _firestore
        .collection('meet')
        .doc(meetingId)
        .collection('requests')
        .where('approved',isEqualTo: false)
        .snapshots();
  }

  // Future<void> approveUser(String meetingId, String userId) async{
  //   await _firestore
  //       .collection('meet')
  //       .doc(meetingId)
  //       .collection('requests')
  //       .doc(userId)
  //       .update({'approved':true});
  // }
  Future<void> approveUser(String meetingId, String userId) async {
    // 1️⃣ Approve the user
    await _firestore
        .collection('meet')
        .doc(meetingId)
        .collection('requests')
        .doc(userId)
        .update({'approved': true});

    // 2️⃣ ADD USER TO MEETING PARTICIPANTS (🔥 REQUIRED)
    await _firestore
        .collection('meetings')
        .doc(meetingId)
        .update({
      'participants': FieldValue.arrayUnion([userId]),
      'participantsCount': FieldValue.increment(1),
    });
  }


  /*----------participant----------*/
  Future<bool> meetingExists(String meetingId) async{
    final doc = await _firestore
        .collection('meet')
        .doc(meetingId)
        .get();
    return doc.exists && doc['status'] == 'active';
  }

  Future<void> requestToJoin(String meetingId, String name) async{
    await _firestore
        .collection('meet')
        .doc(meetingId)
        .collection('requests')
        .doc(_auth.currentUser!.uid)
        .set({'name':name,'approved':false,'joinedAt':FieldValue.serverTimestamp()});
  }

  Stream<DocumentSnapshot> listenApproval(String meetingId)
  {
    return _firestore
        .collection('meet')
        .doc(meetingId)
        .collection('requests')
        .doc(_auth.currentUser!.uid)
        .snapshots();
  }
  // Stream<QuerySnapshot<Map<String, dynamic>>> get meetingsHistory => _firestore
  //     .collection('users')
  //     .doc(_auth.currentUser!.uid)
  //     .collection('meetings')
  //     .snapshots();
  Stream<QuerySnapshot<Map<String, dynamic>>> get externalMeetingsHistory {
    final uid = _auth.currentUser!.uid;

    return _firestore
        .collection('meetings')
        .where('participants', arrayContains: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> addToMeetingHistory(String meetingName) async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('meetings')
          .add({
        'meetingName': meetingName,
        'createdAt': DateTime.now(),
      });
    } catch (e) {
      print(e);
    }
  }

}