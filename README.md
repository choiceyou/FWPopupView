# IOS之弹窗 -- Swift4.0/[Objective-C版本(Swift、Objective-C版本别分实现了不同的功能！！！)](https://github.com/choiceyou/FWPopupViewOC)

[![Platform](http://img.shields.io/badge/platform-iOS-blue.svg?style=flat)](http://cocoapods.org/?q=FWPopupView)&nbsp;
![Language](https://img.shields.io/badge/language-swift-orange.svg?style=flat)&nbsp;
[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/choiceyou/FWPopupView/blob/master/FWPopupView/LICENSE)

*注意：*
*1、弹窗基类分别使用了OC和Swift来实现，同时OC和Swift版本分别实现了几个不同的弹窗效果;*
*2、Objective-C类需要继承弹窗基类时必须选择该库的Objective-C版本中的基类；*
*3、两个库可以同时存在一个项目中，建议两个库同时使用。*




## 温馨提示：
```温馨提示
1、同一窗口内目前只支持弹窗一个弹窗，如果需要同时展示两个弹窗，建议与系统或者其他自定义弹窗配合使用；
2、如需两个弹窗接连使用，请保证第一个弹窗完全消失再调用第二个弹窗；
3、鉴于方法或者属性可能跟着版本改动，因此强烈建议使用该库时封装一层后再使用！！！
```



## 支持pod导入：

```cocoaPods
use_frameworks!
pod 'FWPopupView'
注意：如出现 [!] Unable to find a specification for 'FWPopupView' 错误 或 看不到最新版本，可执行 pod repo update 命令更新一下本地pod仓库。
```



## 简单使用：（注：可下载demo具体查看，分别有OC、Swift的demo） 
```swift
/// 类初始化方法
///
/// - Parameters:
///   - title: 标题
///   - detail: 描述
///   - confirmBlock: 确定按钮回调
/// - Returns: self
open class func alert(title: String,
                     detail: String,
               confirmBlock: @escaping FWPopupItemHandler) -> FWAlertView
                          
```

```swift
/// 类初始化方法
///
/// - Parameters:
///   - title: 标题
///   - itemTitles: 点击项标题
///   - itemBlock: 点击回调
///   - cancenlBlock: 取消按钮回调
///   - property: FWSheetView的相关属性
/// - Returns: self
open class func sheet(title: String?,
                 itemTitles: [String],
                  itemBlock: @escaping FWPopupItemHandler,
               cancenlBlock: @escaping FWPopupVoidBlock,
                   property: FWSheetViewProperty?) -> FWSheetView
```

### Swift:
```swift
let alertView = FWAlertView.alert(title: "标题", detail: "描述描述描述描述") { (index) in
    print("点击了确定")
}
alertView.show()
```
```python
let sheetView = FWSheetView.sheet(title: "测试", 
                             itemTitles: ["Sheet0", "Sheet1", "Sheet2", "Sheet3"], 
                              itemBlock: { (index) in
    print("Sheet：点击了第\(index)个按钮")
}, cancenlBlock: {
    print("点击了取消")
})
sheetView.show()
```


### OC：<br>
```oc
FWAlertView *alertView = [FWAlertView alertWithTitle: @"标题" 
                                              detail: @"描述描述描述描述" 
                                        confirmBlock:^(NSInteger index) {
    NSLog(@"点击了确定");
}];
[alertView show];
```
```oc
FWSheetView *sheetView = [FWSheetView sheetWithTitle: @"标题" 
                                          itemTitles: @[@"Sheet0", @"Sheet1", @"Sheet2", @"Sheet3"] 
                                           itemBlock:^(NSInteger index) {
    NSLog(@"Sheet：点击了第 %ld 个按钮", (long)index);
} cancenlBlock:^{
    NSLog(@"点击了取消");
}];
[sheetView show];
```



## 效果：
![](https://github.com/choiceyou/FWPopupView/blob/master/%E6%95%88%E6%9E%9C/IMG_0714.PNG)
![](https://github.com/choiceyou/FWPopupView/blob/master/%E6%95%88%E6%9E%9C/IMG_0715.PNG)

![](https://github.com/choiceyou/FWPopupView/blob/master/%E6%95%88%E6%9E%9C/IMG_0716.PNG)
![](https://github.com/choiceyou/FWPopupView/blob/master/%E6%95%88%E6%9E%9C/IMG_0717.PNG)

![](https://github.com/choiceyou/FWPopupView/blob/master/%E6%95%88%E6%9E%9C/IMG_0718.PNG)
![](https://github.com/choiceyou/FWPopupView/blob/master/%E6%95%88%E6%9E%9C/IMG_0719.PNG)

![](https://github.com/choiceyou/FWPopupView/blob/master/%E6%95%88%E6%9E%9C/IMG_0720.PNG)
![](https://github.com/choiceyou/FWPopupView/blob/master/%E6%95%88%E6%9E%9C/IMG_0721.PNG)

![](https://github.com/choiceyou/FWPopupView/blob/master/%E6%95%88%E6%9E%9C/IMG_0216.PNG)
![](https://github.com/choiceyou/FWPopupView/blob/master/%E6%95%88%E6%9E%9C/IMG_0217.PNG)

![](https://github.com/choiceyou/FWPopupView/blob/master/%E6%95%88%E6%9E%9C/Custom.gif)
![](https://github.com/choiceyou/FWPopupView/blob/master/%E6%95%88%E6%9E%9C/Menu.gif)

![](https://github.com/choiceyou/FWPopupView/blob/master/%E6%95%88%E6%9E%9C/IMG_0218.PNG)
![](https://github.com/choiceyou/FWPopupView/blob/master/%E6%95%88%E6%9E%9C/IMG_0219.PNG)



## 更新记录：

• v2.0.4：
- [x] 支持图形加载完成后用户添加代理事件灰色背景默认值由原来的 alpha=0.6 改为 alpha=0.5；
- [x] 在原类初始化方法中添加输入框键盘类型参数：UIKeyboardType（鉴于方法可能跟着版本改动，所以建议封装使用）；
  
• v2.0.5:
- [x] 修复弹窗隐藏时未设置原window为keywindow的问题；
  
• v2.0.6:
- [x] 原FWPopupItemHandler改为FWPopupItemClickedBlock，增加反馈当前弹窗参数；
- [x] FWItemType加入参数canAutoHide：点击该按钮后会自动隐藏弹窗。这样子做能够适应更多的弹窗场景；
  
• v2.0.7:
- [x] 支持单独设置某个按钮的文字、背景颜色；
  
• v3.0.0（大版本）:
- [x] 弹窗基类重构：设置视图展示位置+偏移量来设置弹窗真正需要展示的位置；有多重可选动画类型。
- [x] 由于OC类不能继承Swift类，所以弹窗基类实现了两种语言。swift版本：FWPopupView；OC版本：FWPopupBaseView；
- [x] FWAlertView/FWSheetView/FWDateView使用基类提供动画类型；
- [x] 新增FWMenuView，可实现类似QQ/微信首页右上角菜单；
- [x] 其他细节修改；
  
• v3.0.1:
- [x] FWPopupItemClickedBlock回调增加标题参数（注：由于不想维护多个回调，这边没有考虑兼容旧版回调，所以建议封装使用）；
- [x] 修复FWSheetView未设置标题时有多余间距的问题；
  
• v3.0.2:
- [x] 增加：保证前一次弹窗销毁的处理机制；
- [x] FWDateView开放UIDatePicker，外部可以针对不同需求进行修改；
  
• v3.0.3:
- [x] 修复xib加载View方式时，继承弹窗基类FWPopupView崩溃问题；
- [x] FWSheetView适配iPhoneX（在安全区域显示）；
  
• v3.0.5:
- [x] 为防止点击某个弹窗按钮后需要继续弹出另外一个弹窗后出错问题，改为弹窗消失后执行回调；
- [x] 添加支持弹簧动画效果；
  
• v3.0.6：
- [x] 添加弹窗状态：FWPopupState；
- [x] 根据状态对应的进行回调，这样子可以根据实际使用来回调；
  
• v3.0.7：
- [x] FWMenuView新增支持修改背景色等相关属性；
  
• v3.0.8：
- [x] FWAlertView带输入框输入支持密码安全类型；

• v3.0.9：
- [x] FWSheetView支持修改“取消”按钮的名称；

• v3.1.1：
- [x] 添加控件：FWCustomSheetView，该控件实现了单选效果；

• v3.1.3：
- [x] 修改回调策略：点击某个按钮后立刻给对应的回调。旧版本代码升级不需要修改代码，也不会有其他影响；

• v3.1.5：
- [x] 修改FWPopupView弹起时改变了状态栏的颜色问题；
- [x] 修改FWCustomSheetView复用时产生的bug；



## 结尾语：

- 使用过程中发现bug请issues或加入FW问题反馈群：670698309（此群只接受FW相关组件问题）；
- 有新的需求欢迎提出；
