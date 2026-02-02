
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/auth/screen/LoginScreen.dart';
import 'package:frontend/helper/Fonts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lottie/lottie.dart';

class OnBoardingPage extends StatelessWidget {
  final List<PageViewModel> pages = [
    PageViewModel(
      titleWidget: Text("Hello!",style:GoogleFonts.poppins(fontSize: 25.sp,fontWeight: FontWeight.bold),),
      bodyWidget: Text("welcome to Narrow",style:GoogleFonts.poppins(fontSize: 22.sp,fontWeight: FontWeight.bold),),

      image: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(child:Lottie.asset("animation/three.json",height: 400,width: 400),),
      ),
    ),
    PageViewModel(
       titleWidget: Text("Let's Get Started",style:GoogleFonts.poppins(fontSize: 25.sp,fontWeight: FontWeight.bold),),
      bodyWidget: Text("Connect to Each Other today",style:GoogleFonts.poppins(fontSize: 22.sp,fontWeight: FontWeight.bold),),
    
      image: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(child: Lottie.asset("animation/two.json",height: 400,width: 400),),
      )
    ),
    PageViewModel(
            titleWidget: Text("Narrow!",style:GoogleFonts.poppins(fontSize: 25.sp,fontWeight: FontWeight.bold),),
      bodyWidget: Text("My purpose is  change the world",style:GoogleFonts.poppins(fontSize: 22.sp,fontWeight: FontWeight.bold),),

      image: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(child: Lottie.asset("animation/one.json",height: 400,width: 400),),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: pages,
      onDone: () {
        // When done button is pressed
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(builder: (_) => LoginScreen()),
        );
      },
      onSkip: () {
        // Skip button action
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(builder: (_) => LoginScreen()),
        );
      },
      showSkipButton: true,
      skip:  Text("Skip",style:Customfonts.ui1 ,),
      next: const Icon(Icons.arrow_forward),
      done:  Text("Done", style: Customfonts.ui1),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Colors.grey,
        activeSize: Size(22.0, 10.0),
        activeColor: Colors.blue,
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}