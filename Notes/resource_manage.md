# iOS 开发中的资源管理问题

## 前言

在 iOS 开发中，资源文件管理是必不可少的一件事情。今天我和大家聊一聊下面这几个问题。

- 如何更高效的同步素材图?
- 如何更安全的读取素材图?
- 如何解决组件之间的重名问题？

---

## 更高效的同步素材图

说起 **更高效**，前不久特地找了几个朋友问了一下他们项目中同步素材图的方式，我大致列举一下:

- 乞丐版 
![](https://images.xiaozhuanlan.com/photo/2018/bd53ba220790ced6dd8f0d10a8a7f979.jpg)

- 入门版 
![](https://images.xiaozhuanlan.com/photo/2018/27c06e1da27bd325af7a4f2fb29531cd.jpg)

- 升级版 
![](https://images.xiaozhuanlan.com/photo/2018/e7a86e26f55d1894f45dba6be99f1427.jpg)

- 极客版 
![](https://images.xiaozhuanlan.com/photo/2018/22a3f6873041a790c762a6b1af94290d.jpg)

总结了那么多，我只想说一句话，那就是... 

![(图片与本文无关)](https://images.xiaozhuanlan.com/photo/2018/44657ca8b20e8d47a3cb41c78d7ce8bb.jpg)

...我们可以借助**脚本**去优化上面的工作流，从而达到更高效。大致流程如下

![](https://images.xiaozhuanlan.com/photo/2018/211852de0f59a2e31d59cc9f7327b747.png)

实际上工作原理很简单，就是借助了 **Xcode** 的 **Build Phases** 的功能，编写一个将图片从一个同步盘同步到项目中的 **Asset Catalog** 的脚本，在编译的时候 **增量** 同步，就可以很方便的管理图片文件了。

我用 Swift 实现了这个脚本，放在了 [GitHub - AutoAsset](https://github.com/Damonvvong/AutoAsset) 上，感兴趣的可以下载源码了解一下，当然你也可以直接使用到你的项目中，然后再也不用操心同步图片的事情啦。上面有使用方法和示例Demo，所以脚本的使用细节我就不展开讲了。

可能有人会担心这样的方式会减慢编译速度，但是我通过缓存上次同步成功的图片，再借助 diff 找出不一样的文件而去进行增量同步。就不会存在什么减慢编译速度了。

> 说了那么多，搞的好像不加这个你编译 Swift 会很快一样。😂

---

## 更安全的读取素材图

项目中读取一张图片大致有两种类型:

- 通过 **字符串** 读取

```Swift
let image = UIImage(named: "damonwong"）
```
对于这种方式而言，当图片删除时，可能会因为沟通不及时 **导致图片读取失败** 而没有发现，相对来说并不是一个 **十分安全** 的方式。

- 通过 **字面量** 读取

```Swift
let image = #imageLiteral(resourceName: "damonwong")
```
虽然通过字面量读取，在 Xcode 里面可以直接看到图片特别的形象，但是一旦图片删除，你又没有及时修改而上线了，**直接会导致奔溃** 🙃, 所以是一种 **极度不安全** 的方式。

**那么，如何才能更安全的读取一张素材图呢？**

> 用 **Strongly typed identifiers**

首先，先说一下什么是 **Strongly typed identifiers**。
- 对于一个字符串而言，你可以是任何字符比如 `damonwong` 或者 `damonvvong`, 编译器并不会帮你去检查这个字符串有没有什么问题。但是我们可以利用 **enum** 或者 **struct** 对字符串进行一次包装，强行让编译器去检查一下字符串有没有什么问题。比如：

```Swift
enum StronglyString: String {
    case damonwong
    case damonvvong
}

print(StronglyString.damonwong.rawValue)
print(StronglyString.damonvvong.rawValue)
```
这就是 **strongly typed identifiers**。

同时，对于 **图片名** 而言，是一个很好的 **Strongly typed identifiers** 应用例子。将所有的图片名都以 **enum** 的方式去包装，不但能检查图片重名问题，还能及时发现被删除的图片名到底用在哪些地方。

所以要怎么去做呢？照着 Asset Catalog 目录一个一个去码？No，你错了。像这种事情，还是可以用脚本搞定。

![](https://images.xiaozhuanlan.com/photo/2018/fddd84405b64ddbb2a9e5f1b1a439253.jpg)

在 github 上有两个比较好用的库 [R.Swift](https://github.com/mac-cain13/R.swift) 和 [SwiftGen](https://github.com/SwiftGen/SwiftGen)，都很好的解决了从 **字符串** 到 **Strongly typed identifiers** 的自动工作。

两个库我都尝试了一下，大体功能都差不多，非要说一点不同的话。

- **SwiftGen** 相对来说依赖少一点，可配置空间更大，适合老项目引入并资源局部管理。
- **R.Swift** 配置简单且管理全面，适合新项目引入并资源全局管理。

最终的使用效果如下：

```Swift
// SwiftGen
let image = Asset.damonwong.image
// R.Swift
let icon = R.image.damonwong()
```

下面简单的描述一下如何使用 **SwiftGen**

- 首先，你要根据 [README.md](https://github.com/SwiftGen/SwiftGen#installation) 安装 **SwiftGen** 它可以用 CocoaPods 集成也可以直接安装命令行工具。
- 在安装好之后，在 **Xcode** 的 **Build Phases** 新增一个脚本。这里要注意的是脚本执行是有顺序的，先要执行上面的图片同步脚本 **SwiftGen**，再执行 **SwiftGen**。而且这两步是需要在编译之前执行的。
- 如果有定制化要求的朋友，也可以自己去修改 **SwiftGen** 的模板文件。 

结合 **更高效的同步素材图** 和 **更安全的读取素材图**，我们现在的流程就变成了:
> 1. 同步图片到 **Asset Catalog** 
> 2. **SwiftGen/R.Swift** 生成 **Strongly typed identifiers** 文件 
> 3. 编译器编译检验 - 如有问题抛出异常。

整个流程就相对更加高效和安全了。我也写了一个[示例 Demo - ResourceManageDemo](https://github.com/Damonvvong/DevNotes/tree/master/Demo/ResourceManageDemo)

---

## 组件之间的重名问题

最近项目在做组件化，遇到一个问题「如何解决组件之间的重名问题」。和小伙伴讨论了一下，大致有下面几种的解决方案：

- 1. 不用管，反正现在还有没重名文件
- 2. 将一个项目的所有文件都到放到一起，及时发现重名文件并修改
- 3. 通过命名前缀比如 `PodA_icon_image` 方式去约束
- 4. 组件之间单独管理资源文件

**方案 1** 是上来凑数的，肯定是不考虑的。
**方案 2** 是一个相对不错的解决方案，但是维护起来是相对于**一个项目而不是一个组件**，也就是说如果有一个新项目，那你需要知道这个项目所依赖的组件都需要哪些素材图。
**方案 3** 就是一个部门之间的协同与规范问题了，出于 **求人补不如求己** 的原则，最后也放弃了。
**方案 4** 就是我们最后的选择

> 现在回过头来想想是真的"后悔"啊，坑太多了，还好 `@mmoaay` 及时提醒让一个即将上线的bug最后没有上线。
> **所以决定把踩过的坑都记一遍**


### Podspec 中的 resource_bundles & resources 的区别

这是我遇到的第一个坑，在年初的时候看到 [给 Pod 添加资源文件](http://blog.xianqu.org/2015/08/pod-resources/) 这篇文章中的这样一段话：

> 利用 **resources** 属性可以指定 Pod 要使用的资源文件。这些资源文件在 build 时会被直接拷贝到 client target 的 **mainBundle** 里。

当时误以为，只要是 **resources** 属性都会把 Pod 中的资源文件拷贝到 **mainBundle** 中。

但是，上面的话一点都不严谨。对于在 **podfile** 中使用了 `use_frameworks!` 也就是动态框架的方式集成 Pod ，并不会把 Pod 中的资源文件拷贝到 **mainBundle** 中。

所以在这里给那些被我误导的各位说一声抱歉。
![](https://images.xiaozhuanlan.com/photo/2018/2375aea2f08c5e241e43a03da923b82c.jpg)

**所以 resource_bundles 和 resources 到底有什么区别呢？**

```ruby
spec.resource_bundles = {
    'PodName' => ['PodName/Resources/*.png'],
    'OtherResources' => ['PodName/OtherResources/*.png']
}

spec.resources = ['Images/*.png', 'Sounds/*']
```

对于 **resource_bundles** 来说，在打包之后，会自动根据 **key** 而生成对应的一个 **key.bundle** 方式放到 **Pod** 二进制文件所处的位置。
    
- **key** 比如上面的 `PodName` 和 `OtherResources` 会生成 `PodName.bundle` 和 `OtherResources.bundle`
- 这里建议将 **PodName** 作为 **key** 便于后续的开发工作。

而对于 **resources** 来说，则是直接将资源文件放到 **Pod** 二进制文件所处的位置。

所以，**本质区别在于有没有将资源文件通过 .bundle 来包装。**

最后我在 **CocoaPod 1.4.0** (避免为后者留坑，就说明一下版本号) 下的实践结果如下:

|  | resource_bundles | resources |
| --- | --- | --- |
| static_framework | 资源在 PodName.bundle 里, PodName.bundle 在 MainBundle | 资源在 MainBundle |
| use_frameworks | 资源在 PodName.bundle 里, PodName.bundle 在 PodName.framework 目录里 | 资源在PodName.framework 目录里|


- 上文的 **static_framework** 指的是通过静态链接方式编译，比如 **OC** 不使用 **use_frameworks** 的项目 或者 **Swift** 使用了 **static_framework = true** 的属性的 **Pod**。在 **CocoaPods 1.5.0** 之后 **Swift** 项目也支持不使用 **use_frameworks** 的静态链接方式编译了。

从上面的表中可以看到，对于 **resources** 的方式，还是会有可能被打包到主项目中，导致文件名重名的问题。
所以，解决重名问题还是应该选择 **resource_bundles**

同时，[CocoaPods 官方](https://guides.cocoapods.org/syntax/podspec.html#resource_bundles) 也更推荐使用 **resource_bundles**

> We strongly recommend library developers to adopt resource bundles as there can be name collisions using the resources attribute. Moreover, resources specified with this attribute are copied directly to the client target and therefore they are not optimised by Xcode.

如果看完还是有点云里雾里的，我建议你可以自己去实践一下。
当然，其实你只要记住一句话就行了:「用 **resource_bundles** 比 **resources** 更好」

### 越狱机上的神器 bug

在美滋滋的适配完 **framework + resource_bundles** 的方式之后的第二天。`@mmoaay` 突然在微博上告诉我 **framework + resource_bundles** 这个方式在越狱机上会闪退。(其实确切的是访问不到 **PodName.bundle** 里面的资源文件)

我就拿了一个测试机做了一下实际验证，果然有问题。实际验证结果如下：

|  | 图片放在 Asset Catalog | 图片直接拖进项目 |
| --- | --- | --- |
| framework + resource_bundles | 越狱机无法通过任何方式访问到图片 | 可以访问到图片 |
| Static_framework + resource_bundles | 可以访问到图片 | 可以访问到图片 |


- 注: 以上方案，在非越狱机上都可以正常访问到图片

所以，我的 **framework + resource_bundles + Asset Catalog** 方案就华丽的扑街了... 倒在一个迷之 **bug** 中...

[Demo 地址 - OnlyCrashOnJailbreakDemo](https://github.com/Damonvvong/DevNotes/tree/master/Demo/OnlyCrashOnJailbreakDemo) 在这里你可以拿到这个验证 Demo

虽然越狱机上的问题出在 **Asset Catalog**。但是，**Xcode** 对 **Asset Catalog** 在编译时会做压缩等优化处理，打包完成之后，[App Slicing](https://developer.apple.com/library/content/documentation/FileManagement/Conceptual/On_Demand_Resources_Guide/index.html#//apple_ref/doc/uid/TP40015083) 还会将 **Assets.car** 根据不同的安装包进行切割。所以，还是需要使用 **Asset Catalog**。最终的结局方案也变成了 **static_framework + resource_bundles + Asset Catalog**

### resource_bundles 上的资源访问方式

前两天和知识小集的 @Vong 稍微聊过这个问题,他最后也通过 [文章](https://mp.weixin.qq.com/s/26iiNvJgWL-KeMxqfw7LHQ) 大致描述了这个问题，写的比较详细，但是有一个小问题，描述的不够严谨。

> 而 **resource_bundle** 对应的读取代码如下面所示：

```
NSBundle *bundle = [NSBundle bundleForClass:[self class]];
NSURL *url = [bundle URLForResource:@"your-bundle-name" withExtension:@"bundle"];
NSBundle *targetBundle = [NSBundle bundleWithURL:url];
UIImage *image = [UIImage imageNamed:@"your-image-name"
                            inBundle:targetBundle
                            compatibleWithTraitCollection:nil];
```

实际上，对于 **UIImage** 而言。选择 **resource_bundle** 时通过下面这种方式也取到图片。

```
UIImage *image = [UIImage imageNamed:@"your-image-name"
                            inBundle:[NSBundle bundleForClass:[self class]]
                            compatibleWithTraitCollection:nil];
```

我觉得应该是 `imageNamed:inBundle:compatibleWithTraitCollection:` 去找图片的时候会去遍历当前 Bundle, 所以不需要定位到 **PodName.bundle**

而对于 **xib** 等而言，则必须定位到 **PodName.bundle** 才能把 xib 给取出来。查找方法如下：

```Swift
    // 取出 PodName.bundle 对于的 Bundle
    public static func bundle(of classType: AnyClass) -> Bundle {
        let classBundle = Bundle(for: classType)
        let resourceBundleName = String((NSStringFromClass(classType) as String).split(separator: ".").first ?? "")
        let resourceBundleURL = classBundle.url(forResource: resourceBundleName, withExtension: "bundle")
        guard let url = resourceBundleURL,
            let bundle = Bundle(url: url) else {
            return classBundle
        }
        return bundle
    }
```

## 总结

- 如何更高效的同步素材图?

> 我们可以借助 [GitHub - AutoAsset](https://github.com/Damonvvong/AutoAsset) 去同步图片

- 如何更安全的读取素材图?

> 可以借助 [R.Swift](https://github.com/mac-cain13/R.swift) 或者 [SwiftGen](https://github.com/SwiftGen/SwiftGen) 去使用 **Strongly typed identifiers** 

- 如何解决组件之间的重名问题？

> **Podfile** 里面用 **resource_bundles**，并且需要静态链接方式编译到到项目中

当然，这一定不是最好的方案，今天算是抛砖迎玉，如果你有更好的方案，欢迎找我沟通交流。当然你对文中的内容有什么疑问也可以在微博上找我沟通。[@Damonwong](https://weibo.com/damonone)
