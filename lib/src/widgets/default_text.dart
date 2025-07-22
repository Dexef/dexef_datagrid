import 'package:flutter/material.dart';

import '../style/colors.dart';
import '../style/style_size.dart';


class DefaultText extends StatelessWidget {
  double? fontSize;
  double? wordSpacing;
  double? height;
  FontWeight? fontWeight;
  Color? fontColor;
  Color? fontColor2;
  String? fontFamily;
  String? text;
  String? text2;
  TextAlign align;
  bool? isMultiLine;
  bool? isInSearch;
  InlineSpan? textSpan;
  TextDecoration? textDecoration;
  Color? decorationColor;
  TextOverflow overFlow;
  int? maxLines;
  bool isTextTheme;
  bool isTextTheme2;
  TextStyle? themeStyle;
  TextStyle? themeStyle2;

  DefaultText(
      {super.key, this.text,
        this.text2,
        this.fontSize,
        this.fontColor,
        this.fontColor2,
        this.fontWeight,
        this.fontFamily,
        this.align = TextAlign.start,
        this.wordSpacing,
        this.height,
        this.isMultiLine = false,
        this.isInSearch = false,
        this.textSpan,
        this.textDecoration,
        this.decorationColor,
        this.overFlow = TextOverflow.clip,
        this.maxLines,
        this.isTextTheme = false,
        this.isTextTheme2 = false,
        this.themeStyle,
        this.themeStyle2,
      });

  @override
  Widget build(BuildContext context) {
    int x = 0;
    return RichText(
        textAlign: align,
        maxLines: maxLines,
        overflow: overFlow,
        softWrap: true,
        text:TextSpan(
          children: [
            TextSpan(
                text: text?.trimLeft(),
                style: isTextTheme ? themeStyle : TextStyle(
                  fontSize: fontSize != null ? AppFontStyle.appFontSize.setFontSize(context,webFontSize: fontSize) : AppFontStyle.appFontSize.setFontSize(context,webFontSize: 14),
                  fontWeight: fontWeight ??AppFontStyle.fontWeightCustoms.regular,
                  color: fontColor ?? brush,
                  fontFamily: fontFamily ?? AppFontFamily.dexPro,
                  wordSpacing: wordSpacing,
                  height: height,
                  decoration : textDecoration,
                  decorationColor: decorationColor,
                )
            ),
            TextSpan(
                text: text2,
                style: isTextTheme2 ? themeStyle2 : TextStyle(
                  fontSize: fontSize != null ? AppFontStyle.appFontSize.setFontSize(context,webFontSize: fontSize) : AppFontStyle.appFontSize.setFontSize(context,webFontSize: 14),
                  fontWeight: fontWeight ?? AppFontStyle.fontWeightCustoms.medium,
                  color: fontColor2 ?? brush,
                  fontFamily: fontFamily ?? AppFontFamily.dexPro,
                  wordSpacing: wordSpacing,
                  height: height,
                  decoration : textDecoration,
                  decorationColor: decorationColor,
                )
            ),
          ],
        )
    );
  }
}

