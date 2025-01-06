import 'package:flutter/widgets.dart';

import 'package:notepad_forwangtao_writingboard/widget/boardcontroller.dart';

class BoardCore extends StatefulWidget {
  final WritingboardController controller;
  const BoardCore({super.key, required this.controller});

  @override
  State<BoardCore> createState() => _BoardCoreState();
}

class _BoardCoreState extends State<BoardCore> {
  /// 阅读模式呈现出的Widget
  Widget widgetReadMode() => Stack(children: widget.controller.writingObjects);

  /// 书写模式呈现出的Widget
  Widget widgetWriteMode() => Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (event) => onPointerDown(event),
        onPointerMove: (event) => onPointerMove(event),
        onPointerUp: (event) => onPointerUp(event),
        child: Stack(children: widget.controller.writingObjects),
      );

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.controller.writereadmode) {
      case WriteReadMode.readMode:
        return widgetReadMode();
      case WriteReadMode.writeMode:
        return widgetWriteMode();
      default:
        return widgetReadMode();
    }
  }

  /// 落笔事件
  void onPointerDown(PointerEvent event) {}

  /// 笔迹移动事件
  void onPointerMove(PointerEvent event) {}

  /// 收笔事件
  void onPointerUp(PointerEvent event) {}
}
