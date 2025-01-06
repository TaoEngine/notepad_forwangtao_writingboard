import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:notepad_forwangtao_writingboard/class/point.dart';

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
  const Writingboard({
    super.key,
    required this.controller,
  });

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

  /// 控制页面是否可以滚动
  /// 如果它为true，页面就动不了了
  ///
  /// 一般来说，触摸或者手写笔是可以让ListView滚动起来的，
  /// 这会让我们写不了字的，
  /// 需要在书写板处于书写模式时并发生书写时让ListView锁起来，
  /// 阻止它滑动，
  /// 写完后随你怎么滚动都可以
  late bool isScrollable;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {});
    // ListView发生了变动就会刷新当前位置
    _scrollController.addListener(() {
      listviewNowPosition = _scrollController.position.pixels;
    });
    // 预设值是阅读模式还是书写模式
    isScrollable = widget.controller.writereadmode == WriteReadMode.readMode
        ? true
        : false;
  }

  @override
  void dispose() {
    widget.controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 用ListView做出和苹果备忘录一样的无限向下笔记
    return ListView(
      // controller: _scrollController,
      physics: isScrollable
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: 2000, // TODO 正在重新做无限向下功能
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (event) => onPointerDown(event),
            onPointerMove: (event) => onPointerMove(event),
            onPointerUp: (event) => onPointerUp(event),
            child: Stack(
              children: widget.controller.writingObjects,
            ),
          ),
        )
      ],
    );
  }

  /// 当落笔时的操作
  /// - 识别是什么在写字
  void onPointerDown(PointerDownEvent event) {
    // 通过Listener记录一下当前落笔点
    PointData thisPoint = PointData.importPointData(event);

    switch (widget.controller.writereadmode) {
      // 书写模式
      case WriteReadMode.writeMode:
        switch (widget.allowTouch) {
          // 跳过判别过程
          // 直接开写
          // 记得锁定ListView防止误滚动
          case AllowTouch.allow:
            // 锁定ListView
            isScrollable = false;
            // 开启计时器
            writingStopwatch.start();
            // 笔迹渲染预备
            setState(() =>
                widget.writingObjectManager._inputBegin(thisPoint: thisPoint));
            break;

          default:
            switch (event.kind) {
              // 识别到是手写笔
              // 因为手写笔会带动屏幕运动
              // 所以要比其他方法多一个锁定ListView滚动的操作
              case PointerDeviceKind.stylus:
                // 开启计时器
                writingStopwatch.start();
                // 笔迹渲染预备
                setState(() => widget.writingObjectManager
                    ._inputBegin(thisPoint: thisPoint));
                break;

              // 识别到是鼠标写字
              case PointerDeviceKind.mouse:
                // 开启计时器
                writingStopwatch.start();
                // 笔迹渲染预备
                setState(() => widget.writingObjectManager
                    ._inputBegin(thisPoint: thisPoint));
                break;

              // 识别到是触摸写字，但是就不要让它进行书写
              case PointerDeviceKind.touch:
                break;

              // 查找不到触摸类别就不往上面写字了
              default:
            }
        }
        break;

      // 默认为阅读模式，
      // 对书写板只查阅，不修改
      default:
    }
  }

  void onPointerMove(PointerMoveEvent event) {
    // 通过Listener记录一下当前落笔点
    PointData thisPoint = PointData.importPointData(event);

    switch (widget.modeWriteRead) {
      // 书写模式
      case WriteReadMode.writeMode:
        // 获取一下上一个
        PointData lastPoint =
            widget.writingObjectManager.writingObjects.last.pointData;

        // 判断一下是不是同一个触摸留下的笔迹，防止多指导致的误触
        if (thisPoint.thisPointNum == lastPoint.thisPointNum) {
          // 停止计时器
          writingStopwatch.stop();

          // 通过writingObjectManager渲染运动笔迹
          setState(() {
            widget.writingObjectManager._inputMove(
              thisPoint: thisPoint,
            );
          });

          // 然后重置计时器，重新计时
          writingStopwatch.reset();
          writingStopwatch.start();
        }
        break;
      default:
    }
  }

  void onPointerUp(PointerUpEvent event) {
    // 停止计时器
    writingStopwatch.stop();
    // 解锁ListView
    isScrollable = true;
    // 通过writingObjectManager渲染结束笔迹
    setState(() {
      widget.writingObjectManager._inputEnd();
    });
    // 最后重置计时器，给下一个笔迹使用
    writingStopwatch.reset();
  }
}
