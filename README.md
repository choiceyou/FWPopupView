# IOS之弹窗 -- OC/Swift4.0

[![Platform](http://img.shields.io/badge/platform-iOS-blue.svg?style=flat)](http://cocoapods.org/?q=FWPopupView)&nbsp;
![Language](https://img.shields.io/badge/language-swift-orange.svg?style=flat)&nbsp;
[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/choiceyou/FWPopupView/blob/master/FWPopupView/LICENSE)



## 支持pod导入：

```cocoaPods
pod 'FWPopupView'<br>
注意：如出现 [!] Unable to find a specification for 'FWPopupView' 错误，可执行 pod repo update 命令。
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
               confirmBlock:@escaping FWPopupItemHandler) -> FWAlertView
                          
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
FWSheetView *sheetView = [FWSheetView sheetWithTitle:@"标题" 
                                          itemTitles:@[@"Sheet0", @"Sheet1", @"Sheet2", @"Sheet3"] 
                                           itemBlock:^(NSInteger index) {
    NSLog(@"Sheet：点击了第 %ld 个按钮", (long)index);
} cancenlBlock:^{
    NSLog(@"点击了取消");
}];
[sheetView show];
```



## 效果：
![](https://github.com/choiceyou/FWPopupView/blob/master/%E6%95%88%E6%9E%9C/IMG_0598.PNG)
![](https://github.com/choiceyou/FWPopupView/blob/master/%E6%95%88%E6%9E%9C/IMG_0599.PNG)

![](https://github.com/choiceyou/FWPopupView/blob/master/%E6%95%88%E6%9E%9C/IMG_0600.PNG)
![](https://github.com/choiceyou/FWPopupView/blob/master/%E6%95%88%E6%9E%9C/IMG_0601.PNG)

![](https://github.com/choiceyou/FWPopupView/blob/master/%E6%95%88%E6%9E%9C/IMG_0603.PNG)
![](https://github.com/choiceyou/FWPopupView/blob/master/%E6%95%88%E6%9E%9C/IMG_0604.PNG)



## 结尾语：

> * 使用过程中有任何问题或者新的需求都可以issues我哦；
> * 欢迎关注本人更多的UI库，谢谢；
