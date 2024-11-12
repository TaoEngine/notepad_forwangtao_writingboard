library notepad_forwangtao_writingboard;

import 'package:flutter/material.dart';

part 'painter.dart';
part 'shading.dart';

class Writingboard extends StatefulWidget {
  /// 画板
  ///
  /// 它主要实现的流程是这样的：
  /// - 首先，我在画板上画出的第一划的时候，笔或者手指落在屏幕的时候，开始建立一个新画布
  /// - 然后，笔或手指开始运动，此时测量一下手指到达的最远的地方，画布的大小也就这么大
  /// - 最后，手指放开，结束记录，将这个笔迹封存并且停止更新笔迹内容，将资源留给别的笔画

  /// 笔迹的组件放在这里
  /// TODO 将这个字迹记录列表改成Map，可以记录对应笔迹属于什么文字，并且与这个库分离
  final List<Widget> writeWidgets;
  const Writingboard({super.key, required this.writeWidgets});

  @override
  State<Writingboard> createState() => _WritingboardState();
}

class _WritingboardState extends State<Writingboard> {
  /// 笔迹起点
  Offset firstTouch = Offset.zero;

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
        children: widget.writeWidgets,
      ),
    );
  }

  /// 当笔（手指）落下来的操作
  /// - 创建新画布
  /// - 记录起点
  void beginTouch(PointerDownEvent touchevent) {
    firstTouch = touchevent.position;
    setState(() {
      widget.writeWidgets.add(WriteWidget(
          topPosition: touchevent.position,
          bottomPosition: touchevent.position,
          writepath: onceTouch));
    });
  }

  /// 当笔（手指）在屏幕上移动的时候
  /// - 记录
  /// - 处理
  void moveTouch(PointerMoveEvent touchevent) {
    // 计算正确路径
    double touchdx = touchevent.position.dx - firstTouch.dx;
    double touchdy = touchevent.position.dy - firstTouch.dy;
    // 刷新笔迹
    widget.writeWidgets.removeLast();
    onceTouch.lineTo(touchdx, touchdy);
    setState(() {
      widget.writeWidgets.add(WriteWidget(
          topPosition: firstTouch,
          bottomPosition: touchevent.position,
          writepath: onceTouch));
    });
  }

  /// 当笔（手指）从屏幕上离开的时候
  /// - 封装这个笔迹
  /// - 停止让CustomPaint下一次画图再去刷新它
  void endTouch(PointerUpEvent touchevent) {
    firstTouch = Offset.zero;
    onceTouch = Path();
  }
}

class WriteWidget extends StatelessWidget {
  /// 书写组件的左上角
  final Offset topPosition;

  /// 书写组件的右下角
  final Offset bottomPosition;

  /// 显示的书写轨迹
  final Path writepath;

  const WriteWidget(
      {super.key,
      required this.topPosition,
      required this.bottomPosition,
      required this.writepath});

  @override
  Widget build(BuildContext context) {
    // 组件长宽
    double width = bottomPosition.dx - topPosition.dx;
    double height = bottomPosition.dy - topPosition.dy;

    // 是一个可大可小的组件
    return Positioned(
      left: topPosition.dx,
      top: topPosition.dy,
      width: width,
      height: height,
      child: CustomPaint(
        size: Size(width, height),
        painter: _Painter(writepath: writepath),
        // 让书写组件可以支持更复杂的笔画
        isComplex: true,
        willChange: true,
      ),
    );
  }
}
