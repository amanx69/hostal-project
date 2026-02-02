

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/auth/screen/BodingScreen.dart';
import 'package:frontend/helper/Fonts.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    //! Delay for 3 seconds before navigating
    Timer(Duration(seconds: 3), () {
        Navigator.pushReplacement(
    context,
    CupertinoPageRoute(builder: (context) => OnBoardingPage()),
  );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Icon(Icons.connect_without_contact_outlined, size: 100, color: Colors.white),
              SizedBox(height: 20.h),
              // App Name
              Text(
                "Narrow",
                style: Customfonts.splash
              ),
              SizedBox(height: 15.h),
              // Tagline
              Text(
                "We Change The World ",
                style: Customfonts.splash
              ),
              SizedBox(height: 30.h),
              
            ],
          ),
        ),
      ),
    );
  }
}