# 优化 App 启动

苹果是一家特别注重用户体验的公司，过去几年一直在优化 App 的启动时间，特别是今年的 [WWDC 2019 keynote](https://developer.apple.com/videos/play/wwdc2019/101/) 上提到，在过去一年苹果开发团队对启动时间提升了 200%

虽然说是提升了 200%，但是有些问题还是没有说清楚，比如：
- 为什么优化了这么多时间？
- 作为开发者的我们，我们还可以做哪些针对启动速度的优化？

所以我们今天结合 [WWDC2019 - 423 - Optimizing App Launch](https://developer.apple.com/videos/play/wwdc2019/423/) 聊一下和启动相关的东西

# 名词解释

先介绍一些和启动相关的名词。

## Mach-O

Mach-O 是 iOS 系统不同运行时期可执行的文件的文件类型统称。主要分以下三类:
 
- **Executable：**可执行文件，是 App 中的主要二进制文件
- **Dylib：**动态库，在其他平台也叫 DSO 或者 DLL
- **Bundle：**苹果平台特有的类型，是无法被连接的 Dylib。只能在运行时通过 dlopen() 加载

Mach-O 的基本结构如下图所示，分为三个部分：
![Mach-O 的基本结构](https://images.xiaozhuanlan.com/photo/2019/c659113d77556430a2986f7c2cff666c.png)

- **Header** 包含了 Mach-O 文件的基本信息，如 CPU 架构，文件类型，加载指令数量等
- **Load Commands** 是跟在 Header 后面的加载命令区，包含文件的组织架构和在虚拟内存中的布局方式，在调用的时候知道如何设置和加载二进制数据
- **Data** 包含 Load Commands 中需要的各个 Segment 的数据。

绝大多数 Mach-O 文件包括以下三种 **Segment**：

- **__TEXT：** 代码段，包括头文件、代码和常量。只读不可修改。
- **__DATA：**数据段，包括全局变量, 静态变量等。可读可写。
- **__LINKEDIT：** 如何加载程序, 包含了方法和变量的元数据（位置，偏移量），以及代码签名等信息。只读不可修改。

## Image

指的是 Executable，Dylib 或者 Bundle 的一种。

## Framework

有很多东西都叫做 Framework，但在本文中，Framework 指的是一个 dylib，它周围有一个特殊的目录结构来保存该 dylib 所需的文件。

## 虚拟内存（Virtual Memory）

虚拟内存是建立在物理内存和进程之间的中间层。是一个连续的逻辑地址空间，而且逻辑地址可以没有对应的实际物理内存地址，也可以让多个逻辑地址对应到一个物理内存地址上。

#### Page Fault
    
当进程访问一个没有对应物理地址的逻辑地址时，会发生 Page Fault
    
#### Lazy Reading

某个想要读取的页没有在内存中就会触发 Page Fault，系统通过调用 mmap() 函数读取指定页，这个过程叫做 Lazy Reading
    
#### COW（Copy-On-Write）

当进程需要对某一页内容进行修改时，内核会把需要修改的部分先复制一份，然后再修改，并把逻辑地址重新映射到新的物理内存去。这个过程叫做 Copy-On-Write

#### Dirty Page & Clean Page

Image 加载后，被修改过内容的 Page 叫做 Dirty Page，会包含着进程特定的信息。与之相对的叫 Clean Page，可以从磁盘重新生成。
    
#### 共享内存（Share RAM）

当多个 Mach-O 都依赖同一个 Dylib（eg. UIKit）时，系统会让这几个 Mach-O 的调用 Dylib 的逻辑地址都指向同一块物理内存区域，从而实现内存共享。Dirty Page 为进程独有，不能被共享。

## 地址空间布局随机化（ASLR）

当 Image 加载到逻辑地址空间的时候，系统会利用 ASLR 技术，使得 Image 的起始地址总是随机的，以避免黑客通过起始地址+偏移量找到函数的地址

当系统利用 ASLR 分配了随机地址后，从 0 到该地址的整个区间会被标记为不可访问，意味着不可读，不可写，不可被执行。这个区域就是 `__PAGEZERO` 段，它的大小在 32 位系统是 4KB+，而在 64 位系统是 4GB+

## 代码签名（Code Sign）

代码签名可以让 iOS 系统确保要被加载的 Image 的安全性，用 Code Sign 设置签名时，每页内容都会生成一个单独的加密散列值，并存储到 `__LINKEDIT` 中去，系统在加载时会校验每页内容确保没有被篡改。

## dyld（dynamic loader）

dyld 是 iOS 上的二进制加载器，用于加载 Image。有不少人认为 dyld 只负责加载应用依赖的所有动态链接库，这个理解是错误的。dyld 工作的具体流程如下：
![](https://images.xiaozhuanlan.com/photo/2019/e2f3b2a00fbad1df5f9aaf24d8633d4e.png)
参考：[dyld启动流程](https://leylfl.github.io/2018/05/28/dyld启动流程/)

#### Load dylibs

dyld 在加载 Mach-O 之前会先解析 Header 和 Load Commands, 然后就知道了这个 Mach-O 所依赖的 dylibs，以此类推，通过递归的方式把全部需要的 dylib 都加载进来。

一般来说，一个 App 所依赖的 dylib 在 100 - 400 左右，其中大多数都是系统的 dylib，因为有缓存和共享的缘故，读取速度比较高。
    
#### Fix-ups

因为 ASLR 和 Code Sign 的原因，刚被加载进来的 dylib 都处于相对独立的状态，为了把它们绑定起来，需要经过一个 Fix-ups 过程。Fix-ups 主要有两种类型：Rebase 和 Bind。

#### PIC（Position Independent Code）
    
因为代码签名的原因，dyld 无法直接修改指令，但是为了实现在运行时可以 Fix-ups，在 code gen 时，通过动态 PIC（Position Independent Code）技术，使本来因为代码签名限制不能再修改的代码，可以被加载到间接地址上。当要调用一个方法时，会先在 `__DATA` 段中建立一个指针指向这个方法，再通过这个指针实现间接调用。

#### Rebase

Rebase 就是针对“因为 ASLR 导致 Mach-O 在加载到内存中是一个随机的首地址”这一个问题做一个数据修正的过程。会将内部指针地址都加上一个偏移量，偏移量的计算方法如下：
    
```
  Slide = actual_address - preferred_address
```

所有需要 Rebase 的指针信息已经被编码到 `__LINKEDIT` 里。然后就是不断重复地对 `__DATA` 中需要 Rebase 的指针加上这个偏移量。这个过程中可能会不断发生 Page Fault 和 COW，从而导致 I/0 的性能损耗问题，不过因为 Rebase 处理的是连续地址，所以内核会预先读取数据，减少 I/O 的消耗。
    
#### Binding

Binding 就是对调用的外部符号进行绑定的过程。比如我们要使用到 `UITableView`，即符号 `_OBJC_CLASS_$_UITableView`, 但这个符号又不在 Mach-O 中，需要从 UIKit.framework 中获取，因此需要通过 Binding 把这个对应关系绑定到一起。

在运行时，dyld 需要找到符号名对应的实现。而这需要很多计算，包括去符号表里找。找到后就会将对应的值记录到 `__DATA` 的那个指针里。Binding 的计算量虽然比 Rebasing 更多，但实际需要的 I/O 操作很少，因为之前 Rebasing 已经做过了。
   
#### dyld2 && dyld3
![](https://images.xiaozhuanlan.com/photo/2019/5a63e8d1b749512b1ae85b7abd3770d4.png)

在 iOS 13 之前，所有的第三方 App 都是通过 dyld 2 来启动 App 的，主要过程如下：

- 解析 Mach-O 的 Header 和 Load Commands，找到其依赖的库，并递归找到所有依赖的库
- 加载 Mach-O 文件
- 进行符号查找
- 绑定和变基
- 运行初始化程序

> 上面的所有过程都发生在 App 启动时，包含了大量的计算和I/O，所以苹果开发团队为了加快启动速度，在 [WWDC2017 - 413 - App Startup Time: Past, Present, and Future](https://developer.apple.com/videos/play/wwdc2017/413/) 上正式提出了 dyld3。

dyld3 被分为了三个组件：

- 一个进程外的 MachO 解析器

    - 预先处理了所有可能影响启动速度的 search path、@rpaths 和环境变量
    - 然后分析 Mach-O 的 Header 和依赖，并完成了所有符号查找的工作
    - 最后将这些结果创建成了一个启动闭包
    - 这是一个普通的 daemon 进程，可以使用通常的测试架构

- 一个进程内的引擎，用来运行启动闭包

    - 这部分在进程中处理
    - 验证启动闭包的安全性，然后映射到 dylib 之中，再跳转到 main 函数
    - 不需要解析 Mach-O 的 Header 和依赖，也不需要符号查找。

- 一个启动闭包缓存服务
    
    - 系统 App 的启动闭包被构建在一个 Shared Cache 中， 我们甚至不需要打开一个单独的文件
    - 对于第三方的 App，我们会在 App 安装或者升级的时候构建这个启动闭包。
    - 在 iOS、tvOS、watchOS中，这这一切都是 App 启动之前完成的。在 macOS 上，由于有 Side Load App，进程内引擎会在首次启动的时候启动一个 daemon 进程，之后就可以使用启动闭包启动了。

dyld 3 把很多耗时的查找、计算和 I/O 的事前都预先处理好了，这使得启动速度有了很大的提升。

# App 启动

介绍完上面这一大堆名词之后，我们正式进入主题。

## App 启动为什么这么重要？

- App 启动是和用户的第一个交互过程，所以要尽量缩短这个过程的时间，给用户一个良好的第一印象
- 启动代表了你的代码的整体性能，如果启动的性能不好，其他部分的性能可能也不会太好
- 启动会占用 CPU 和内存，从而影响系统性能和电池

所以我们要好好优化启动时间。

## 启动类型

App 的启动类型分为三类

- **Cold Launch** 也就是冷启动，冷启动需要满足以下几个条件：
    
    - 重启之后
    - App 不在内存中
    - 没有相关的进程存在    

- **Warm Launch** 也就是热启动，热启动需要满足以下几个条件：
    
    - App 刚被终止
    - App 还没完全从内存中移除
    - 没有相关的进程存在 

- **Resume Launch** 指的是被挂起的 App 继续的过程，需要满足以下几个条件：  

    - App 被挂起
    - App 还全部都在内存中
    - 还存在相关的进程

## App 启动阶段

App 启动分为三个阶段

- 初始化 App 的准备工作
- 绘制第一帧 App 的准备工作及绘制（这里的第一帧并不是获取到数据之后的第一帧，可以是一张占位视图），这时候用户与App已经可以交互了，比如 tabbar 切换
- 获取到页面的所有数据之后的完整的绘制第一帧页面

在这个地方，苹果再次强调了一下，**建议「用户从点击 App 图标到可以再次交互，也就是第二阶段结束」的时间最好在 400ms 以内**。目前来看，大部分 App 都没有达到这个目标。

下面，我们把上面三个阶段分成下面这 6 个部分，讲一下这几个阶段做了什么以及有什么可以优化的地方。

![](https://images.xiaozhuanlan.com/photo/2019/70cb1ea5e52566fa826ffdf6335acc5f.png)

#### System Interface

初始化 App 的准备工作，系统主要做了两个事情：Load dylibs 和 libSystem init

在 2017 年苹果介绍过 dyld3 给系统 App 带来了多少优化，今年 dyld3 正式开发给开发者使用，这意味着 iOS 系统会将你热启动的运行时依赖给缓存起来。以达到减少启动时间的目的。这也就是提升 200% 的原因之一。

> 视频中只说优化了热启动时间，理论上对于 iOS 系统来说 dyld3 应该还可以优化冷启动时间，所以不知道是因为给 iPad 增加了多任务功能的原因，还是没有把所有功能开放的原因，作者只提了热启动这个原因暂时还不太清楚。

除此之外，在 Load dylibs 阶段，开发者还可以做以下优化：

- 避免链接无用的 frameworks，在 Xcode 中检查一下项目中的「Linked Frameworks and Librares」部分是否有无用的链接。
- 避免在启动时加载动态库，将项目的 Pods 以静态编译的方式打包，尤其是 Swift 项目，这地方的时间损耗是很大的。
- 硬链接你的依赖项，这里做了缓存优化。

> 也许有人会困惑是不是使用了 dyld3 了，我们就不需要做 Static Link 了，其实还是需要的，感兴趣的可以看一下 [Static linking vs dyld3](https://allegro.tech/2018/05/Static-linking-vs-dyld3.html) 这篇文章，里面有一个详细的数据对比。

libSystem init 部分，主要是加载一些优先级比较低的系统组件，这部分时间是一个固定的成本，所以我们开发人员不需要关心。

#### Static Runtime Initializaiton

这个阶段主要是 Objective-C 和 Swift Runtime 的初始化，会调用所有的 `+load` 方法，将类的信息注册到 runtime 中。

在这个阶段，原则上不建议开发者做任何事情，所以为了避免一些启动时间的损耗，你可以做以下几个事情：

- 在 framework 开发时，公开专有的初始化 API
- 减少在 `+load` 中做的事情
- 使用 `initialize` 进行懒加载初始化工作

#### UIKit Initializaiton

这个阶段主要做了两个事情：

- 实例化 UIApplication 和 UIApplicationDelegate
- 开始事件处理和系统集成

所以这个阶段的优化也比较简单，你需要做两个事情：

- 最大限度的减少 UIApplication 子类初始化时候的工作，更甚至与不子类化 UIApplication
- 减少 UIApplicationDelegate 的初始化工作

#### Application Initializaiton

这个阶段主要是生命周期方法的回调，也正是开发者最熟悉的部分。

调用 UIApplicationDelegate 的 App 生命周期方法：

```Swift
  application:willFinishLaunchingWithOptions: 
  application:didFinishLaunchingWithOptions:
```

和 UIApplicationDelegate 的 UI 生命周期方法：

```Swift
  applicationDidBecomeActive:
```

同时，iOS 13 针对 UISceneDelegate 增加了新的回调：

```Swift
  scene:willConnectToSession:options:
  sceneWillEnterForeground:
  sceneDidBecomeActive:
```

也会在这个阶段调用。感兴趣的可以关注一下 Getting the Most out of Multitasking 这个 Session，暂时没有视频资源，怀疑是现场演示翻车了，所以没有把视频资源放出来。

在这个阶段，开发者可以做的优化：

- 推迟和启动时无关的工作
- Senens 之间共享资源

#### Fisrt Frame Render

这个阶段主要做了创建、布局和绘制视图的工作，并把准备好的第一帧提交给渲染层渲染。会频繁调用以下几个函数：

```
 loadView
 viewDidLoad 
 layoutSubviews
```

在这个阶段，开发者可以做的优化：

- 减少视图层级，懒加载一些不需要的视图
- 优化布局，减少约束
    
> 更多细节可以从 [WWDC2018 - 220 - High Performance Auto Layout](https://developer.apple.com/videos/play/wwdc2018/220/) 中了解
    
#### Extend

大部分 App 都会通过异步的方式获取数据，并最终呈现给用户。我们把这一部分称为 Extend。

因为这一部分每个 App 的表现都不一样，所以苹果建议开发者使用 os_signpost 进行测量然后慢慢分析慢慢优化。

# 测量 App 启动时间

要找到启动过程中的问题，就要进行多次测量并前后比较。但是如果变量没有控制好，就会导致误差。

所以为了保证测量的数据能够真实的反应问题，我们要减少不稳定性因素，保证在可控的相近的环境下进行测量。最后使用一致的结果来分析。

## 条件一致性

为了保证环境一致，我们可以做下面这几个事情:

- 重启手机，并等待 2-3 分钟
- 启用飞行模式或者使用模拟网络
- 不使用或者不变更 iCloud 的账户
- 使用 release 模式进行 build
- 测量热启动时间

iColud 账户切换会影响性能，所以不要切换账号或者不开启 iCloud。

## 测量注意点

- 尽可能的使用具有代表性的数据进行测试

    如果不使用具有代表性的数据进行测试，就会出现偏差

- 使用不同的新旧设备进行测试
- 最后你还可以使用 XCTest 来测试，多运行几次，取平均结果

> 关于使用 XCTest 测试启动时间的信息，可以看一下 [WWDC2019 - 417 - Improving Battery Life and Performance](https://developer.apple.com/videos/play/wwdc2019/417/)，但是我测试了一下，目前好像还有一部分 API 还没有开放出来，暂时还不能使用。


# 使用 Instruments 分析和优化 App 启动过程

## 优化方式

苹果给了我们三个优化方式的建议，整体思想和前面提到的各个阶段的优化差不多

#### Minimize Work

- 推迟与第一帧无关的工作
- 从主线程移开阻塞工作
- 减少内存使用量

#### Prioritize Work

- 定义好任务的优先级。
- 利用好 GCD 来优化你的启动速度。
- 然重要的事情保持优先

> 更深入的了解有关 GCD 的内容，可以看一下 [WWDC2017 - 706 - Modernizing Grand Central Dispatch Usage](https://developer.apple.com/videos/play/wwdc2017/706/)

#### Optimize Work

- 简化现有工作，比如只请求必要的数据。
- 优化算法和数据结构
- 缓存资源和计算

## 使用 Instruments 分析 App 启动过程

当知道如何优化之后，我们需要针对我们的启动过程进行分析。Xcode 11 的 Instruments 为此新增了一个 App launch 模板，让开发者可以更好的分析自己 App 的启动速度。

![](https://images.xiaozhuanlan.com/photo/2019/9587ff7e3dfecdaa50568a497f5e710b.png)

运行后可以看到个接各个阶段的具体时间，根据数据进行优化，还能看到耗时的函数调用。

![](https://images.xiaozhuanlan.com/photo/2019/4f1b5b3f9fe7989441d52ea76619a049.png)

# 系统优化

今年苹果做了很多优化，下面这几个高亮的是和启动速度有关的优化

![](https://images.xiaozhuanlan.com/photo/2019/90ee8adbaffb847377f47ba4f720ec42.png)

但是不知道是不是时间原因，在 session 中对于这部分的解释特别少，很难理解 200% 到底做了什么。

但是 Craig Federighi 在 [The Talk Show Live From WWDC 2019, With Craig Federighi and Greg Joswiak](https://daringfireball.net/2019/06/the_talk_show_live_from_wwdc_2019) 中针对为什么优化了 200% 说了这样一段话：

> Isn’t that crazy that was quite a discovery for us. No it turns out that over times as in terms of the way the apps were encrypted and the way fair play worked and so forth. The encryption became part of the critical path actually of launching the apps. I mean the processors are capable or up and through the thing that actually it was a problem. And then there are other optimizations that based on what was visible to system at certain things. And so it actually cut out optimization opportunities and so when we really identified that opportunity we said okay. We can actually come up with better format that’s gonna eliminate that being on the critical path, It’s going to enable all these pre-binding things. And then we did a whole bunch of other work to optimize the objective-c runtime to optimize the linker the dynamic linker a bunch of other things and you put it all together. And yeah that I mean a cold launch this is we’ve never had a win like this to launch time in a single release.

从这段话中，除了 dyld3 的功劳之外，对代码签名的优化应该也是一个。

# 监控线上用户 App 的启动

Xcode 11 在 Xcode Organizer 新增了一个监控面板，在这个面板里面可以查看多个维度的用户数据，其中还包括平均启动时间。

![](https://images.xiaozhuanlan.com/photo/2019/95a22db394a8338ecf31765a083d055e.png)

以当你通过 Instruments 分析完你的启动过程，并做了大量优化之后，你就可以通过 Xcode Organizer 来分析你这次优化效果到底怎么样。

> 当然你可以通过今年新出的 [MetricKit](https://developer.apple.com/documentation/metrickit) 获取一些自定义的数据，具体参照 [WWDC2019 - 417 -Improving Battery Life and Performance](https://developer.apple.com/videos/play/wwdc2019/417/)


# 总结

今年苹果提的很多优化建议其实在早几年都已经说过一遍了，属于老生常谈了。但是值得点赞的是新出的 Instruments 的 App launch 和 Xcode Organizer 的性能监控。

启动优化是一个需要经常反复做的事情，越早发现问题，越容易解决问题，如果你想给你的用户一个良好的第一印象，就赶快行动起来吧。