# IOS之弹窗 -- Swift4.2/[Objective-C版本(Swift、Objective-C版本别分实现了不同的功能！！！)](https://github.com/choiceyou/FWPopupViewOC)

[![Platform](http://img.shields.io/badge/platform-iOS-blue.svg?style=flat)](http://cocoapods.org/?q=FWPopupView)&nbsp;
![Language](https://img.shields.io/badge/language-swift-orange.svg?style=flat)&nbsp;
[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/choiceyou/FWPopupView/blob/master/FWPopupView/LICENSE)




## 使用说明：
```注意
1、弹窗基类分别使用了OC和Swift来实现，同时OC和Swift版本分别实现了几个不同的弹窗效果;
2、Objective-C类需要继承弹窗基类时必须选择该库的Objective-C版本中的基类；
3、两个库可以同时存在一个项目中，建议两个库同时使用。
```



## 温馨提示：
```温馨提示
1、同一窗口内目前只支持弹窗一个弹窗，如果需要同时展示两个弹窗，建议与系统或者其他自定义弹窗配合使用；
2、如需两个弹窗接连使用，请保证第一个弹窗完全消失再调用第二个弹窗；
3、鉴于方法或者属性可能跟着版本改动，因此强烈建议使用该库时封装一层后再使用；
4、如需在弹窗上展示SVProgressHUD，可设置：[SVProgressHUD setMaxSupportedWindowLevel:UIWindowLevelStatusBar+1]；
```



## 支持pod导入：

```cocoaPods
use_frameworks!
pod 'FWPopupView'
注意：
1、如出现 [!] Unable to find a specification for 'FWPopupView' 错误 或 看不到最新的版本，
  可执行 pod repo update 命令更新一下本地pod仓库。
2、use_frameworks! 的使用：
（1）纯OC项目中，通过cocoapods导入OC库时，一般都不使用use_frameworks!
（2）纯swift项目中，通过cocoapods导入swift库时，必须使用use_frameworks!
（3）只要是通过cocoapods导入swift库时，都必须使用use_frameworks!
（4）使用动态链接库dynamic frameworks时，必须使用use_frameworks!
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

• v4.0.0（大版本）:
- [x] 使用SnapKit库重构了弹窗基类及部分弹窗视图；
- [x] 支持横竖屏切换；
- [x] 支持多个弹窗存在（详细请查看：同时显示两个弹窗的演示）；
- [x] 升级到Swift4.2；

• v4.0.2:
- [x] 解决app进入后台时隐藏弹窗可能出现界面卡死问题；
- [x] 解决多次调用显示、隐藏的安全判断（会导致约束出错问题）；

• v4.0.3:
- [x] 增加hiddenViews添加视图的条件判断，解决某些视图已经创建了，但还未显示过一次依然会加入hiddenViews的问题；

• v4.0.4:
- [x] 支持重新设置弹窗视图size；
- [x] 添加两种弹窗状态：didAppearButCovered、didAppearAgain；
- [x] 新增 titleFont、buttonFont、detailFont 属性；

• v4.0.5:
- [x] FWAlertView、FWSheetView、FWDateView 中相关字体默认改为不加粗，即boldSystemFont 改为systemFont；
- [x] FWPopupItem中新增itemTitleFont，该属性优先权大于全局变量，如需使用该变量可使用：初始化方法3；

• v4.0.6:
- [x] 解决某个类中同时存在两个非懒加载方式的弹窗成员变量，前一个点击外部隐藏时会影响另外一个弹窗显示的问题；
- [x] FWSheetView：FWSheetViewProperty可设置取消按钮的字体颜色、大小以及背景颜色；

• v4.0.8:
- [x] 解决xcode11中FWPopupWindow单例初始化问题；
- [x] 其它细节优化；

• v4.0.9:
- [x] 部分组件适配ios13的深色模式；

• v4.1.1:
- [x] FWPopupView新增渐变背景色功能：backgroundLayerColors；
- [x] FWMenuView细节优化；

• v4.1.2:
- [x] 解决xcode11.x新建（含SceneDelegate）的项目中弹窗不显示的问题；

• v4.1.3:
- [x] 原FWPopupWindow类改名：FWPopupSWindow（主要为了解决OC项目同时引入：FWPopupView、FWPopupViewOC库时需要使用FWPopupWindow时类重名的问题）；
- [x] FWPopupSWindow新增removeAllPopupView方法：隐藏全部的弹窗（包括当前不可见的弹窗）；

• v4.1.4:
- [x] 解决还原keywindow时未判断原记录的window是否keywindow的问题；

• v4.1.5:
- [x] 支持 xib 方式创建弹窗；



## 结尾语：

- 使用过程中发现bug请issues或加入FW问题反馈群：670698309（此群只接受FW相关组件问题）；
- 有新的需求欢迎提出；
