
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:flutter/cupertino.dart';

class ResponsiveInfo{


 static bool isMobile()
{

  bool a=false;
  double width = AppDimensions.instance.width;

  if(width<650)
    {
      a=true;
    }
  else{
    a=false;
  }

  return a;

}

 static bool isSmallMobile()
 {

   bool a=false;
   double width = AppDimensions.instance.width;

   if(width<=380)
   {
     a=true;
   }
   else{
     a=false;
   }

   return a;

 }
 static bool isTablet()
 {

   bool a=false;
   double width = AppDimensions.instance.width;

   if(width>650||width<1200)
   {
     a=true;
   }
   else{
     a=false;
   }

   return a;

 }

 static bool isMobileDimension(BuildContext context)
 {

   var shortestSide = MediaQuery.of(context).size.shortestSide;

// Determine if we should use mobile layout or not, 600 here is
// a common breakpoint for a typical 7-inch tablet.
   final bool useMobileLayout = shortestSide < 600;

   return useMobileLayout;

 }



}