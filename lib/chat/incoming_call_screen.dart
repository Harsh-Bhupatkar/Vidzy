import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:vidzy_app/chat/call_signaling.dart';
import 'package:vidzy_app/meeting/video_call_screen.dart';

import 'chat_call_screen.dart';

class IncomingCallScreen extends StatefulWidget {
  final String callId;
  final String callerName;
  const IncomingCallScreen({super.key, required this.callId, required this.callerName});

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {

  final CallSignaling _callSignaling = CallSignaling();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _vibrate();
  }

  Future<void> _vibrate() async{
    if(await Vibration.hasVibrator()??false)
      {
        Vibration.vibrate(
          pattern: [0, 800, 400, 800, 400, 800],
        );

      }
  }
  @override
  void dispose() {
    // TODO: implement dispose
    Vibration.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            Text(
              "${widget.callerName} is calling...",
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(24),
                  ),
                  onPressed: () async {
                    await _callSignaling.endCall(widget.callId);
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.call_end, color: Colors.white),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(24),
                  ),
                  onPressed: () async {
                    await _callSignaling.acceptCall(widget.callId);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatCallScreen(callId: widget.callId),
                      ),
                    );
                  },
                  child: const Icon(Icons.call, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// class IncomingCallScreen extends StatelessWidget {
//   final String callId;
//   final String callerName;
//
//   IncomingCallScreen({
//     super.key,
//     required this.callId,
//     required this.callerName,
//   });
//
//   final CallSignaling _callSignaling = CallSignaling();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.videocam, size: 80, color: Colors.white),
//             const SizedBox(height: 20),
//             Text(
//               "$callerName is calling…",
//               style: const TextStyle(color: Colors.white, fontSize: 20),
//             ),
//             const SizedBox(height: 40),
//
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.red,
//                     shape: const CircleBorder(),
//                     padding: const EdgeInsets.all(24),
//                   ),
//                   onPressed: () async {
//                     await _callSignaling.endCall(callId);
//                     Navigator.pop(context);
//                   },
//                   child: const Icon(Icons.call_end, color: Colors.white),
//                 ),
//
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     shape: const CircleBorder(),
//                     padding: const EdgeInsets.all(24),
//                   ),
//                   onPressed: () async {
//                     await _callSignaling.acceptCall(callId);
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => ChatCallScreen(callId: callId),
//                       ),
//                     );
//                   },
//                   child: const Icon(Icons.call, color: Colors.white),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
