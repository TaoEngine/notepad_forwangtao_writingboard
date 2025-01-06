import 'package:flutter/widgets.dart';

import 'package:notepad_forwangtao_writingboard/widget/boardcore.dart';
import 'package:notepad_forwangtao_writingboard/widget/boardcontroller.dart';

/// ### 书写板Widget
///
/// #### 介绍
///
/// {@template Writingboard.介绍}
///
/// 这便是整个书写板组件的交互Widget了,
/// 你只管往上面写字就好了,
/// 它自带许多帮助写字的超酷功能
///
/// {@endtemplate}
///
/// #### 使用
///
/// {@template Writingboard.使用}
///
/// 比如我想全屏幕显示这个书写板,
/// 那就这样写:
/// ```dart
/// return Center(
///   child: Writingboard(),
/// );
/// ```
///
/// 但是你要是不满足这个只能写字的书写板,
/// 那你还能对这个组件作以下这些自定义功能,
/// 让它更贴合你的需求:
/// ```dart
/// Writingboard(
///   controller: WritingboardController,
///   canscroll: true/false,
///   debug: true/false,
/// )
/// ```
///
/// {@endtemplate}
///
/// #### 功能
///
/// {@macro WritingboardController.介绍}
class Writingboard extends StatefulWidget {
  /// {@macro WritingboardController.介绍}
  final WritingboardController controller;

  /// {@macro Writingboard.介绍}
  const Writingboard({super.key, required this.controller});

  @override
  State<Writingboard> createState() => _WritingboardState();
}

class _WritingboardState extends State<Writingboard> {
  /// 用来监听ListView翻页事件用的控制器
  final ScrollController _scrollController = ScrollController();

  /// 当前ListView翻到多少页了，主要用于写到结尾自动加页和页面懒加载
  ///
  /// 这里解释下懒加载，就是当书写内容超过1.5个屏幕面积时，
  /// 书写板将只渲染当前能够显示的1.5个屏幕面积，
  /// 剩下的内容将被卸载，
  /// 直到那部分内容被重新显示在1.5个屏幕面积上
  ///
  /// 提一嘴，苹果的备忘录就是没有懒加载的反面例子，
  /// 打开的时候将页面内容全部显示出来，
  /// 这样翻页不卡不闪退才怪呢！
  late double listviewNowPosition;

  /// 书写速度计时器，用于计算笔迹运动时的速度并且映射到风格化笔迹上
  final writingStopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(
      () => setState(() {
        if (widget.controller.isdebug) {
          debugPrint("调试功能已启动!");
        }
      }),
    );
    // ListView发生了变动就会刷新当前位置
    _scrollController.addListener(() {
      listviewNowPosition = _scrollController.position.pixels;
    });
  }

  @override
  void dispose() {
    widget.controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 通过检测阅读模式/书写模式来控制ListView是否需要滚动
    final ScrollPhysics physics;
    switch (widget.controller.writereadmode) {
      case WriteReadMode.readMode:
        physics = const AlwaysScrollableScrollPhysics();
        break;
      case WriteReadMode.writeMode:
        physics = const NeverScrollableScrollPhysics();
      default:
        physics = const AlwaysScrollableScrollPhysics();
    }

    // 用ListView做出和苹果备忘录一样的无限向下笔记
    return ListView(
      controller: _scrollController,
      physics: physics,
      children: [
        SizedBox(
          height: 2000,
          child: BoardCore(
            controller: widget.controller,
          ),
        )
      ],
    );
  }
}
