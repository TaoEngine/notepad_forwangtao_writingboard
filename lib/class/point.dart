import 'package:flutter/widgets.dart';

/// ### 书写时落笔点的参数
///
/// 一般来说，
/// 在每次书写时，
/// 我们利用书写设备（触摸屏、手写笔或者数位板）在屏幕留下笔迹往往不止一个**落笔位置**参数，
/// 其实这些书写设备给我们带来的信息还是有很多很多的，如：
///
/// - 这次留下的落笔点的**书写速度**（与上一次落笔点相比）
/// - 这次留下的落笔点采集到的书写设备（特别是手写笔）的**压感**
/// - 这次留下的落笔点采集到的，我们使用书写设备（特别是手写笔）的**用笔方向**
/// - 这次留下的落笔点采集到的书写设备（特别是手写笔）的**笔杆倾斜角度**
/// - 这次留下的落笔点采集到的书写设备（特别是手写笔）的**笔尖形状**
///
/// 这些书写设备在屏幕的每个落笔点留下的参数都会被 `PointData` 记录起来，
/// 而记录了一堆 `PointData` 的列表将会**存储**起来作为**记事本的内容**
///
/// 说实话Flutter其实是有定义类似的参数 `PointerData` ,
/// 但是那个参数太繁杂了我说实话，
/// 还有一些可能在手写操作时永远用不到的功能，
/// 所以我将其精简了下以适合完备的书写采集
///
/// 对了，
/// 这些采集的 `PointData` 也会被渲染到书写板上以优化过的笔迹形式出现在各位的屏幕上,
/// 不过这些数据对于渲染来说压力可能还是大了些,
/// 因此原始记录的笔迹会经过样条插值以减少数据量,
/// 且经过风格化的优化后笔迹会变得平滑且好看
class PointData {
  /// ### 此次落笔点的编号
  ///
  /// #### 介绍:
  ///
  /// 由于Listener在每次触摸事件发生时会 **根据触摸设备以及次序给每个触摸点** 标注一个 **不会再复用** 的ID,
  /// 这样就有了原生的多指触控支持( `GestureDetector` 里面的多指事件).
  ///
  /// 在这里编号将用于分类落笔设备,并且为识别多指触控所用
  final int thisPointNum;

  /// ### 此次落笔点的坐标
  final Offset thisPointOffset;

  /// ### 此次落笔点与上一个落笔点相隔的时间
  final int thisPointTime;

  /// ### 此次落笔点采集出来书写设备(特指手写笔)的压感
  ///
  /// #### tip:
  ///
  /// 要是此次触摸事件不是触控笔做出的,这个值就没有了( `null` )
  final double? thisPointPressure;

  /// ### 此次落笔点采集出来书写设备(特指手写笔)的转向
  ///
  /// #### tip:
  ///
  /// 要是此次触摸事件不是触控笔做出的,这个值就没有了( `null` )
  final double? thisPointRotation;

  /// ### 此次落笔点采集出来书写设备(特指手写笔)的倾斜程度
  ///
  /// #### tip:
  ///
  /// 要是此次触摸事件不是触控笔做出的,这个值就没有了( `null` )
  final double? thisPointTilt;

  /// ### 此次落笔点采集出来书写设备(特指手写笔)的按压面积
  ///
  /// #### tip:
  ///
  /// 要是此次触摸事件不是触控笔做出的,这个值就没有了( `null` )
  final double? thisPointRadius;

  /// ### 进行一次书写时落笔的点的所有参数
  ///
  /// 需要将从 `Listener` 或者 `PencilKit` 中采集到的落笔点的所有信息导入此处，
  /// 这不仅是将要保存的记事本主要信息，对笔迹风格化非常有用
  PointData({
    required this.thisPointNum,
    required this.thisPointOffset,
    required this.thisPointTime,
    this.thisPointPressure,
    this.thisPointRotation,
    this.thisPointTilt,
    this.thisPointRadius,
  });

  /// ### 一键从Listener的 [PointerEvent] 采集落笔点参数
  static PointData importPointData(PointerEvent event) {
    PointData thisPoint = PointData(
      thisPointNum: event.device,
      thisPointTime: 0,
      thisPointOffset: event.localPosition,
      thisPointPressure: event.pressure,
      thisPointRotation: event.orientation,
      thisPointTilt: event.tilt,
      thisPointRadius: event.radiusMajor,
    );
    return thisPoint;
  }
}
