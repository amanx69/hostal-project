import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
 
 class AppTheme {
   
   //! in light  mode
    static ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
       scaffoldBackgroundColor: Colors.white, //! scaffold background color in light  mode
    primaryColor: Colors.blue,

    //!  app bar in light  mode
    appBarTheme: AppBarTheme(
       backgroundColor: Colors.white,
        titleTextStyle: GoogleFonts.poppins(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
        
      ),

     ),
     //! text themae 
      textTheme: TextTheme(
        
      displayLarge: GoogleFonts.poppins(fontSize: 24.sp, fontWeight: FontWeight.bold),
      headlineMedium: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.w600),
      bodyMedium: GoogleFonts.openSans(fontSize: 16.sp),
      bodySmall: GoogleFonts.openSans(fontSize: 14.sp, color: Colors.white),
      labelLarge: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white),
    ),
   //! eleveted  button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
        ),
      ),
    ),
    //! text button  
     textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
     
        textStyle: TextStyle(color: Colors.black)
      )
     ),


    //! otline button  theme data
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
       
         foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
           side: BorderSide(color: Colors.blue,width: 2.w),
        ),
      ),
    ),
    //! curser  colors
     textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.blue,
    ),
    

   

    //! text field  in  ligth  mode  

     inputDecorationTheme: InputDecorationTheme(
        
       border: OutlineInputBorder(
         borderRadius: BorderRadius.circular(18.r),
         borderSide: BorderSide(color: Colors.blue,width: 2.w),
       ),
       focusedBorder: OutlineInputBorder(
         borderRadius: BorderRadius.circular(18.r),
         borderSide: BorderSide(color: Colors.blue,width: 2.w),
       ), 
       enabledBorder: OutlineInputBorder(
         borderRadius: BorderRadius.circular(18.r),
         borderSide: BorderSide(color: Colors.blue,width: 2.w),
       ),
       errorBorder: OutlineInputBorder(
         borderRadius: BorderRadius.circular(18.r),
         borderSide: BorderSide(color: Colors.red,width: 2.w),
       ),
       focusedErrorBorder: OutlineInputBorder(
         borderRadius: BorderRadius.circular(18.r),
         borderSide: BorderSide(color: Colors.red,width: 2.w),
       ),
       disabledBorder: OutlineInputBorder(
         borderRadius: BorderRadius.circular(18.r),
         borderSide: BorderSide(color: Colors.blue,width: 2.w),
       ),
      
       labelStyle: TextStyle(color: Colors.black),
       hintStyle: TextStyle(color: Colors.black),
       errorStyle: TextStyle(color: Colors.red),
       suffixIconColor: Colors.black,
       prefixIconColor: Colors.black,
      
     ),
       bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black,
      type: BottomNavigationBarType.fixed,
      elevation: 01,
      selectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12.sp,
        fontWeight: FontWeight.bold,
      
    ),

       ),
  
 
     );
     


   //! in dark  mode
   static  ThemeData  darkTheme = ThemeData(

     textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.blue,
    ),
    
   
 
     scaffoldBackgroundColor: Colors.black,  //! scaffold background color in dark  mode 
  //!  app bar background color
     appBarTheme: AppBarTheme(
       backgroundColor: Colors.black38,
        titleTextStyle: GoogleFonts.poppins(
        fontSize: 28.sp,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
        
      ),
      iconTheme: IconThemeData(color: Colors.white),

     ),
     //! elevate button 
      elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
        ),
      ),
    ),
    //! text them in dark  mode
     textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(fontSize: 24.sp, fontWeight: FontWeight.bold,color: Colors.white),
      headlineMedium: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.w600,color: Colors.white),
      bodyMedium: GoogleFonts.openSans(fontSize: 16.sp,color: Colors.white),
      bodySmall: GoogleFonts.openSans(fontSize: 14.sp, color: Colors.white),
      labelLarge: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white),
    ),


 //! icon button theme  data
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        backgroundColor: Colors.black, //!  late  check white  looking good 
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
        ),
      ),


    ),

    //! otline button  theme data
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
          side: BorderSide(color: Colors.blue),
        ),
      ),
    ),

    //! text butoon
     textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        textStyle: TextStyle(color: Colors.white)
      )
     ),

     //! textfil dark
          inputDecorationTheme: InputDecorationTheme(
            
       border: OutlineInputBorder(
         borderRadius: BorderRadius.circular(18.r),
         borderSide: BorderSide(color: Colors.blue,width: 2.w),
       ),
       focusedBorder: OutlineInputBorder(
         borderRadius: BorderRadius.circular(18.r),
         borderSide: BorderSide(color: Colors.blue,width: 2.w),
       ), 
       enabledBorder: OutlineInputBorder(
         borderRadius: BorderRadius.circular(18.r),
         borderSide: BorderSide(color: Colors.blue,width: 2.w),
       ),
       errorBorder: OutlineInputBorder(
         borderRadius: BorderRadius.circular(18.r),
         borderSide: BorderSide(color: Colors.red,width: 2.w),
       ),
       focusedErrorBorder: OutlineInputBorder(
         borderRadius: BorderRadius.circular(18.r),
         borderSide: BorderSide(color: Colors.red,width: 2.w),
       ),
       disabledBorder: OutlineInputBorder(
         borderRadius: BorderRadius.circular(18.r),
         borderSide: BorderSide(color: Colors.blue,width: 2.w),
       ),
      
       labelStyle: TextStyle(color: Colors.white),
       hintStyle: TextStyle(color: Colors.white),
       errorStyle: TextStyle(color: Colors.red),
       suffixIconColor: Colors.white,
       prefixIconColor: Colors.white,
      
       
     ),
     iconTheme: IconThemeData(color: Colors.white), //! icon theme data
     bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.black12,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white,
      type: BottomNavigationBarType.shifting,
      elevation: 5,
    selectedIconTheme: IconThemeData(size: 24),
    showSelectedLabels: true,
    showUnselectedLabels: true,
    selectedLabelStyle: GoogleFonts.poppins(
      fontSize: 12.sp,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    // Add border using decoration

    landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
),
    );
         
   
    
     

}