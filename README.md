IOS之弹窗 -- OC/Swift4.0  
===================================  

支持pod导入：
-----------------------------------
pod 'FWPopupView'<br>
注意：如出现 [!] Unable to find a specification for 'FWPopupView' 错误，可执行 pod repo update 命令。

简单使用：  
-----------------------------------  
### Swift: <br>
let alertView = FWAlertView.alert(title: "标题", detail: "描述描述描述描述") { (index) in <br>
    print("点击了确定") <br>
} <br>
alertView.show()<br>
            
### OC：<br>

效果：
-----------------------------------


结尾语：
-----------------------------------
使用过程中有任何问题或者新的需求都可以issues我哦，谢谢！
