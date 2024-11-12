part of 'notepad_forwangtao_writingboard.dart';

class Shading extends StatelessWidget {
  /// 底纹是点还是实线 [bool]
  ///
  /// 用法：实线 `True` ，点 `False`
  ///
  /// 底纹用点一般用于画几何，底纹用实线就更常见了
  final bool shadingLineOrDot;

  /// 横线之间的间隔 [int]
  ///
  /// 用法：输入数字作为间隔，输 `0` 表示不绘制横线
  final int horizontalLineWithit;

  /// 竖线之间的间隔 [int]
  ///
  /// 用法：输入数字作为间隔，输 `0` 表示不绘制竖线
  final int verticalLineWithit;

  /// 横线与组件边框的距离 [double]
  ///
  /// 注意：当且仅当 `horizontalLineWithit` 不为0时这个才能起作用，也就是说
  /// `horizontalLineWithit` 为0时就可以不用管这个东西了
  ///
  /// 用法：输入 `(0,1]` 之间的小数，最好输入像 `5/6` 这样的分数形式。`1` 就是覆盖整个组件
  final double horizontalLineWithedge;

  /// 竖线与组件边框的距离 [double]
  ///
  /// 注意：当且仅当 `verticalLineWithit` 不为0时这个才能起作用，也就是说
  /// `verticalLineWithit` 为0时就可以不用管这个东西了
  ///
  /// 用法：输入 `(0,1]` 之间的小数，最好输入像 `5/6` 这样的分数形式。`1` 就是覆盖整个组件
  final double verticalLineWithedge;

  /// 底纹可配的插图 [String]
  ///
  /// 用法：输入图片的路径，什么都不输就是屏幕纯色 TODO 当前只支持网络图片
  ///
  /// 给底纹上一个背景图片，上类纸的图片写着就和在纸上写一样，上一些励志壁纸图片可以在书写时
  /// 给予力量，甚至可以上各位二次元老婆的图满足一下自己哈
  final String shadingBackgroundImage;

  /// 绘制手写记事本的底纹
  ///
  /// 正如一般的纸质笔记本、比较出色的笔记app而言，在页面上印制底纹大多是为了规范书写时的格式，
  /// 提高可读性，像康奈尔笔记的底纹还为了后期笔记的可修改性 \
  /// （当然有些底纹就反其道而行之，比如咕卡，我家小孩就玩这个）
  ///
  /// 当然我还想实现一些不一样的。到目前为止，在我使用的各款笔记应用中，基本没有一款能让与底纹
  /// 对齐。笔迹还好说，毕竟不可能不出线，但文字啊、插入的图片啊、杂七杂八的啊，基本不能与这些
  /// 底纹对齐，这导致在后期修改笔记的时候就非常不自然（苹果备忘录也是如此，在手写笔记和打字笔
  /// 记共存的情况下就会留有大片空白，而OneNote就很难对文字笔记进行排版，换行就容易露馅）
  ///
  /// 但是吧， TODO 我现在还没有如何实现这样的排版效果的方法，再等等吧😅
  const Shading({
    this.shadingLineOrDot = true,
    this.horizontalLineWithedge = 1,
    this.verticalLineWithedge = 1,
    this.shadingBackgroundImage = '',
    super.key,
    required this.horizontalLineWithit,
    required this.verticalLineWithit,
  });

  @override
  Widget build(BuildContext context) {
    // 获取组件宽度和高度
    double driverWidth = MediaQuery.sizeOf(context).width;
    double driverHeight = MediaQuery.sizeOf(context).height;

    // 底纹横线和竖线与组件边缘留空的长度
    double lineEmptyWidth = (driverWidth * (1 - horizontalLineWithedge)) / 2;
    double lineEmptyHeight = (driverHeight * (1 - verticalLineWithedge)) / 2;

    // 取色板
    Color lineColor = Theme.of(context).colorScheme.onSurface;

    // 需不需要图片
    Widget backgroundImage;
    if (shadingBackgroundImage != '') {
      backgroundImage = SizedBox(
        child: Image.network(
          shadingBackgroundImage,
          alignment: Alignment.topCenter,
          fit: BoxFit.contain,
          repeat: ImageRepeat.repeatY,
          width: driverWidth,
          height: driverHeight,
        ),
      );
    } else {
      backgroundImage = Container();
    }

    return CustomPaint(
      size: Size(
        driverWidth,
        driverHeight,
      ),
      foregroundPainter: LinePainter(
        driverWidth,
        driverHeight,
        lineEmptyWidth,
        lineEmptyHeight,
        horizontalLineWithit,
        verticalLineWithit,
        shadingLineOrDot,
        lineColor,
      ),
      child: backgroundImage,
    );
  }
}

class LinePainter extends CustomPainter {
  final double driverWidth;
  final double driverHeight;
  final double lineEmptyWidth;
  final double lineEmptyHeight;
  final int horizontalLineWithit;
  final int verticalLineWithit;
  final bool shadingLineOrDot;
  final Color lineColor;

  LinePainter(
    this.driverWidth,
    this.driverHeight,
    this.lineEmptyWidth,
    this.lineEmptyHeight,
    this.horizontalLineWithit,
    this.verticalLineWithit,
    this.shadingLineOrDot,
    this.lineColor,
  );

  @override
  void paint(Canvas canvas, Size size) {
    // 横竖线的配置
    Paint linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // 绘制点还是直线
    if (shadingLineOrDot) {
      // 绘制直线

      // 能绘制横线就绘制横线
      if (horizontalLineWithit != 0) {
        for (var i = 0; i < driverHeight; i += horizontalLineWithit) {
          canvas.drawLine(
            Offset(lineEmptyWidth, i.toDouble()),
            Offset(driverWidth - lineEmptyWidth, i.toDouble()),
            linePaint,
          );
        }
      }

      // 能绘制竖线就绘制竖线
      if (verticalLineWithit != 0) {
        for (var i = 0; i < driverHeight; i += verticalLineWithit) {
          canvas.drawLine(
            Offset(i.toDouble(), lineEmptyWidth),
            Offset(i.toDouble(), driverHeight - lineEmptyWidth),
            linePaint,
          );
        }
      }
    } else {
      // 绘制点
      if (horizontalLineWithit > 0 && verticalLineWithit > 0) {
        double i = lineEmptyWidth;
        while (i < driverWidth) {
          double j = lineEmptyHeight;
          while (j < driverHeight) {
            canvas.drawCircle(
              Offset(i, j),
              0.5,
              linePaint,
            );
            j += verticalLineWithit;
          }
          i += horizontalLineWithit;
        }
      }
    }
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(LinePainter oldDelegate) => false;
}
