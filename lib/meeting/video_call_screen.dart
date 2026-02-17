import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vidzy_app/auth/auth_methods.dart';
import 'package:vidzy_app/common/video/zego_meeting_methods.dart';
import 'package:vidzy_app/meeting/waiting_screen.dart';
import 'package:vidzy_app/utils/colors.dart';
import 'package:vidzy_app/chat/call_signaling.dart';



class VideoCallScreen extends StatefulWidget {

  final String? meetingId;
  final bool isHost;
  const VideoCallScreen({
    super.key,
    this.meetingId,
    this.isHost = false,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final AuthMethods _authMethods = AuthMethods();
  late TextEditingController meetingIdController;
  StreamSubscription<DocumentSnapshot>? _removeListener;
 // late TextEditingController nameController;
  //final JitsiMeetMethods _jitsiMeetMethods = JitsiMeetMethods();
  //bool isAudioMuted = true;
  //bool isVideoMuted = true;

  @override
  void initState() {
    super.initState();
    meetingIdController = TextEditingController();

    if (widget.meetingId != null) {
      _registerParticipant();

      if (!widget.isHost) {
        _listenForRemoval();
      }
    }
  }


  @override
  void dispose() {
    meetingIdController.dispose();
    _removeListener ?.cancel();
    _removeParticipant();

    super.dispose();

    //nameController.dispose();
   //JitsiMeet.removeAllListeners();
  }

  void _registerParticipant() {
    final user = FirebaseAuth.instance.currentUser!;
    FirebaseFirestore.instance
        .collection('meet')
        .doc(widget.meetingId)
        .collection('waiting')
        .doc(user.uid)
        .set({
      'name': user.displayName ?? (widget.isHost ? "Host" : "User"),
      'isHost': widget.isHost,
      'approved': widget.isHost, // 👈 IMPORTANT
      'joinedAt': FieldValue.serverTimestamp(),
    });
  }


  void _listenForRemoval() {
    final user = FirebaseAuth.instance.currentUser!;
    _removeListener = FirebaseFirestore.instance
        .collection('meet')
        .doc(widget.meetingId)
        .collection('waiting')
        .doc(user.uid)
        .snapshots()
        .listen((doc) {
      if (!doc.exists) {
        _handleRemoved();
      }
    });
  }


  void _handleRemoved(){
    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("You were remvoed by the host", style: TextStyle())
      )
    );
    Navigator.pop(context);
  }

  void _removeParticipant() {
    final user = FirebaseAuth.instance.currentUser!;
    FirebaseFirestore.instance
        .collection('meet')
        .doc(widget.meetingId)
        .collection('waiting')
        .doc(user.uid)
        .delete();
  }




  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: widget.isHost?null:AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        title: Text("Join a meeting", style: TextStyle(fontSize: 18)),
        centerTitle: true,

      ),
      body: SafeArea(
          child: Column(
            children: [
              widget.isHost?_meetingHeader(context):SizedBox.shrink(),
              Expanded(
                child:  widget.isHost?
                   Stack(
                     children: [
                       ZegoMeetingMethods().startMeeting(
                       context: context,
                       meetingId: widget.meetingId!,
                       userId: user.uid,
                       userName: user.displayName??"Host",
                       isHost: true),
                       StreamBuilder<QuerySnapshot>(
                           stream: FirebaseFirestore.instance
                           .collection('meet')
                           .doc(widget.meetingId)
                           .collection('waiting')
                           .where('approved',isEqualTo: false)
                           .snapshots(),
                           builder: (context, snapshot) {
                             if(!snapshot.hasData || snapshot.data!.docs.isEmpty)
                               {
                                 return const SizedBox.shrink();
                               }
                             return Positioned(
                                 bottom: 120,
                                 left: 12,
                                 right: 12,
                                 child: Card(
                                   margin: EdgeInsets.all(12),
                                   child: Column(
                                     mainAxisSize: MainAxisSize.min,
                                     children: snapshot.data!.docs.map((doc) {
                                       return ListTile(
                                         title: Text(doc['name'], style: TextStyle()),
                                         trailing: Row(
                                           mainAxisSize: MainAxisSize.min,
                                           children: [
                                             IconButton(onPressed: () async => await doc.reference.delete() , icon: Icon(Icons.close,color: Colors.red,)),
                                             IconButton(onPressed: ()  =>  doc.reference.update({'approved':true}) , icon: Icon(Icons.check,color: Colors.white,))

                                           ],
                                         ),
                                       );
                                     },).toList(),
                                   ),
                                 )
                             );
                           },)
                     ],
                   )
                  :
                Column(

                  children: [
                    SizedBox(height: 10,),
                    SizedBox(height: 60,
                      child: TextField(
                        controller: meetingIdController,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            fillColor: secondaryBackgroundColor,
                            hintText: "Enter meeting id here..",
                            filled: true,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.fromLTRB(16, 8, 0, 0)
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    ElevatedButton(
                        onPressed: () async {
                          final meetingId = meetingIdController.text.trim();
                          final uid = user.uid;
                          await FirebaseFirestore.instance
                              .collection('meet')
                              .doc(meetingId)
                              .collection('waiting')
                              .doc(uid)
                              .set({
                            'name':user.displayName??"User",
                            "isHost" : false,
                            'approved': false,
                            'joinedAt':FieldValue.serverTimestamp()
                          });
                          Navigator.push(context, MaterialPageRoute(builder: (context) => WaitingRoomScreen(meetingId: meetingId),));
                        },
                        child: Text("Join", style: TextStyle(color: Colors.white))
                    ),
                  ],
                ),

              )


            ],
          )
      ),
    );
  }
  
  Widget _meetingHeader(BuildContext context)
  {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12,vertical: 8),
      height: 35,
      color: Colors.black87,
      child: Row(
        children: [
          Expanded(child: Text("Meeting Id: ${widget.meetingId}",style: TextStyle(color: Colors.white),)),
          IconButton(onPressed: (){
            Clipboard.setData(ClipboardData(text: widget.meetingId.toString()));
          }, icon: Icon(Icons.copy,color: Colors.white,size: 18,)),
          IconButton(onPressed: (){
            SharePlus.instance.share(ShareParams(text: "Join meeting \n Meeting Id: ${widget.meetingId}"));
          }, icon: Icon(Icons.share,color: Colors.white,size: 18,)),
          widget.isHost? IconButton(onPressed:_openParticipantsSheet, icon: Icon(Icons.group,color: Colors.white,size: 18,)):SizedBox(width: 0,height: 0,),


        ],
      ),
    );
  }
  void _openParticipantsSheet(){
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (context) => _ParticipantSheet(meetingId:widget.meetingId.toString()),);
  }
}


class _ParticipantSheet extends StatelessWidget {
  final String meetingId;
  const _ParticipantSheet({super.key, required this.meetingId});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Participants", style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
          SizedBox(height: 16,),
          //waiting users
          StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
              .collection('meet')
              .doc(meetingId)
              .collection('waiting')
              .where('approved',isEqualTo: false)
              .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Waiting for approval"),
                    ...snapshot.data!.docs.map((doc) {
                      return ListTile(
                        title: Text(doc['name']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => doc.reference.delete(),
                            ),
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () =>
                                  doc.reference.update({'approved': true}),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
          ),
          const Divider(),
          //joined participants
          // joined participants
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('meet')
                .doc(meetingId)
                .collection('waiting')
                .where('approved', isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("In Meeting"),
                  ...snapshot.data!.docs.map((doc) {
                    final isHost = doc['isHost'] == true;
                    if (isHost) {
                      return ListTile(
                        title: Text("${doc['name']} (Host)"),
                      );
                    }

                    return ListTile(
                      title: Text(doc['name']),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () async {
                          await doc.reference.delete();
                        },
                      ),
                    );
                  }).toList(),
                ],
              );
            },
          ),






        ],
      ),
    );
  }
}


