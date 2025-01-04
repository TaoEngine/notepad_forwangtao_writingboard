part of '../main.dart';

enum ShadingStyle {
  /// 横线
  line,

  /// 网格
  grid,

  /// 点
  dot,
}

class Shading extends StatelessWidget {
  /// 底纹的高度
  final Size shadingSize;

  /// 显示的底纹类型
  final ShadingStyle shadingStyle;

  /// 绘制的底纹与整个书写板的间距
  final EdgeInsets shadingPadding;

  /// 底纹中线与线之间的间距
  final int lineSpacing;

  /// 绘制手写记事本的底纹
  ///
  /// 正如一般的纸质笔记本、比较出色的笔记app而言，在页面上印制底纹大多是为了规范书写时的格式，
  /// 提高可读性，像康奈尔笔记的底纹还为了后期笔记的可修改性 \
  /// （当然有些底纹就反其道而行之，比如咕卡，我家小孩就玩这个）
  ///
  /// 当时正如我遇到的众多记事本应用中，真正解决我的痛点的杀手级应用我始终遇不到。
  /// 到目前为止，在我使用的各款笔记应用中，基本没有一款能让与底纹对齐。
  /// 笔迹还好说，毕竟不可能不出线，但文字啊、插入的图片啊、杂七杂八的啊，基本不能与这些
  /// 底纹对齐，这导致在后期修改笔记的时候就非常不自然（苹果备忘录也是如此，在手写笔记和打字笔
  /// 记共存的情况下就会留有大片空白，而OneNote就很难对文字笔记进行排版，换行就容易露馅）
  ///
  /// 但是吧， TODO 我现在还没有如何实现这样的排版效果的方法，再等等吧😅
  const Shading({
    super.key,
    required this.shadingStyle,
    required this.shadingPadding,
    required this.lineSpacing,
    required this.shadingSize,
  });

  @override
  Widget build(BuildContext context) {
    // 应用的莫奈取色调用一下，
    // 这样绘线的时候就不用担心深色模式和浅色模式的问题了
    Color lineColor = Theme.of(context).colorScheme.onSurface;

    return Container(
      padding: shadingPadding,
      child: CustomPaint(
        foregroundPainter: LinePainter(
            lineColor: lineColor,
            lineSpacing: lineSpacing,
            shadingSize: shadingSize,
            shadingStyle: shadingStyle),
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  final Color lineColor;
  final int lineSpacing;
  final Size shadingSize;
  final ShadingStyle shadingStyle;

  LinePainter({
    required this.lineColor,
    required this.lineSpacing,
    required this.shadingSize,
    required this.shadingStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 横竖线的配置
    Paint linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    switch (shadingStyle) {
      // 绘制直线
      case ShadingStyle.line:
        for (var i = 0; i < shadingSize.height; i += lineSpacing) {
          canvas.drawLine(
            Offset(0, i.toDouble()),
            Offset(shadingSize.width, i.toDouble()),
            linePaint,
          );
        }
        break;

      // 绘制网格
      case ShadingStyle.grid:
        for (var i = 0; i < shadingSize.height; i += lineSpacing) {
          canvas.drawLine(
            Offset(0, i.toDouble()),
            Offset(shadingSize.width, i.toDouble()),
            linePaint,
          );
        }
        for (var i = 0; i < shadingSize.width; i += lineSpacing) {
          canvas.drawLine(
            Offset(i.toDouble(), 0),
            Offset(i.toDouble(), shadingSize.height),
            linePaint,
          );
        }
        break;

      // 绘制点
      case ShadingStyle.dot:
        double i = 0;
        while (i < shadingSize.width) {
          double j = 0;
          while (j < shadingSize.height) {
            canvas.drawCircle(
              Offset(i, j),
              0.5,
              linePaint,
            );
            j += lineSpacing;
          }
          i += lineSpacing;
        }
        break;
    }
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(LinePainter oldDelegate) => false;
}
