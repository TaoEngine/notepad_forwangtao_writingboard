part of 'notepad_forwangtao_writingboard.dart';

class _Writer extends CustomPainter {
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
  Path writingPath;

  /// 笔的类型
  ///
  /// 在我的记笔记的过程中，
  /// 我最常使用的两支笔就是：
  /// 中性笔和直线笔
  ///
  /// 中性笔就是我平时记记东西最常用的笔，
  /// 然后直线笔就可以用于画波浪线、虚线和直线
  /// 就非常适合标注一些重点东西
  ///
  /// 最后橡皮擦工具是每个书写板标配的东西，
  /// 因此也可以将笔的类型切换成橡皮擦来清除多余笔迹
  /// 橡皮擦可设置为针对像素的橡皮擦和针对笔迹的橡皮擦
  PenKind penKind;

  /// 笔的属性
  ///
  /// 可以简单的设计它的粗细、大小及颜色，
  /// 也可以对笔的逻辑进行更深层次的更改
  ///
  /// tip:这个文章讲这个Paint属性讲的非常nice，
  /// 推荐给你们：https://www.cnblogs.com/ilgnefz/p/15992967.html
  Paint penProperties;

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
  _Writer(
      {required this.writingPath,
      required this.penKind,
      required this.penProperties});

  @override
  void paint(Canvas canvas, Size size) {
    penProperties.style = PaintingStyle.stroke;
    // 笔迹整体呈圆滑型
    penProperties.strokeCap = StrokeCap.round;
    // 笔迹的路径呈圆滑型
    penProperties.strokeJoin = StrokeJoin.round;
    canvas.drawPath(writingPath, penProperties);
  }

  @override
  bool shouldRepaint(_Writer oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(_Writer oldDelegate) => false;
}

/// 笔的类型
enum PenKind {
  /// 中性笔
  ///
  /// 我生活中最常用的笔，写字看着最舒服
  gelPen,

  /// 直线笔
  ///
  /// 适合用来标注东西的笔，
  /// 可以切换成波浪线、虚线、双横线和单横线
  linePen,

  /// 像素橡皮擦
  pixelEraser,

  /// 笔迹橡皮擦
  pathEraser
}
