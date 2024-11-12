part of 'notepad_forwangtao_writingboard.dart';

class _Painter extends CustomPainter {
  /// 在单一的一个笔迹框架内显示的笔迹
  Path writepath;

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
  _Painter({required this.writepath});

  @override
  void paint(Canvas canvas, Size size) {
    Paint p = Paint();
    p.color = Colors.black;
    p.style = PaintingStyle.stroke;
    p.strokeCap = StrokeCap.round;
    p.strokeJoin = StrokeJoin.round;
    p.strokeWidth = 5;
    canvas.drawPath(writepath, p);
  }

  @override
  bool shouldRepaint(_Painter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(_Painter oldDelegate) => false;
}
