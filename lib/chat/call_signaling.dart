import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CallSignaling{
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  //start a call
  Future<String> startCall({
    required String chatId,
    required List<String> receiverIds,
  })async{
    final callRef = _firestore.collection('calls').doc();

    await callRef.set({
      'chatId':chatId,
      'initiatorId' : _uid,
      'receiverIds' : receiverIds,
      'status':'ringing',
      'createdAt':FieldValue.serverTimestamp()
    });
    return callRef.id;
  }

  //Accept call

  Future<void> acceptCall(String callId) async{
    await _firestore.collection('calls').doc(callId).update({'status':'accepted'});
  }

  //Reject a call
  Future<void> rejectCall(String callId) async{
    await _firestore.collection('calls').doc(callId).update({'status':'rejected'});
  }

  //End a call
  Future<void> endCall(String callId) async{
    await _firestore.collection('calls').doc(callId).delete();
  }

  Stream<QuerySnapshot> listenIncomingCalls(){
    return _firestore
        .collection('calls')
        .where('receiverIds',arrayContains: _uid)
        .where('status',isEqualTo: 'ringing')
        .snapshots();
  }
}