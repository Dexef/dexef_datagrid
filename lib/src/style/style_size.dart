import 'package:flutter/material.dart';

class AppFontStyle{
  static AppFontFamily appFontFamily = AppFontFamily();
  static AppFontWeight fontWeightCustoms = AppFontWeight();
  static AppFontSize appFontSize = AppFontSize();
}

class AppFontSize{
  setFontSize(BuildContext context,{double? webFontSize, double? mobileFontSize}) {

    if (MediaQuery.of(context).size.width > 600){
      if(webFontSize != null){
        if (MediaQuery.of(context).size.width <= 1280 && MediaQuery.of(context).size.height <= 800) {
          return webFontSize;
        }else if (MediaQuery.of(context).size.width <= 1366 && MediaQuery.of(context).size.height <= 768) {
          double size = webFontSize + 1;
          return size;
        }else if (MediaQuery.of(context).size.width <= 1920 && MediaQuery.of(context).size.height <= 1080) {
          double size = webFontSize + 2 ;
          return size;
        }
      }
    }else{
      if(mobileFontSize != null){
        return mobileFontSize;
      }

    }
  }
}

class AppScreenSize {
  static double widthSizeScreenInUI = 1366;
  static double heightSizeScreenInUI = 768;

  static getWidthMediaQuery(BuildContext context){
    double width = MediaQuery.of(context).size.width;
    return width;
  }
  static getHeightMediaQuery(BuildContext context){
    double height = MediaQuery.of(context).size.height;
    return height;
  }
  static setWidthWidgetSize(BuildContext context, sizeInUI){
    double width = getWidthMediaQuery(context) * (sizeInUI/widthSizeScreenInUI);
    return width;
  }
  static setHeightWidgetSize(BuildContext context, sizeInUI){
    double width = getHeightMediaQuery(context) * (sizeInUI/heightSizeScreenInUI);
    return width;
  }
////////////////////////////////////////////////////////////////////////////////
  static Orientation? orientation;
  static getLoginRightPanelWidth (BuildContext context) {
    orientation = MediaQuery.of(context).orientation;
    MediaQueryData media = MediaQuery.of(context);
    double? width ;
    if (media.size.width > 1280) {
      width = 700;
    } else if (media.size.width >= 1024 && media.size.width <= 1280 && orientation == Orientation.landscape) {
      width = media.size.width * 0.5;
    }else{
      width = media.size.width;
    }
    return width;
  }
}
////////////////////////////////////////////////////////////////////////////////
  setWidthForWidget(BuildContext context ,double width){
    return width / MediaQuery.of(context).size.width;
  }
////////////////////////////////////////////////////////////////////////////////
class AppFontFamily{
  static String dexPro = 'DexPro';
  static String dexProBold = 'DexProBold';
  static String dexProRegular = 'DexProRegular';
  // static String dexRoundBold = 'DXRoundBold';
  // static String dexefRoundRegular = 'DXRoundRegular';
}

// class AppFontWeight{
//   static FontWeight dex_Bold = FontWeight.w600;
//   static FontWeight dexef_Regular = FontWeight.w400;
//   static FontWeight dexef_Normal = FontWeight.w300;
//   static FontWeight dexefRound_Bold = FontWeight.w900;
//   static FontWeight dexefRound_Regular = FontWeight.w400;
//   static FontWeight dexefRoundBold_Bold = FontWeight.w800;
//   static FontWeight dexefRoundRegular_Regular = FontWeight.w500;
// }
class AppFontWeight{
  final FontWeight thin;
  final FontWeight extraLight;
  final FontWeight light;
  final FontWeight regular;
  final FontWeight medium;
  final FontWeight semiBold;
  final FontWeight bold;
  final FontWeight extraBold;
  final FontWeight black;

  AppFontWeight({
    this.thin = FontWeight.w100,
    this.extraLight = FontWeight.w200,
    this.light = FontWeight.w300,
    this.regular = FontWeight.w400,
    this.medium = FontWeight.w500,
    this.semiBold = FontWeight.w600,
    this.bold = FontWeight.w700,
    this.extraBold = FontWeight.w800,
    this.black = FontWeight.w900,
  });
}
