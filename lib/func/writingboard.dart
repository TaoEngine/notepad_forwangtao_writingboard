part of '../notepad_forwangtao_writingboard.dart';

class WritingObjectManager {
  WritingObjectManager._privateConstructor();

  static final WritingObjectManager _instance =
      WritingObjectManager._privateConstructor();

  /// 书写板控制管理器
  factory WritingObjectManager() {
    return _instance;
  }

  /// 书写板是否处于Debug模式，这会在书写板显示一些用于调试的组件
  bool isDebug = false;

  /// 笔盒，存放到时候书写时要用到的笔
  List<PenPreset> penPresets = [];

  /// 使用笔盒的哪一只笔写字
  int penNum = 0;

  /// 在这里存放要用于渲染的书写笔迹组件
  List<WritingObject> writingObjects = [];

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
