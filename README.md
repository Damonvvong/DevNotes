# iOS 开发笔记

## App优化相关

- [我的 App 『减肥计划』(一)](https://github.com/Damonvvong/iOSDevNotes/blob/master/Notes/AppBetter_1.md)
    - 如果你不知道下面几个问题，不妨可以看看文章。
        - 使用 .xcassets 有什么好处?
        - @1x 、@2x 和 @3x 会一起内置到安装包中吗？
        - PDF 和 @1x 、@2x 和 @3x 有什么区别？
        - 如果我有一个 10 x 10 的控件和一个 50 x 50 的控件，美工需要制作几张 PDF？
        - Iconfont 是什么？PDF 和 Iconfont 有什么区别？
        - 启动图的正确打开方式？
        - 使用 Swift 或者 混编会增大多少的包体积？
        - Install Smallest  or Coding Fastest ？

## iOS 开发中的『库』
- [iOS 开发中的『库』(一)](https://github.com/Damonvvong/iOSDevNotes/blob/master/Notes/framework.md)
    - .framework 是什么？怎么制作？
    - 谈一谈自己对动态库和静态库的理解。
    - 在项目中如何使用动态framework的 APP ？使用了动态framework 的 APP 能上架 Appstore 么？
    - 可以通过 framework 的方式实现 app 的热修复么？
- [iOS 开发中的『库』(二)](https://github.com/Damonvvong/iOSDevNotes/blob/master/Notes/framework2.md)
    - 再谈一谈动态库和静态库。~~你真的知道 XXXX 和 XXX 系列。~~
    - 为什么使用动态库的方式来动态更新只能用在 **in house** 和**develop** 模式却不能在使用到 **AppStore** 上呢？
    - 动态库到底会添加到内存中几次？

## CocoaPods 相关
- [CocoaPods 1.0 + 适配](https://github.com/Damonvvong/DWCategory)
    - CocoaPods 1.0 安装及适配
    - 利用 CocoaPods 发布自己的三方库
    - CocoaPods 1.0 私有 Pods 

## 功能模仿        
- [微信小视屏模仿 - AVFoundation 入门](https://github.com/Damonvvong/iOSDevNotes/blob/master/Notes/videorecoder.md)
    - **技术路线**: iOS 开发中的视频录制主要技术路线。
    - AVFoundation 的初步使用:**先录制再压缩**。[Demo1](https://github.com/Damonvvong/iOSDevNotes/tree/master/Demo/VideoRecoderDemo)
    - 优化方案:按帧压缩视频、**边录制边压缩**。[Demo2](https://github.com/Damonvvong/iOSDevNotes/tree/master/Demo/DWShortVideoRecoder)
    - Tips：如何从导出真机沙盒里面的文件、iOS 默认可选预设


## Swift Tips
- [Swift 3 迁移工作总结](https://github.com/Damonvvong/iOSDevNotes/blob/master/Notes/SwiftTips_1.md)
    - 一天时间将4万行 Swift 2 To Swift 3 的工作总结。
    - 迁移中的问题
- [Swift 性能相关](https://github.com/Damonvvong/iOSDevNotes/blob/master/Notes/swift_performance.md)
    - 为什么说 **Swift** 相比较于 **Objective-C** 会更加**快** ？
    - 为什么在编译 **Swift** 的时候这么**慢** ？
    - 如何更**优雅**的去写 Swift ？


