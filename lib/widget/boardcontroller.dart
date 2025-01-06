import 'package:flutter/widgets.dart';
import 'package:notepad_forwangtao_writingboard/func/writingobject.dart';

/// ### 书写板控制器
///
/// #### 介绍
///
/// {@template WritingboardController.介绍}
///
/// 这是整个书写板的核心,
/// 它绑定了书写板从起笔到落笔的所有事件,
/// 此外它还能对书写板进行控制,比如:
///
///   * 它能决定书写板的模式(生产或者Debug模式)
///   * 它能 **存放** 写过的笔迹,将读取的笔迹 **映射** 到书写板上
///   * 它给出了书写板的 **撤销和重做** 功能映射
///   * 它让我们可以将自己定义的笔放到 **书写板的笔盒** 上并且随时调用
///   * 它能便捷的直接将 **切换笔/橡皮擦/框选功能** 绑定到任一事件上
///
/// {@endtemplate}
///
/// #### 使用
class WritingboardController extends ChangeNotifier {
  /// ### 让书写板处于调试模式
  ///
  /// #### 介绍
  ///
  /// {@template WritingboardController.isdebug.介绍}
  ///
  /// 正常使用书写板的时候请不要给它赋值,
  /// 如果需要调试你的应用使用书写板的状态,
  /// 可以打开它查看运行时的情况
  ///
  /// {@endtemplate}
  ///
  /// #### 使用
  ///
  /// 如果调试状态被打开的话,
  /// 会在每个组件上显示一个框框用于展示它的大小和中心点,
  /// 并会在旁边显示组件书写时的:
  ///
  /// * 书写时用的设备
  /// * 此次书写的序号
  /// * 书写时的实时刷新率
  /// * 书写时的实时速度
  /// * 书写设备的笔尖的坐标
  /// * 书写设备的压感/握笔方向/倾斜角/笔尖的形状
  ///
  /// <!--
  /// TODO 还未实现显示刷新率、压感、速度和握笔方向的功能
  /// -->
  bool get isdebug => _isdebug;

  /// ### 定义允许书写的输入设备
  ///
  /// {@macro WritingboardController.TouchMode.介绍}
  TouchFilter get touchfilter => _touchfilter;

  /// ### 阅读模式与书写模式的切换
  ///
  /// {@macro WritingboardController.WriteReadMode.介绍}
  WriteReadMode get writereadmode => _writereadmode;

  /// ### 存放笔迹的列表
  List<WritingObject> get writingObjects => _writingObjects;

  /// ### 存放重做笔迹的列表
  List<WritingObject> get redoObjects => _redoObjects;

  /// {@macro WritingboardController.isdebug.介绍}
  bool _isdebug = false;

  /// {@macro WritingboardController.TouchMode.介绍}
  TouchFilter _touchfilter = TouchFilter.allowPenOnly;

  /// {@macro WritingboardController.WriteReadMode.介绍}
  WriteReadMode _writereadmode = WriteReadMode.readMode;

  ///
  final List<WritingObject> _writingObjects = [];

  ///
  final List<WritingObject> _redoObjects = [];

  /// 设置调试模式
  void setDebug({required bool value}) {
    _isdebug = value;
    notifyListeners();
  }

  /// 设置输入设备筛选
  void setTouchFilter({required TouchFilter value}) {
    _touchfilter = value;
    notifyListeners();
  }

  /// 设置书写板模式
  void setWriteReadMode({required WriteReadMode value}) {
    _writereadmode = value;
    notifyListeners();
  }

  /// 撤销功能
  void clickUndo() {
    if (_writingObjects.isNotEmpty) {
      _redoObjects.add(_writingObjects.last);
      _writingObjects.removeLast();
    }
    notifyListeners();
  }

  /// 重做功能
  void clickRedo() {
    if (_redoObjects.isNotEmpty) {
      writingObjects.add(_redoObjects.last);
      _redoObjects.removeLast();
    }
  }
}

/// ### 定义允许书写的输入设备
///
/// #### 介绍
///
/// {@template WritingboardController.TouchMode.介绍}
///
/// 允许哪一种书写形式进行书写(笔类/指针/所有)
///
/// 一般来说,
/// 在平板上用手写笔书写是最自然也是最舒服的书写方式,
/// 但是我们也会在手机上用触摸屏批注签名,
/// 或者在电脑上用鼠标画重点
///
/// 但是 **笔/触摸/鼠标** 的逻辑是各不相同的,
/// 例如 **笔/鼠标** 可以实现阅读与书写独立操作,
/// (书写用手写笔/鼠标拖动，阅读用触摸/鼠标滚轮)
/// 但是触摸在执行书写和翻阅两者操作会打架导致写不了字,
/// 所以必须要分离一下这些模式的操作
///
/// {@endtemplate}
enum TouchFilter {
  /// 允许所有输入设备进行书写
  ///
  /// 包括
  /// * 手写笔/数位板 这些笔类输入设备
  /// * 手写笔/数位板/鼠标/触摸板 这些指针输入设备
  /// * 手写笔/数位板/鼠标/触摸板/触摸屏 这些输入设备
  allowAll,

  /// 允许指针输入设备进行书写
  ///
  /// 包括
  /// * 手写笔/数位板 这些笔类输入设备
  /// * 手写笔/数位板/鼠标/触摸板 这些指针输入设备
  allowPointer,

  /// 允许笔类输入设备进行书写
  ///
  /// 仅包括 手写笔/数位板 这些笔类输入设备
  allowPenOnly
}

/// ### 阅读模式与书写模式的切换
///
/// #### 介绍
///
/// {@template WritingboardController.WriteReadMode.介绍}
///
/// 可以让书写板处于阅读模式或者是书写模式
///
/// 阅读模式将会限制书写板的书写功能,
/// 此时你拿各类输入设备对书写板进行滑动操作,
/// 书写板会服帖的跟随着滑动,
/// 不怕有莫名其妙的笔迹留在书写板上
///
/// 而书写模式会限制书写板的翻阅功能,
/// 此时分两种情况:
/// * 你禁用了一些输入设备进行书写(比如限制了触控屏或者仅允许笔类)
///   * 此时你使用被禁用的输入设备对书写板进行滑动,
///     书写板就会像阅读模式一样服帖的跟随着滑动,
///     而不会在书写板上留下笔迹.
///   * 但是你使用未被禁用的输入设备对书写板进行滑动,
///     书写板则不会进行滑动,
///     而是直接在书写板上留下笔迹
///   * 当然你使用被禁用的设备和未被禁用的设备同时在书写板上滑动
///     书写板则直接锁定起来不滑动,
///     那些未被禁用的设备会留下笔迹,
///     被禁用的设备滑动的动作将被抛弃
/// * 你没有禁用输入设备,所有输入设备均可用
///   * 此时书写板也会被直接锁定起来不滑动,
///     输入设备只会在书写板上留下笔迹
///
/// {@endtemplate}
///
/// #### 故事
///
/// 苹果的备忘录是我用的最熟的笔记APP了,
/// 比第三方像GoodNotes啊云记啊的对我来说更顺手些,
/// 一个最重要的原因是它是无限向下笔记,
/// 而不像其他笔记软件是要手动加页的
///
/// 苹果备忘录有个逻辑,
/// 就是在不点开右上角的ApplePencil笔盒的时候,
/// 备忘录就会处于阅读模式,
/// 单手可以翻阅笔记,
/// 但是除非你双击屏幕进入编辑模式,
/// 不然它不会轻易对笔记进行编辑操作的
enum WriteReadMode {
  /// 书写模式
  writeMode,

  /// 阅读模式
  readMode,
}
