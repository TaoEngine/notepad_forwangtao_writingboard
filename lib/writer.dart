part of 'notepad_forwangtao_writingboard.dart';

class _Writer extends CustomPainter {
  /// 从原始触摸事件获取到手写笔的参数
  final StylusData stylusData;

  /// 笔的属性
  final PenProperties penProperties;

  /// 在单一的一个书写组件内显示的轨迹
  ///
  /// 在每个widget中，
  /// 书写轨迹会以 [Path] 的形式传过来
  /// 而在这里需要对传入的单个 [Path] 进行拟合和风格化处理
  ///
  /// 注意传入的 [Path] 都是固定的，
  /// 因此对于笔迹进行拟合和风格化的操作也应该是固定的。
  /// 然后原始轨迹还都是保存在数据库中的，
  /// 在这里并没有对它们进行修改，
  /// 所以大可不用担心风格化会破坏原始轨迹的样子
  final Path writingPath;

  /// 测试用画板，主要用于测试书写的笔迹进行还原的算法
  ///
  /// 首先，由于Flutter的画板在使用时会过于卡顿，我得想个办法解决此类卡顿
  ///
  /// 其次，简单的画笔处理出来的笔迹实在太丑啦，得让笔迹拟合一下并形成一定的风格，
  /// 这样写出来的字才好看
  ///
  /// 此次分析我主要是使用这些文章讲的进行操作
  ///
  /// 涉及笔迹分析：https://blog.csdn.net/luansxx/article/details/120960073
  ///
  /// 涉及笔迹拟合：https://www.cnblogs.com/zl03jsj/p/8047259.html
  ///
  /// 涉及笔迹风格化：https://cloud.tencent.com/developer/article/2364677
  ///
  /// 这是我为了研究此类问题对画板进行一些算法上的操作，它主要做这些事情：
  /// - 预处理，有些连在一起的点可以不要的，要对从画板上获取的一些点进行预处理，
  ///   找到那些有价值的点
  ///
  /// - 分析转折点，有一些字在书写的时候会有一些拐弯的地方，比如折，横折，竖钩等，
  ///   这些转折的地方通常会不同于其他地方，比如点会密集一些。
  ///   通过聚类的算法可以找到这些密集的点的位置大致在哪，然后就能找到这个转折点了
  ///
  /// - 拟合成曲线，大家用来拟合曲线的办法都是贝塞尔曲线哈，那我也不客气了！
  ///
  /// - 风格化，我花了半个月想到的方法是，在每个采集点上做一个圆，通过压感和速度来调整圆的半径，
  ///   通过离转折点的远近来调整圆的偏心度，最后填充一下轮廓即可。
  ///   结果我在网上找资料的时候发现早有人这么做了，还有更好大佬研制出的优化版呢！
  ///   那我得好好的学一下哈
  _Writer({
    required this.stylusData,
    required this.penProperties,
    required this.writingPath,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint pen = Paint();

    // 每处笔迹需要断开
    pen.style = PaintingStyle.stroke;
    // 笔迹整体呈圆滑型
    pen.strokeCap = StrokeCap.round;
    // 笔迹的路径呈圆滑型
    pen.strokeJoin = StrokeJoin.round;
    // 设置颜色和粗细
    pen.color = penProperties.penColor;
    pen.strokeWidth = penProperties.penSize;

    canvas.drawPath(writingPath, pen);
  }

  @override
  bool shouldRepaint(_Writer oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(_Writer oldDelegate) => false;
}

/// 笔的属性
///
/// 在书写板建立之前将一些要用到的笔引入书写板，
/// 这些笔就会出现在书写板的笔盘上
/// 笔的设置根据大家写字的舒适度来调
///
/// 让我们将非常好的笔们带给大家！（华为何刚音）
class PenProperties {
  /// 笔的颜色
  ///
  /// 这个真没多少好说的🤓☝️，
  /// 真的就是调整笔的颜色
  final Color penColor;

  /// 笔的粗细
  ///
  /// 调整笔的粗细在那个范围间变化
  ///
  /// 粗细会随着压感、速度和角度出现或大或小的变化，
  /// 一般来说，
  /// 粗细难变化的笔被称为“硬笔”，
  /// 而容易变化的笔被称为“软笔”
  final double penSize;

  /// 压感权重
  ///
  /// 在书写时，
  /// 压感决定笔迹粗细的重要程度，
  /// 范围在0到1之间
  ///
  /// 调大的话笔会发软，调小的话笔会发硬
  final double penPressureWeight;

  /// 中性笔预设
  ///
  /// 手感稍硬，不过观感舒服
  PenProperties.gelpen({
    this.penColor = Colors.black,
    this.penSize = 5,
    this.penPressureWeight = 0.1,
  });

  /// 水彩笔预设
  ///
  /// 手感稍软，不过还没软到毛笔的程度
  PenProperties.watercolorpen({
    this.penColor = Colors.red,
    this.penSize = 5,
    this.penPressureWeight = 0.8,
  });

  /// 自定义笔
  ///
  /// 可以设置笔的颜色，粗细，还有压感
  PenProperties(
    this.penColor,
    this.penSize,
    this.penPressureWeight,
  );
}

/// 获取到的手写笔参数
///
/// 一般来说，手写笔有这几个参数值得我们关注
/// - 笔的压感
/// - 笔的转向（在屏幕的相对方向上）
/// - 笔的倾斜程度
/// - 笔尖在屏幕按压出的面积（可能在一些设备上没有）
class StylusData {
  /// 手写笔的压感
  final double stylusPressure;

  /// 手写笔的转向
  final double stylusDirection;

  /// 手写笔的倾斜程度
  final double stylusTilt;

  /// 手写笔的按压面积
  final double? stylusRadius;

  StylusData(
    this.stylusPressure,
    this.stylusDirection,
    this.stylusTilt,
    this.stylusRadius,
  );
}
