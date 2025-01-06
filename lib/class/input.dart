import 'package:flutter/widgets.dart';

/// ### 笔的预设
///
/// 在书写板建立之前我们可以将到时候写字要用到的一些笔引入书写板，
/// 这些笔就会出现在书写板的笔盘上
/// 笔的设置根据大家写字的舒适度来调
///
/// 让我们将非常好的笔们带给大家！（华为何刚音）
///
/// 此次有三个参数：
///
/// 笔的颜色
/// 这个真没多少好说的🤓☝️，
/// 真的就是调整笔的颜色
///
/// 笔的粗细
///
/// 调整笔的粗细在那个范围间变化
///
/// 粗细会随着压感、速度和角度出现或大或小的变化，
/// 一般来说，
/// 粗细难变化的笔被称为“硬笔”，
/// 而容易变化的笔被称为“软笔”
///
/// 压感权重
///
/// 在书写时，
/// 压感决定笔迹粗细的重要程度，
/// 范围在0到1之间
///
/// 调大的话笔会发软，调小的话笔会发硬
class PenPreset {
  /// 笔的颜色
  Color penColor;

  /// 笔的粗细
  double penSize;

  /// 笔的透明度
  double penOpacity;

  /// 写字时压感的权重
  double penPressureWeight;

  /// 中性笔预设 手感稍硬，不过观感舒服
  PenPreset.gelpen({
    required this.penColor,
    required this.penSize,
    this.penOpacity = 1,
    this.penPressureWeight = 0.1,
  });

  /// 水彩笔预设 手感稍软，有点像写毛笔字
  PenPreset.watercolorpen({
    required this.penColor,
    required this.penSize,
    this.penOpacity = 1,
    this.penPressureWeight = 0.8,
  });

  /// 荧光笔预设 笔头是一边宽一边窄，适合标注东西
  PenPreset.highlightedpen({
    required this.penColor,
    required this.penSize,
    this.penOpacity = 0.3,
    this.penPressureWeight = 0,
  });

  /// 自定义笔的预设 需要你自己设置笔的颜色，粗细，还有压感
  PenPreset({
    required this.penSize,
    required this.penColor,
    required this.penOpacity,
    required this.penPressureWeight,
  });
}
