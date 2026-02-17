import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vidzy_app/auth/auth_methods.dart';
import 'package:vidzy_app/chat/incoming_call_handler.dart';
import 'package:vidzy_app/screens/home_screen.dart';
import 'package:vidzy_app/screens/login_screen.dart';
import 'package:vidzy_app/meeting/video_call_screen.dart';
import 'package:vidzy_app/utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Vidzy",
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundColor
      ),
      // routes: {
      //   '/login': (context) => const LoginScreen(),
      //   '/home' : (context) => const HomeScreen(),
      //   '/video-call' : (context) => const VideoCallScreen(),
      //
      // },
      home: StreamBuilder(
          stream: AuthMethods().authChanges,
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting)
              {
                return Center(child: CircularProgressIndicator(),);
              }
            if(snapshot.hasData)
              {
                return IncomingCallHandler(child: const HomeScreen());
              }
            return const LoginScreen();
          },),
    );
  }
}


