/// 汪涛的记事本 书写板组件
///
/// "汪涛的记事本"的所有书写组件就是基于它开发的，简单又好用
library notepad_forwangtao_writingboard;

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

part 'class/input.dart';
part 'class/point.dart';
part 'enum/writingboard.dart';
part 'func/writer.dart';
part 'func/writingboard.dart';
part 'widget/boardshading.dart';
part 'widget/writingboard.dart';
part 'widget/writingobject.dart';

class WritingBoard extends StatelessWidget {
  /// ## 让书写板处于调试模式
  ///
  /// ### 介绍
  /// 正常使用书写板的时候请忽视它，
  /// 如果需要调试你的应用使用书写板的状态，
  /// 可以打开它查看运行时的情况 [bool]
  ///
  /// 如果处于调试状态的话，
  /// 会在每个组件上显示一个框框用于展示它的大小和中心点
  /// 并会在旁边显示组件书写时的：
  /// - 书写时用的设备
  /// - 此次书写的序号
  /// - 书写时的实时刷新率
  /// - 书写时的实时速度
  /// - 书写设备的笔尖的坐标
  /// - 书写设备的压感、握笔方向和倾斜角、笔尖的形状
  /// <!--
  /// TODO 还未实现显示刷新率、压感、速度和握笔方向的功能
  /// -->
  ///
  /// ### 如何引入
  /// ```dart
  /// Writingboard(
  ///   ...
  ///   // 不需要使用调试功能，请忽略它
  ///
  ///   // 如果你需要使用调试模式测试自身的应用，传入true
  ///   isDebug: true,
  ///   // 或者引入一个切换器 [bool]
  ///   isDebug: isDebugSwitcher
  /// ),
  /// ```
  ///
  final bool isDebug;

  /// ## 允许其他输入工具进行书写吗
  ///
  /// ### 介绍
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
  final AllowTouch allowTouch;

  /// ## 阅读模式与书写模式的切换
  ///
  /// ### 介绍
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

  /// ## SafeArea纠偏
  ///
  /// ### 介绍
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

  /// ## 书写板动作组件管理器
  ///
  /// ### 介绍
  /// 这是一个非常厉害的工具
  final WritingObjectManager writingObjectManager;

  /// 书写板
  ///
  /// 它主要实现的流程是这样的：
  /// - 首先，我在画板上画出第一划的时候，笔或者手指落在屏幕的时候，开始建立一个新画布
  /// - 然后，笔或手指开始运动，此时测量一下笔尖到达的最远的地方，画布的大小也就这么大
  /// - 最后，手指放开，结束记录，将这个笔迹封存并且停止更新笔迹内容，将资源留给别的笔画
  const WritingBoard({
    super.key,
    this.isDebug = false,
    this.allowTouch = AllowTouch.disallow,
    this.modeWriteRead = WriteReadMode.readMode,
    this.appSafeAreaFix = Offset.zero,
    required this.writingObjectManager,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Shading(
          shadingStyle: ShadingStyle.line,
          shadingPadding: EdgeInsets.all(5),
          shadingSize: Size.zero, // TODO 底纹还是做的有点问题
          lineSpacing: 50,
        ),
        _WritingBoardCore(
          isDebug: isDebug,
          allowTouch: allowTouch,
          modeWriteRead: modeWriteRead,
          appSafeAreaFix: appSafeAreaFix,
          writingObjectManager: writingObjectManager,
        )
      ],
    );
  }
}
