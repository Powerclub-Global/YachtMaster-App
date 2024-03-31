import 'package:flutter/material.dart';
import 'package:yacht_master_admin/resources/localization/localization_map.dart';
import 'package:yacht_master_admin/resources/resources.dart';
import 'package:yacht_master_admin/utils/text_size.dart';

class AppButton extends StatefulWidget {
  final String buttonTitle;
  final GestureTapCallback onTap;
  final Color? color;
  final Color? textColor;
  final Color? borderColor;
  final double? textSize;
  final double? borderRadius;
  final double? letterSpacing;
  final FontWeight? fontWeight;
  final AlignmentGeometry? alignmentGeometryBegin;
  final AlignmentGeometry? alignmentGeometryEnd;

  const AppButton({
    Key? key,
    required this.buttonTitle,
    required this.onTap,
    this.borderRadius,
    this.color,
    this.borderColor,
    this.textColor,
    this.textSize,
    this.letterSpacing,
    this.fontWeight,
    this.alignmentGeometryBegin,
    this.alignmentGeometryEnd,
  }) : super(key: key);

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors:[
                R.colors.gradMud,
                R.colors.themeMud,
                R.colors.gradMudLight,
                R.colors.themeMud,
                R.colors.gradMud,
              ] ),
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 28),

        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              LocalizationMap.getTranslatedValues(widget.buttonTitle),
              textAlign: TextAlign.center,
              style: R.textStyles.poppins().copyWith(
                    fontSize: widget.textSize ??
                        AdaptiveTextSize.getAdaptiveTextSize(context, 18),
                    fontWeight: widget.fontWeight ?? FontWeight.w500,
                    color: widget.textColor ?? R.colors.white,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
