import 'dart:developer';


import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/auth/screen/BodingScreen.dart';
import 'package:frontend/auth/screen/IntroScreen.dart';
import 'package:frontend/helper/Theme.dart';
import 'package:frontend/screens/BottonNavi.dart';
import 'package:introduction_screen/introduction_screen.dart';






void main() async{

  runApp(  ProviderScope(child: MyApp()));

}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(390, 844),
      builder: (context, child) {
        return MaterialApp(
          
          // darkTheme: AppTheme.darkTheme,
          // theme: AppTheme.lightTheme,
          
     
          debugShowCheckedModeBanner:  false,
          home: OnBoardingPage(),
        );
      },
    );
  }
}