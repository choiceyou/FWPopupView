IOS之弹窗 -- OC/Swift4.0  
===================================  

### 支持pod导入：

pod 'FWPopupView'<br>
注意：如出现 [!] Unable to find a specification for 'FWPopupView' 错误，可执行 pod repo update 命令。

-----------------------------------

### 简单使用：  
```python
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

```python
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
                      itemBlock:@escaping FWPopupItemHandler,
                      cancenlBlock:@escaping FWPopupVoidBlock,
                      property: FWSheetViewProperty?) -> FWSheetView
```

### Swift:
```python
let alertView = FWAlertView.alert(title: "标题", detail: "描述描述描述描述") { (index) in
    print("点击了确定")
}
alertView.show()
```
```python
let sheetView = FWSheetView.sheet(title: "测试", itemTitles: ["Sheet0", "Sheet1", "Sheet2", "Sheet3"], itemBlock: { (index) in
                print("Sheet：点击了第\(index)个按钮")
            }, cancenlBlock: {
                print("点击了取消")
            })
sheetView.show()
```


### OC：<br>

-----------------------------------  

### 效果：
![](https://github.com/choiceyou/FWPopupView/blob/master/%E6%95%88%E6%9E%9C/IMG_0598.PNG)
![](https://github.com/choiceyou/FWPopupView/blob/master/%E6%95%88%E6%9E%9C/IMG_0599.PNG)
![](https://github.com/choiceyou/FWPopupView/blob/master/%E6%95%88%E6%9E%9C/IMG_0600.PNG)
![](https://github.com/choiceyou/FWPopupView/blob/master/%E6%95%88%E6%9E%9C/IMG_0601.PNG)
![](https://github.com/choiceyou/FWPopupView/blob/master/%E6%95%88%E6%9E%9C/IMG_0603.PNG)
![](https://github.com/choiceyou/FWPopupView/blob/master/%E6%95%88%E6%9E%9C/IMG_0604.PNG)

-----------------------------------

### 结尾语：

> 使用过程中有任何问题或者新的需求都可以issues我哦，谢谢！
