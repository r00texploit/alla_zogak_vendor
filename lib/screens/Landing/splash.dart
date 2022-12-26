import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen> {
  @override
  initState() {
    initApp();
    super.initState();
  }

  initApp() async {
    final sh = await SharedPreferences.getInstance();
    if (sh.getString("token") != null) {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, "home");
      });
    } else {
      Future.delayed(const Duration(seconds: 5), () {
        Navigator.pushReplacementNamed(context, "login");
      });
    }
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/logo.png",
              width: MediaQuery.of(context).size.width / 2,
            ),
            Text(
              "تاجر",
            style:GoogleFonts.amiri(fontSize: 50,),
              
              ),
            const Divider(thickness: 5,color: Colors.yellow,indent: 130,endIndent: 130,)
          ],
        ),
      ),
    );
  }
}
