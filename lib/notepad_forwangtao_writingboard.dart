/// # 汪涛的记事本 书写板组件
///
/// "汪涛的记事本"的所有书写组件就是基于它开发的，简单又好用
///
/// ## 实现功能
///
/// - [x] 将笔迹记录为模块并附带存储的回调函数
/// - [ ] 书写板的背景，比如条纹，横线或者点，背景将严格用于手写文字的排版
/// - [ ] 提供对手写笔迹的风格化调整，支持调整内置的中性笔、水笔、荧光笔和橡皮擦的各类参数
/// - [ ] 对笔迹进行排版，并提供类似于文字选择器一样的手写文字选择器用于选择或者全选
/// - [ ] 识别笔迹是什么文字并提前存储以备后端使用
/// - [ ] 将笔迹分类，哪些是手写字，哪些是图画，哪些是格式化用的符号（类似于markdown，但是比markdown写起来简单）
///
/// ## 如何使用
///
/// 很简单，书写板的Widget名叫 `Writingboard()` 导入到页面就好了
///
/// ```dart
/// Writingboard Writingboard({Key? key, required List<Widget> writeWidgets})
/// ```
/// 其中 `writeWidgets` 是书写的笔迹，以 `WriteWidget` 进行存储
/// 其他功能的参数文档还在完善，敬请期待吧！
library notepad_forwangtao_writingboard;

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

part 'widget.dart';
part 'writer.dart';
part 'shading.dart';

/// 只允许手写笔书写或者允许手指/鼠标书写
///
/// 一般来说，
/// 在平板上用手写笔书写是最自然也是最舒服的书写方式，
/// 但是我们也会在手机上用手指批注东西，
/// 或者在电脑上用鼠标画重点
///
/// 但是手写笔/手写/鼠标的逻辑是各不相同的，
/// 手写笔/鼠标可以实现阅读与书写独立操作
/// （书写用手写笔/鼠标拖动，阅读用手指/鼠标滚轮）
/// 但是手就不行，
/// 两者操作会打架，
/// 所以必须要分离一下两个模式的操作
///
/// 还有一点，
/// 手写笔可以精准采集书写的好多操作，
/// 但是鼠标和手写就不行了，
/// 这个也需要分离一下
enum AllowTouch {
  /// 允许手写和鼠标书写
  allow,

  /// 不允许手写和鼠标书写
  disallow
}

/// 阅读模式与书写模式的切换
///
/// 可以让书写板处于阅读模式或者是书写模式
///
/// 阅读模式将会禁用书写板的书写功能，
/// 这时候就可以翻阅书写板的内容了
///
/// 而书写模式会禁用书写板的翻阅功能，
/// 你将无法滑动翻阅书写板，
/// 这样在写字的时候就不会糟心了
enum WriteReadMode {
  /// 书写模式，禁用书写板的翻阅功能
  writeMode,

  /// 阅读模式，禁用书写板的书写功能
  readMode,
}

class Writingboard extends StatefulWidget {
  /// 让书写板处于调试模式
  ///
  /// 如果处于调试状态的话，
  /// 会在每个组件上显示一个框框用于展示它的大小和中心点
  /// 并会在旁边显示组件书写时的刷新率、压感、速度和握笔方向
  ///
  /// <!--
  /// TODO 还未实现显示刷新率、压感、速度和握笔方向的功能
  /// -->
  ///
  /// 用法：如果在使用书写板进行开发的时候想测试笔迹的运行情况
  /// （包括显示笔迹的边界、书写时的刷新率、手写笔的当前压感、速度和握笔方向功能）
  /// 就传入 `true` ，
  ///
  /// 正常使用书写板请千万不要向其传入参数，它默认为 `false`
  final bool isDebug;

  /// ### 允许其他输入工具进行书写吗
  ///
  /// 是否允许除手写笔的其他输入工具(如触摸)进行书写 [AllowTouch]
  ///
  /// 一般来说，
  /// 在平板上用手写笔书写是最自然也是最舒服的书写方式，
  /// 但是我们也会在手机上用触摸屏批注东西，
  /// 或者在电脑上用鼠标画重点
  ///
  /// 但是手写笔/触摸/鼠标的逻辑是各不相同的，
  /// 手写笔/鼠标可以实现阅读与书写独立操作
  /// （书写用手写笔/鼠标拖动，阅读用触摸/鼠标滚轮）
  /// 但是触摸就不行，
  /// 两者操作会打架，
  /// 所以必须要分离一下两个模式的操作
  ///
  /// 还有一点，
  /// 手写笔可以精准采集书写的好多操作，
  /// 但是鼠标和触摸就不行了，
  /// 这个也需要分离一下
  ///
  /// ### 如何引入
  /// ```dart
  /// Writingboard(
  ///   ...
  ///   // 允许
  ///   allowTouch: AllowTouch.allow,
  ///   // 不允许
  ///   allowTouch: AllowTouch.disallow,
  ///   // 或者引入一个切换器 [bool]
  ///   allowTouch: allowTouchSwitcher
  ///     ? AllowTouch.allow
  ///     : AllowTouch.disallow,
  /// ),
  /// ```
  ///
  /// <!--
  /// TODO 使用触摸进行书写目前存在多指触控冲突问题
  /// -->
  final AllowTouch allowTouch;

  /// ### 阅读模式与书写模式的切换
  ///
  /// 想要阅读书写板的笔记内容就切换为阅读模式，
  /// 要想在书写板上记一些笔记就切换为书写模式 [WriteReadMode]
  ///
  /// 苹果的备忘录是我用的最熟的笔记APP了，
  /// 比第三方像GoodNotes啊云记啊的对我来说更顺手些
  /// 一个最重要的原因是它是无限向下笔记，
  /// 而不像其他笔记软件是要手动加页的
  ///
  /// 苹果备忘录有个逻辑，
  /// 就是在不点开右上角的ApplePencil笔盒的时候，
  /// 备忘录就会处于阅读模式，
  /// 单手可以翻阅笔记，
  /// 但是除非你双击屏幕进入编辑模式，
  /// 不然它不会轻易对笔记进行编辑操作的
  ///
  /// 不过当那个笔盒被点开的时候（同时手指涂画也是打开的状态）
  /// 备忘录就会处于编辑模式，
  /// 你会发现你向上滑还是向下滑都不能翻阅笔记了，
  /// 除非用双指滑才能滑动
  ///
  /// 使用手写笔的时候手指其实只起到滑动的作用，
  /// 所以若 `allowTouch` 为 `disallow` 时这个功能将会失效
  ///
  /// ### 如何引入
  /// ```dart
  /// Writingboard(
  ///   ...
  ///   // 阅读模式
  ///   modeWriteRead: WriteReadMode.readMode,
  ///   // 书写模式
  ///   modeWriteRead: WriteReadMode.writeMode,
  ///   // 或者引入一个切换器 [bool]
  ///   modeWriteRead: modeWriteReadSwitcher
  ///     ? WriteReadMode.readMode
  ///     : WriteReadMode.writeMode,
  /// ),
  /// ```
  final WriteReadMode modeWriteRead;

  /// ### SafeArea纠偏
  ///
  /// 对手机/平板普遍存在的SafeArea进行触摸纠偏 [Offset]
  ///
  /// 安卓/苹果的平板/手机在现在基本搞上了全面屏，
  /// 全面屏好是好，但会对应用的布局产生影响，
  /// 尤其是刘海屏/打孔屏会遮挡一些应用的AppBar
  ///
  /// 因此安卓会有一些机制防止应用被挡住，
  /// 比如Flutter的SafeArea就是起到这个作用的组件，
  /// 它把应用的AppBar抬高，
  /// 这样整个AppBar就能从挖孔屏中完整的被显示出来了
  ///
  /// 但是这个垫高的SafeArea会导致整个识别触摸的组件也被垫高，
  /// 从而导致偏差，
  /// 因此需要在使用书写板之前就把偏移的坐标给纠正过来
  ///
  /// ### 如何引入
  ///
  /// ```dart
  /// // 在主界面的最开始检测下这个界面的SafeArea
  /// EdgeInsets appSafeArea = MediaQuery.of(context).padding;
  /// // 转换成Offset，纠偏主要针对SafeArea的上方和左方
  /// appSafeAreaFix = Offset(safearea.left, safearea.top)
  /// // 传进来就可以纠偏了
  /// Writingboard(
  ///   ...
  ///   safeareaFixPosition: appSafeAreaFix,
  /// ),
  /// ```
  ///
  /// ### 注意
  ///
  /// 横屏也是存在SafeArea的
  final Offset appSafeAreaFix;

  /// 当写完一笔的时候，放在这里的函数会被自动执行 [Function]
  ///
  /// 主要用于写下一笔然后自动保存笔迹的功能，
  /// 建议使用Isar保存笔迹，
  /// 毕竟它的速度足够每写一笔就保存一笔了
  final Function(PointerUpEvent) onWriteFinish;

  /// 外部笔迹引入
  ///
  /// 如果使用外部的笔迹功能替换内建的识别笔迹功能，
  /// 如引入PencilKit或PenKit，
  /// 那么请将从PencilKit或PenKit获取的笔迹引入此处，
  /// 这样在延迟、压感上都会有硬件上的改善
  ///
  /// 注意这会使内建的触摸笔功能被禁用，
  /// 如果是iOS设备或华为设备，
  /// 笔盘会被换成PencilKit或PenKit的默认笔盘

  /// 画笔的设置
  ///
  /// 一般来说，画笔
  /// TODO 其实我还没想好画笔应该怎么做
  final PenProperties penProperties;

  /// 书写板
  ///
  /// 它主要实现的流程是这样的：
  /// - 首先，我在画板上画出第一划的时候，笔或者手指落在屏幕的时候，开始建立一个新画布
  /// - 然后，笔或手指开始运动，此时测量一下笔尖到达的最远的地方，画布的大小也就这么大
  /// - 最后，手指放开，结束记录，将这个笔迹封存并且停止更新笔迹内容，将资源留给别的笔画
  const Writingboard({
    super.key,
    this.isDebug = false,
    this.allowTouch = AllowTouch.disallow,
    this.modeWriteRead = WriteReadMode.writeMode,
    this.appSafeAreaFix = Offset.zero,
    required this.onWriteFinish,
    required this.penProperties,
  });

  @override
  State<Writingboard> createState() => _WritingboardState();
}

class _WritingboardState extends State<Writingboard> {
  // 用于监听ListView用的
  final ScrollController _scrollController = ScrollController();

  /// 当前ListView翻阅到哪里了
  ///
  /// 如果ListView翻阅超过一页，
  /// 上一页及其以上内容将被卸载，
  /// 等待翻阅过去的时候再重新加载
  double listviewNowPosition = 0;

  /// 当前ListView的长度
  ///
  /// ListView的长度是能动态增缩的，
  /// 刚好符合无限向下笔记的核心
  double? listviewNowLength;

  /// 存放笔迹的列表
  List<WriteWidget> writingWidgets = [];

  /// 临时记录一下每个画布的左上角坐标，
  /// 这个坐标会在每次收笔时重置
  Offset lefttopPosition = Offset.zero;

  /// 临时记录一下每个画布的右下角坐标
  /// 这个坐标会在每次收笔时重置
  Offset rightbottomPosition = Offset.zero;

  /// 每次进行书写时所留下的笔迹，
  /// 它是临时的，
  /// 这个笔迹会在每次收笔时重置
  ///
  /// 要访问书写的笔迹请转到 TODO 等待创建一个完整的笔迹接口
  Path tempTouch = Path();

  /// 如果要进行滑动
  bool runTouch = false;

  @override
  void initState() {
    super.initState();
    // ListView发生了变动就会刷新
    _scrollController.addListener(() {
      listviewNowPosition = _scrollController.position.pixels;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 加载一下ListView的初始大小
    listviewNowLength ??= MediaQuery.of(context).size.height;

    // 用ListView做出和苹果备忘录一样的无限向下笔记
    return ListView(
      controller: _scrollController,
      physics: runTouch
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: listviewNowLength,
          child: Listener(
            // 设置全局监听笔迹
            behavior: HitTestBehavior.translucent,
            // 落笔书写
            onPointerDown: (event) => beginTouch(event),
            // 移动笔迹
            onPointerMove: (event) => moveTouch(event),
            // 笔离开屏
            onPointerUp: (event) => endTouch(event),
            // 用于存放笔迹的组件
            child: Stack(
              children: [
                Shading(
                  shadingStyle: ShadingStyle.line,
                  shadingPadding: const EdgeInsets.all(5),
                  shadingSize: Size(
                      MediaQuery.sizeOf(context).width, listviewNowLength!),
                  lineSpacing: 50,
                ),
                // TODO 底纹显示有些问题，别慌哈！
                Stack(
                  children: writingWidgets,
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  /// 当笔（手指）落下来的操作
  /// - 识别是什么在写字
  /// - 记录起点
  /// - 创建新的书写组件
  /// - 新的书写组件的中心将是起笔的位置
  void beginTouch(PointerDownEvent touchevent) {
    // 识别是不是手写笔
    if (touchevent.kind == PointerDeviceKind.stylus ||
        widget.allowTouch == AllowTouch.allow) {
      // 写字时阻止屏幕滑动
      runTouch = true;

      // 获取手写笔的有关信息
      StylusData stylusData = StylusData(
        touchevent.pressure,
        touchevent.orientation,
        touchevent.tilt,
        touchevent.radiusMajor,
      );

      // 获取现在笔尖的位置，并进行纠偏
      Offset nowPosition = touchevent.localPosition + widget.appSafeAreaFix;

      // 将第一笔的位置赋值给所有的组件位置
      lefttopPosition = nowPosition;
      rightbottomPosition = nowPosition;
      tempTouch.moveTo(lefttopPosition.dx, lefttopPosition.dy);

      // 如果这个输入点的位置刚好靠近底部，那就加页
      // 这就是无限向下笔记的精髓！
      if (nowPosition.dy >
          listviewNowLength! - MediaQuery.sizeOf(context).height / 2) {
        setState(() {
          listviewNowLength =
              (listviewNowLength ?? 0.0) + MediaQuery.sizeOf(context).height;
        });
      }

      // 创建书写组件
      // 此后的书写操作均绑定到这个组件上
      setState(() {
        writingWidgets.add(WriteWidget(
          stylusData: stylusData,
          lefttopPosition: lefttopPosition,
          rightbottomPosition: rightbottomPosition,
          writingPath: tempTouch,
          isDebug: widget.isDebug,
          penProperties: widget.penProperties,
        ));
      });
    }
  }

  /// 当笔（手指）在屏幕上移动的时候
  /// - 记录当前的笔迹
  /// - 进行运算，
  ///   如果超过之前书写到达的最远的位置，
  ///   就扩充一下组件的大小
  /// - 刷新笔迹，
  ///   渲染轨迹后更新画布
  void moveTouch(PointerMoveEvent touchevent) {
    // 识别是不是手写笔
    if (touchevent.kind == PointerDeviceKind.stylus ||
        widget.allowTouch == AllowTouch.allow) {
      // 获取手写笔的有关信息
      StylusData stylusData = StylusData(
        touchevent.pressure,
        touchevent.orientation,
        touchevent.tilt,
        touchevent.radiusMajor,
      );

      // 获取现在笔尖的位置，并进行纠偏
      Offset nowPosition = touchevent.localPosition + widget.appSafeAreaFix;

      // 描绘笔迹的轨迹
      tempTouch.lineTo(nowPosition.dx, nowPosition.dy);

      // 是否超过最远距离
      lefttopPosition = Offset(
        min(lefttopPosition.dx, nowPosition.dx),
        min(lefttopPosition.dy, nowPosition.dy),
      );
      rightbottomPosition = Offset(
        max(rightbottomPosition.dx, nowPosition.dx),
        max(rightbottomPosition.dy, nowPosition.dy),
      );

      // 如果这个输入点的位置刚好靠近底部，那就加页
      // 这就是无限向下笔记的精髓！
      if (nowPosition.dy >
          listviewNowLength! - MediaQuery.sizeOf(context).height / 2) {
        setState(() {
          listviewNowLength = (listviewNowLength ?? 0.0) +
              MediaQuery.sizeOf(context).height / 2;
        });
      }

      // 刷新笔迹，就要将之前的就笔迹给删掉
      writingWidgets.removeLast();

      // 最后刷新之前绑定的书写组件
      // 删掉旧组件再添加新组件不影响这个书写组件在画板上的作用
      setState(() {
        writingWidgets.add(WriteWidget(
          lefttopPosition: lefttopPosition,
          rightbottomPosition: rightbottomPosition,
          writingPath: tempTouch,
          isDebug: widget.isDebug,
          penProperties: widget.penProperties,
          stylusData: stylusData,
        ));
      });
    }
  }

  /// 当笔（手指）从屏幕上离开的时候
  /// - 封装这个笔迹
  /// - 停止让CustomPaint下一次画图再去刷新它
  void endTouch(PointerUpEvent touchevent) {
    // 如果发现屏幕只是被点了一个小点，
    // 那就把这个画布给删掉，
    // 避免浪费
    final pathCounter = tempTouch.computeMetrics();
    if (pathCounter.isEmpty) {
      writingWidgets.removeLast();
    }

    // 恢复屏幕滑动
    runTouch = false;

    // 对所有临时组件进行归零处理，以便下次使用
    lefttopPosition = Offset.zero;
    rightbottomPosition = Offset.zero;
    tempTouch = Path();

    // 执行一下停止书写的外部函数，比如保存笔迹
    widget.onWriteFinish(touchevent);
  }
}
