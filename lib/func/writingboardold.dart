import 'package:flutter/material.dart';
import 'package:notepad_forwangtao_writingboard/class/point.dart';
import 'package:notepad_forwangtao_writingboard/notepad_forwangtao_writingboard.dart';

class WritingObjectManager {
  /*
   * 这些是用于每一次书写使用的临时变量
   * 非必须不要从外部调用它们
   */

  /// 每一次书写都将操作这里的轨迹进行书写，
  /// 再给各个渲染字迹组件进行渲染
  Path _writingPath = Path();

  /// 每个书写笔迹组件的临时坐标(左上角)
  Offset _lefttopPosition = Offset.zero;

  /// 每个书写笔迹组件的临时坐标(右下角)
  Offset _rightbottomPosition = Offset.zero;

  /// 开始记录输入
  ///
  /// 务必使用setState包裹住这个方法，
  /// 否则就什么效果都没有
  void _inputBegin({required PointData thisPoint}) {
    // 清空一下重做列表，防止乱套了
    _redoObjects.clear();

    _writingPath.moveTo(
      thisPoint.thisPointOffset.dx,
      thisPoint.thisPointOffset.dy,
    );
    _lefttopPosition = thisPoint.thisPointOffset;
    _rightbottomPosition = thisPoint.thisPointOffset;
    writingObjects.add(WritingObject(
      isDebug: isDebug,
      lefttopPosition: _lefttopPosition,
      rightbottomPosition: _rightbottomPosition,
      writingPath: _writingPath,
      penPreset: penPresets[penNum],
      pointData: thisPoint,
    ));
  }

  /// 记录输入的移动
  ///
  /// 务必使用setState包裹住这个方法，
  /// 否则就什么效果都没有
  void _inputMove({required PointData thisPoint}) {
    _lefttopPosition = Offset(
      min(_lefttopPosition.dx, thisPoint.thisPointOffset.dx),
      min(_lefttopPosition.dy, thisPoint.thisPointOffset.dy),
    );
    _rightbottomPosition = Offset(
      max(_rightbottomPosition.dx, thisPoint.thisPointOffset.dx),
      max(_rightbottomPosition.dy, thisPoint.thisPointOffset.dy),
    );
    _writingPath.lineTo(
      thisPoint.thisPointOffset.dx,
      thisPoint.thisPointOffset.dy,
    );
    writingObjects.removeLast();
    writingObjects.add(WritingObject(
      isDebug: isDebug,
      lefttopPosition: _lefttopPosition,
      rightbottomPosition: _rightbottomPosition,
      writingPath: _writingPath,
      penPreset: penPresets[penNum],
      pointData: thisPoint,
    ));
  }

  /// 结束记录输入
  ///
  /// 务必使用setState包裹住这个方法，
  /// 否则就什么效果都没有
  void _inputEnd() {
    // 如果发现屏幕只是被点了一个小点，
    // 那就把这个画布给删掉，
    // 避免浪费
    final pathCounter = _writingPath.computeMetrics();
    if (pathCounter.isEmpty) {
      if (writingObjects.isNotEmpty) {
        writingObjects.removeLast();
      }
    }
    _lefttopPosition = Offset.zero;
    _rightbottomPosition = Offset.zero;
    _writingPath = Path();
  }

  /*
   * 这些是用于对书写板进行撤销重做的临时变量
   * 非必须不要从外部调用它们
   */

  /// 当点撤销键时，
  /// 撤销的内容将被暂存在这里
  ///
  /// 除非有新的笔迹导致它被清空，
  /// 或者重做做完了
  final List _redoObjects = [];

  // 撤销操作
  bool undo() {
    if (writingObjects.isNotEmpty) {
      _redoObjects.add(writingObjects.last);
      writingObjects.removeLast();
      return true;
    } else {
      return false;
    }
  }

  // 重做操作
  bool redo() {
    if (_redoObjects.isNotEmpty) {
      writingObjects.add(_redoObjects.last);
      _redoObjects.removeLast();
      return true;
    } else {
      return false;
    }
  }
}

class WritingFunction {
  WritingboardController controller;

  /// 每一次书写都将操作这里的轨迹进行书写，
  /// 再给各个渲染字迹组件进行渲染
  Path _writingPath = Path();

  /// 每个书写笔迹组件的临时坐标(左上角)
  Offset _lefttopPosition = Offset.zero;

  /// 每个书写笔迹组件的临时坐标(右下角)
  Offset _rightbottomPosition = Offset.zero;

  ///
  WritingFunction({required this.controller});

  ///
  void _writeBegin({required PointData thisPoint}) {
    _writingPath.moveTo(
      thisPoint.thisPointOffset.dx,
      thisPoint.thisPointOffset.dy,
    );
    _lefttopPosition = thisPoint.thisPointOffset;
    _rightbottomPosition = thisPoint.thisPointOffset;
  }

  ///
  void _writeMove({required PointData thisPoint}) {}

  ///
  void _writeEnd({required PointData thisPoint}) {}

  /// 落笔事件
  void onPointerDown(PointerEvent event) {}

  /// 笔迹移动事件
  void onPointerMove(PointerEvent event) {}

  /// 收笔事件
  void onPointerUp(PointerEvent event) {}
}
