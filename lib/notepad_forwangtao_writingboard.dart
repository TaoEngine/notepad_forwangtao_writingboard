library notepad_forwangtao_writingboard;

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

part 'widget.dart';
part 'painter.dart';
part 'shading.dart';

class Writingboard extends StatefulWidget {
  /// 画板是否处于调试模式
  ///
  /// 用法
  final bool isDebug;

  /// 存放笔迹的Map，里面含有这篇记事本中所有笔迹的信息 [List]
  ///
  /// 用法
  ///
  /// <!--
  /// TODO 将这个字迹记录列表改成Map，可以记录对应笔迹属于什么文字
  /// -->
  final List<WriteWidget> writeWidgets;

  /// 只使用手写笔进行书写，使用手指将不起作用 [bool]
  ///
  /// 用法：只使用手写笔进行书写就传入 `true` ，
  /// 如果想让手指也支持书写，就传入 `false`
  ///
  /// 不过我其实想说，真的没多少人会用手指进行写字吧，
  /// 反正在我的APP上是只支持手写笔写字的，
  /// 因此该值默认为 `true`
  ///
  /// <!--
  /// TODO 使用触摸进行书写目前存在多指触控冲突问题
  /// -->
  final bool stylusOnly;

  /// 当写完一笔的时候，放在这里的函数会被自动执行 [VoidCallback]
  ///
  /// 用法：放入函数
  ///
  /// 主要用于写下一笔然后自动保存笔迹的功能，
  /// 建议使用Isar保存笔迹，
  /// 毕竟它的速度足够每写一笔就保存一笔了
  final VoidCallback? onWriteFinish;

  /// 画板
  ///
  /// 它主要实现的流程是这样的：
  /// - 首先，我在画板上画出第一划的时候，笔或者手指落在屏幕的时候，开始建立一个新画布
  /// - 然后，笔或手指开始运动，此时测量一下手指到达的最远的地方，画布的大小也就这么大
  /// - 最后，手指放开，结束记录，将这个笔迹封存并且停止更新笔迹内容，将资源留给别的笔画
  const Writingboard({
    super.key,
    this.onWriteFinish,
    this.isDebug = false,
    this.stylusOnly = true,
    required this.writeWidgets,
  });

  @override
  State<Writingboard> createState() => _WritingboardState();
}

class _WritingboardState extends State<Writingboard> {
  /// 画布左上角
  Offset lefttopPosition = Offset.zero;

  /// 画布右下角
  Offset rightbottomPosition = Offset.zero;

  /// 进行一次书写所留下的笔迹
  Path onceTouch = Path();

  @override
  Widget build(BuildContext context) {
    return Listener(
      // 设置全局监听笔迹
      behavior: HitTestBehavior.opaque,
      // 落笔书写
      onPointerDown: (event) => beginTouch(event),
      // 移动笔迹
      onPointerMove: (event) => moveTouch(event),
      // 笔离开屏
      onPointerUp: (event) => endTouch(event),
      // 用于存放笔迹的组件
      child: Stack(
        children: [
          //const Shading(horizontalLineWithit: 20, verticalLineWithit: 20),
          // TODO 底纹显示有些问题，别慌哈！
          Stack(
            children: widget.writeWidgets,
          )
        ],
      ),
    );
  }

  /// 当笔（手指）落下来的操作
  /// - 识别是什么在写字
  /// - 记录起点
  /// - 创建新的书写组件
  /// - 新的书写组件的中心将是起笔的位置
  void beginTouch(PointerDownEvent touchevent) {
    // 识别是不是手写笔
    // 或者把这个识别功能给跳过
    if (touchevent.kind == PointerDeviceKind.stylus || !widget.stylusOnly) {
      // 将第一笔的位置赋值给所有的组件位置
      lefttopPosition = touchevent.position;
      rightbottomPosition = touchevent.position;
      onceTouch.moveTo(lefttopPosition.dx, lefttopPosition.dy);

      // 创建书写组件
      // 此后的书写操作均绑定到这个组件上
      setState(() {
        widget.writeWidgets.add(WriteWidget(
          lefttopPosition: lefttopPosition,
          rightbottomPosition: rightbottomPosition,
          writingPath: onceTouch,
          isDebug: widget.isDebug,
        ));
      });
    }
  }

  /// 当笔（手指）在屏幕上移动的时候
  /// - 记录当前的笔迹
  /// - 进行运算，
  ///   如果超过之前书写到达的最远的位置，
  ///   就扩充一下组件的大小
  /// - 刷新笔迹，
  ///   渲染轨迹后更新画布
  void moveTouch(PointerMoveEvent touchevent) {
    // 获取现在笔尖的位置
    final nowPosition = touchevent.position;

    // 描绘笔迹的轨迹
    onceTouch.lineTo(nowPosition.dx, nowPosition.dy);

    // 是否超过最远距离
    lefttopPosition = Offset(
      min(lefttopPosition.dx, nowPosition.dx),
      min(lefttopPosition.dy, nowPosition.dy),
    );
    rightbottomPosition = Offset(
      max(rightbottomPosition.dx, nowPosition.dx),
      max(rightbottomPosition.dy, nowPosition.dy),
    );

    // 刷新笔迹，就要将之前的就笔迹给删掉
    widget.writeWidgets.removeLast();

    // 最后刷新之前绑定的书写组件
    // 删掉旧组件再添加新组件不影响这个书写组件在画板上的作用
    setState(() {
      widget.writeWidgets.add(WriteWidget(
        lefttopPosition: lefttopPosition,
        rightbottomPosition: rightbottomPosition,
        writingPath: onceTouch,
        isDebug: widget.isDebug,
      ));
    });
  }

  /// 当笔（手指）从屏幕上离开的时候
  /// - 封装这个笔迹
  /// - 停止让CustomPaint下一次画图再去刷新它
  void endTouch(PointerUpEvent touchevent) {
    // 对所有临时组件进行归零处理，以便下次使用
    lefttopPosition = Offset.zero;
    rightbottomPosition = Offset.zero;
    onceTouch = Path();

    // 执行一下停止书写的外部函数，比如保存笔迹
    widget.onWriteFinish;
  }
}
