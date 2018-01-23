#### iOS 开发笔记

<details>
<summary> **优化相关** </summary>

- [iOS App 瘦身 - 以 Swift App Yep 为例](https://github.com/Damonvvong/DevNotes/blob/master/Notes/optimize_app_size_1.md)
    - 使用 **.xcassets** 有什么好处? 放置在 **.xcassets** 的 **PDF** 在编译时会如何处理？
    - 什么是 App Slicing? 
    - 如果我有一个 10 x 10 的控件和一个 50 x 50 的控件，美工需要制作几张 PDF？
    - 启动图的正确打开方式？
    - 使用 Swift 混编的项目会对包体积有什么影响？到底如何抉择是否使用Swift。
    - 
</details>

<details>
<summary> 原理相关 </summary>

- [iOS 开发中的『库』(一)](https://github.com/Damonvvong/DevNotes/blob/master/Notes/framework.md)
    - .framework 是什么？怎么制作？
    - 谈一谈自己对动态库和静态库的理解。
    - 在项目中如何使用动态framework的 APP ？使用了动态framework 的 APP 能上架 Appstore 么？
    - 可以通过 framework 的方式实现 app 的热修复么？

- [iOS 开发中的『库』(二)](https://github.com/Damonvvong/DevNotes/blob/master/Notes/framework2.md)
    - 再谈一谈动态库和静态库。~~你真的知道 XXXX 和 XXX 系列。~~
    - 为什么使用动态库的方式来动态更新只能用在 **in house** 和**develop** 模式却不能在使用到 **AppStore** 上呢？
    - 动态库到底会添加到内存中几次？

</details>

<details>
<summary> **工具相关** </summary>

- [CocoaPods 1.0 + 适配](https://github.com/Damonvvong/DWCategory)
    - CocoaPods 1.0 安装及适配
    - 利用 CocoaPods 发布自己的三方库
    - CocoaPods 1.0 私有 Pods 

</details>

<details>
<summary> **功能模仿** </summary>
 
- [微信小视屏模仿 - AVFoundation 入门](https://github.com/Damonvvong/DevNotes/blob/master/Notes/videorecoder.md)
    - **技术路线**: iOS 开发中的视频录制主要技术路线。
    - AVFoundation 的初步使用:**先录制再压缩**。[Demo1](https://github.com/Damonvvong/iOSDevNotes/tree/master/Demo/VideoRecoderDemo)
    - 优化方案:按帧压缩视频、**边录制边压缩**。[Demo2](https://github.com/Damonvvong/iOSDevNotes/tree/master/Demo/DWShortVideoRecoder)
    - Tips：如何从导出真机沙盒里面的文件、iOS 默认可选预设
</details>


<details>
<summary> **Swift 相关** </summary>

- [Swift 3 迁移工作总结](https://github.com/Damonvvong/DevNotes/blob/master/Notes/SwiftTips_1.md)
    - 一天时间将4万行 Swift 2 To Swift 3 的工作总结。
    - 迁移中的问题
- [Swift 性能相关](https://github.com/Damonvvong/DevNotes/blob/master/Notes/swift_performance.md)
    - 为什么说 **Swift** 相比较于 **Objective-C** 会更加**快** ？
    - 为什么在编译 **Swift** 的时候这么**慢** ？
    - 如何更**优雅**的去写 Swift ？
- [Swift 编码规范](https://github.com/Damonvvong/DevNotes/blob/master/Notes/swift_performance.md)
    - 参照 [Raywenderlich Swift Style Guide](https://github.com/raywenderlich/swift-style-guide)、[Linkedin Swift Style Guide](https://github.com/linkedin/swift-style-guide)、[Github Swift Style Guide](https://github.com/github/swift-style-guide)、[Eure  Swift Style Guide](https://github.com/eure/swift-style-guide) 总结的规范
</details>


