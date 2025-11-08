import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/auth/screen/IntroScreen.dart';
import 'package:frontend/helper/Theme.dart';




void main() {
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
          
          darkTheme: AppTheme.darkTheme,
          theme: AppTheme.lightTheme,
          
     
          debugShowCheckedModeBanner:  false,
          home: SplashScreen(),
        );
      },
    );
  }
}