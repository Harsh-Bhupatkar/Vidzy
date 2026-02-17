import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_video_conference/zego_uikit_prebuilt_video_conference.dart';

import '../../utils/zego_config.dart';

class ZegoMeetingMethods {
  Widget startMeeting({
    required BuildContext context,
    required String meetingId,
    required String userId,
    required String userName,
    required bool isHost,
  }) {
    return  SafeArea(
      child: ZegoUIKitPrebuiltVideoConference(
          appID: ZegoConfig.appId,
          appSign: ZegoConfig.appDesign,
          conferenceID: meetingId,
          userID: userId,
          userName: userName,
          config: ZegoUIKitPrebuiltVideoConferenceConfig(
            turnOnCameraWhenJoining: true,
            turnOnMicrophoneWhenJoining: true,
          ),
      ),
    );
  }
}
