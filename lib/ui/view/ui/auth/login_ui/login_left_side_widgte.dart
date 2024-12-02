import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/generated/assets.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginLeftSideWidget extends StatefulWidget {
  const LoginLeftSideWidget({Key? key}) : super(key: key);

  @override
  State<LoginLeftSideWidget> createState() => _LoginLeftSideWidgetState();
}

class _LoginLeftSideWidgetState extends State<LoginLeftSideWidget> {
  ValueNotifier<String> changeNotify = ValueNotifier(Assets.iconsIcLoginLogo);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: double.infinity,
          width: double.maxFinite,
          decoration: BoxDecoration(
  gradient: LinearGradient(colors: [
    primaryColor.withOpacity(1),
    primaryColor.withOpacity(0.75),
    primaryColor.withOpacity(0.65),
    primaryColor.withOpacity(0.75),
    primaryColor.withOpacity(1),
  ]),
  image: DecorationImage(
    fit: BoxFit.fill,
    image: AssetImage("assets/images/dollor.png"),
    colorFilter: ColorFilter.mode(
      Colors.black.withOpacity(0.03), 
      BlendMode.dstATop,        
    ),
  ),
),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Image.asset("assets/images/loginimage 8.png",height: 150,),
                  Image.asset("assets/images/loginImage 6.png",height: 100,),
                ],
              ),
              Container(height: 1,width: 250,decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(color: primaryButtonColor,blurRadius: 10,spreadRadius: 2,)
                ]
              ),),
              SizedBox(height: 30,),
             Text("Welcome!",style: GoogleFonts.poppins(color: white, fontSize: 45, fontWeight: FontWeight.bold),),
             Center(
               child: Text(
                "Empower Your Sales, Anywhere, Anytime!",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: white, fontSize: 20, fontWeight: FontWeight.bold,),),
             ),
        
            ],
          ),
        ),
      ],
    );
  }
}
