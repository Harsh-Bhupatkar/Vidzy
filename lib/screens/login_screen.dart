import 'package:flutter/material.dart';
import 'package:vidzy_app/auth/auth_methods.dart';
import 'package:vidzy_app/screens/home_screen.dart';
import 'package:vidzy_app/widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final AuthMethods _authMethods = AuthMethods();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 10,
        children: [
          Text("Start or join a meeting",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24
              )),
          Image.asset("assets/images/onboarding.png"),
          CustomButton(
              text: "Google Sign In",
              onPressed: () async{
                bool res = await _authMethods.signInWithGoogle(context);
                if(res)
                  {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen(),));
                    // Navigator.pushNamed(context, '/home');

                  }
              },
          )

          
        ],
      ),
    );
  }
}
