part of 'notepad_forwangtao_writingboard.dart';

class WriteWidget extends StatelessWidget {
  /// 书写组件是否处于调试状态
  final bool isDebug;

  /// 书写组件左上角的坐标
  ///
  /// 在开始书写时这个坐标就是落笔时的第一个点
  ///
  /// 而当笔迹开始运动时，
  /// 就围绕着这个点扩充画布的面积，
  /// 这样就能尽可能多的让每一笔都落在画布上面
  final Offset lefttopPosition;

  /// 书写组件右下角的坐标
  ///
  /// 在开始书写时这个坐标就是落笔时的第一个点
  ///
  /// 而当笔迹开始运动时，
  /// 就围绕着这个点扩充画布的面积，
  /// 这样就能尽可能多的让每一笔都落在画布上面
  final Offset rightbottomPosition;

  /// 书写轨迹
  ///
  /// 将书写轨迹以 [Path] 形式放在这里，
  /// 即可在书写组件上渲染出笔迹
  ///
  /// 渲染主体是隔离的，
  /// 这意味着只要停止对 [Path] 的增加，
  /// 那么这个组件就变成静态的了
  ///
  /// 记事本有了这个功能就能做到非常流畅的书写效果！
  /// 还好Flutter有局部渲染这个非常棒的底层功能
  final Path writingPath;

  /// 书写笔迹的有关设置
  ///
  /// 可以简单的设计它的粗细、大小及颜色，
  /// 也可以对笔的逻辑进行更深层次的更改
  ///
  /// tip:这个文章讲这个Paint属性讲的非常nice，
  /// 推荐给你们：https://www.cnblogs.com/ilgnefz/p/15992967.html
  final PenProperties penProperties;

  /// 从原始触摸事件获取到手写笔的参数
  final StylusData stylusData;

  /// 书写组件
  const WriteWidget({
    super.key,
    required this.lefttopPosition,
    required this.rightbottomPosition,
    required this.writingPath,
    required this.stylusData,
    required this.penProperties,
    this.isDebug = false,
  });

  @override
  Widget build(BuildContext context) {
    // 对书写轨迹的坐标进行偏移转换，使轨迹中触摸点转换为对应画布的坐标
    Path writingPathFixed = writingPath.shift(-lefttopPosition);

    // 是一个可大可小的组件
    return Positioned(
        left: lefttopPosition.dx,
        top: lefttopPosition.dy,
        width: rightbottomPosition.dx - lefttopPosition.dx,
        height: rightbottomPosition.dy - lefttopPosition.dy,
        // 让这个组件不要影响其他组件的刷新，防止过度刷新
        child: RepaintBoundary(
          child: CustomPaint(
            size: Size(rightbottomPosition.dx - lefttopPosition.dx,
                rightbottomPosition.dy - lefttopPosition.dy),
            painter: _Writer(
                writingPath: writingPathFixed,
                penProperties: penProperties,
                stylusData: stylusData),
            // 让书写组件可以支持更复杂的笔画
            isComplex: true,
            willChange: true,
            // 如果处于调试状态，就为每一个书写组件突出显示一下它的位置和大小
            child: isDebug
                ? Container(
                    decoration: BoxDecoration(border: Border.all()),
                  )
                : null,
          ),
        ));
  }
}
