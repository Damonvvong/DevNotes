# iOS 开发中的『库』(一)

> 看文章之前，你可以看下下面几个问题，如果你都会了，可以选择不看。

- .framework 是什么？怎么制作？
- 谈一谈自己对动态库和静态库的理解。
- 在项目中如何使用动态framework的 APP ？使用了动态framework 的 APP 能上架 Appstore 么？
- 可以通过 framework 的方式实现 app 的热修复么？

--- 

## 我是前言

- 最近发现很多人分不清 『.framework && .a 』、『动态库 && 静态库』、『.tbd && .dylib』这几个东西。甚至, 还有人一直以误为 framework 就是动态库！！鉴于网上许多文章都表述的含糊不清，再加上很多文章都比较老了，所以今天写点东西总结一下。

- 首先，看文章之前，你稍微了解这么几个东西：编译过程、内存分区。下面开始！

--- 

## 理论篇
### 动态库 VS. 静态库

> Static frameworks are linked at compile time. Dynamic frameworks are linked at runtime

- 首先你得搞清楚，这两个东西都是编译好的**二进制文件**。就是用法不同而已。**为什么要分为动态和静态两种库呢？**先看下图：

![静态库](media/14750532302037/14750560968857.jpg)

![动态库](media/14750532302037/14750561045406.jpg)

- 我们可以很清楚的看到：
    - 对于**静态库**而言，在编译链接的时候，会将**静态库**的**所有文件**都添加到 **目标 app 可执行文件**中,并在程序运行之后，**静态库**与 **app 可执行文件** 一起被加载到同一块代码区中。
        - **app 可执行文件**: 这个目标 app 可执行文件就是 ipa解压缩后，再显示的包内容里面与app同名的文件。
    - 对于**动态库**而言，在编译链接的时候，只会将**动态库**被引用的**头文件**添加到目标** app 可执行文件**，区别于**静态库**，**动态库** 是在程序运行的时候被添加另外一块内存区域。

 - 下面看下苹果的官方文档中有两句对**动态库**和**静态库**的解释。
        - A better approach is for an app to load code into its address space when it’s actually needed, either at launch time or at runtime. The type of library that provides this flexibility is called dynamic library. 

        - **动态库**:可以在 **运行 or 启动** 的时候加载到内存中，加载到一块**独立的于 app ** 的内存地址中

        - When an app is launched, the app’s code—which includes the code of the static libraries it was linked with—is loaded into the app’s address space.Applications with large executables suffer from slow launch times and large memory footprints

        - **静态库**：当程序在启动的时候，会将 app 的代码(包括静态库的代码）一起在加载到 app 所处的内存地址上。相比于**静态库** 的方案，使用**静态库**将花费更多的启动时间和内存消耗。还会增加可执行文件的大小。

- 举个🌰：假设 UIKit 编译成静态库和动态库的大小都看成 1M , 加载到内存中花销 1s . 现在又 app1 和 app2 两个 app。倘若使用静态库的方式，那么在 app1 启动的时候, 需要花销 2s 同时内存有 2M 分配给了 app1.同样的道理 加上 app2 的启动时间和内存消耗，采用静态库的方案，一共需要花销 **4s 启动时间**、**4M 内存大小**、**4M 安装包大小**。那么换成动态库的时候，对于启动和 app1 可能花费一样的时间，但是在启动 app2 的时候 不用再加载 **UIKit 动态库** 了。减少了 UIKit 的重复 使用问题，一共花销 **3s启动时间**、**3M 内存大小**、**4M 安装包大小**。
- 而很多 app 都会使用很多相同的库，如 **UIKit **、 **CFNetwork** 等。所以，苹果为了加快 app 启动速度、减少内存小孩、减少安装包体积大小，采用了大量 动态库的形式 来优化系统。**dyld 的共享缓存** ：在 OS X 和 iOS 上的动态链接器使用了共享缓存，共享缓存存于 /var/db/dyld/。对于每一种架构，操作系统都有一个单独的文件，文件中包含了绝大多数的动态库，这些库都已经链接为一个文件，并且已经处理好了它们之间的符号关系。当加载一个 Mach-O 文件 (一个可执行文件或者一个库) 时，动态链接器首先会检查 共享缓存 看看是否存在其中，如果存在，那么就直接从共享缓存中拿出来使用。每一个进程都把这个共享缓存映射到了自己的地址空间中。这个方法大大优化了 OS X 和 iOS 上程序的启动时间。

- 两者都是由*.o目标文件链接而成。都是二进制文件，闭源。

### .framework VS .a

- .a是一个纯二进制文件，不能直接拿来使用，需要配合头文件、资源文件一起使用。在 iOS 中是作为静态库的文件名后缀。

- .framework中除了有二进制文件之外还有资源文件，可以拿来直接使用。

- 在不能开发动态库的时候，其实 『**.framework =  .a + .h + bundle』**。而当 Xcode 6 出来以后，我们可以开发动态库后**『.framework =  静态库/动态库 + .h + bundle』**

### .tbd VS .dylib

- 对于静态库的后缀名是**.a**，那么动态库的后缀名是什么呢？
- 可以从 libsqlite3.dylib 这里我们可以知道 .dylib 就是动态库的文件的后缀名。

- 那么 **.tbd** 又是什么东西呢？其实，细心的朋友都早已发现了从 Xcode7 我们再导入系统提供的动态库的时候，不再有**.dylib**了，取而代之的是**.tbd**。而 **.tbd** 其实是一个YAML本文文件，描述了需要链接的动态库的信息。主要目的是为了减少app 的下载大小。[具体细节可以看这里](http://stackoverflow.com/questions/31450690/why-xcode-7-shows-tbd-instead-of-dylib)

### 小总结

- 首先，相比较与静态库和动态库，动态库在包体积、启动时间还有内存占比上都是很有优势的。
- 为了解决 .a 的文件不能直接用，还要配备 .h 和资源文件，苹果推出了一个叫做 .framework 的东西，而且还支持动态库。

### Embedded VS. Linked 

> Embedded frameworks are placed within an app’s sandbox and are only available to that app. System frameworks are stored at the system-level and are available to all apps. 

- OK，前面说了那么多，那么如果我们自己开发了一个动态framework 怎么把它复制到 **dyld 的共享缓存** 里面呢？
- 一般来说，用正常的方式是不能滴，苹果也不允许你这么做。（当然不排除一些搞逆向的大神通过一些 hack 手段达到目的）
- 那么，我们应该如何开发并使用我们自己开发的 动态framework 呢？
- 那就是 Embedded Binaries。

- Embedded 的意思是嵌入，但是这个嵌入并不是嵌入 app 可执行文件，而是嵌入 app 的 bundle 文件。当一个 app 通过 Embedded 的方式嵌入一个 app 后，在打包之后解压 ipa 可以在包内看到一个 framework 的文件夹，下面都是与这个应用相关的动态framework。在 Xcode 可以在这里设置,图中红色部分：

![](media/14750532302037/14751257675011.jpg)

- 那么问题又来了，下面的 **linded feameworks and libraries** 又是什么呢？
- 首先在 **linded feameworks and libraries** 这个下面我们可以连接系统的动态库、自己开发的静态库、自己开发的动态库。对于这里的静态库而言，会在**编译链接**阶段连接到**app可执行文件**中，而对这里的动态库而言，虽然不会链接到**app可执行文件**中，~~但是会在启动的时候就去加载这里设置的所有动态库~~。(ps.理论上应该是这样，但是在我实际测试中似乎加载不加载都和这个没关系。可能我的姿势不对。😂)
- 如果你不想在启动的时候加载动态库，可以在 **linded feameworks and libraries**  删除，并使用dlopen加载动态库。（dlopen 不是私有 api。）

```
- (void)dlopenLoad{
    NSString *documentsPath = [NSString stringWithFormat:@"%@/Documents/Dylib.framework/Dylib",NSHomeDirectory()];
    [self dlopenLoadDylibWithPath:documentsPath];
}

- (void)dlopenLoadDylibWithPath:(NSString *)path
{
    libHandle = NULL;
    libHandle = dlopen([path cStringUsingEncoding:NSUTF8StringEncoding], RTLD_NOW);
    if (libHandle == NULL) {
        char *error = dlerror();
        NSLog(@"dlopen error: %s", error);
    } else {
        NSLog(@"dlopen load framework success.");
    }
}
```

### 关于制作过程

- 关于如何制作，大家可以看下raywenderlich家的经典教程[《How to Create a Framework for iOS 》](https://www.raywenderlich.com/65964/create-a-framework-for-ios)，中文可以看这里[《创建你自己的Framework》](http://blog.csdn.net/u013604612/article/details/43197465)

- 阅读完这篇教程，我补充几点。
    - 首先，framework 分为Thin and Fat Frameworks。Thin 的意思就是瘦，指的是单个架构。而 Fat 是胖，指的是多个架构。
    - 要开发一个真机和模拟器都可以调试的 Frameworks 需要对Frameworks进行合并。合并命令是 `lipo`[lipo]()。
    - 如果 app 要上架 appstore 在提交审核之前需要把 Frameworks 中模拟器的架构给去除掉。
    - 个人理解，项目组件化或者做 SDK 的时候，最好以 framework 的形式来做。

---

## 实践篇
### framework 的方式实现 app 的热修复

- 由于 Apple 不希望开发者绕过 App Store 来更新 app，因此只有对于不需要上架的应用，才能以 framework 的方式实现 app 的更新。
- 但是理论上只要保持签名一致，在 dlopen 没有被禁止的情况下应该是行的通的。(因为没有去实践，只能这样 YY 了。)
- 但是不论是哪种方式都得保证 服务器上的 framework 与 app 的签名要保持一致。

#### 实现大致思路

- 下载新版的 framework
- 先到 document 下寻找 framework。然后根据条件加载 bundle or document 里的 framework。

```Objective - C
	NSString *fileName = @"remote";
	
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = nil;
	if ([paths count] != 0) {
		documentDirectory = [paths objectAtIndex:0];
	}

	NSFileManager *manager = [NSFileManager defaultManager];
	NSString *bundlePath = [[NSBundle mainBundle]
										 pathForResource:fileName ofType:@"framework"];
	
	BOOL loadDocument = YES;
	
	// Check if new bundle exists
	if (![manager fileExistsAtPath:bundlePath] && loadDocument) {
		bundlePath = [documentDirectory stringByAppendingPathComponent:[fileName stringByAppendingString:@".framework"]];
	}
```
- 再加载 framework

```Objective - C
	// Load bundle
	NSError *error = nil;
	NSBundle *frameworkBundle = [NSBundle bundleWithPath:bundlePath];
	
	if (frameworkBundle && [frameworkBundle loadAndReturnError:&error]) {
		NSLog(@"Load framework successfully");
	}else {
		NSLog(@"Failed to load framework with err: %@",error);
		
	}
```
- 加载类并做事情

```
	// Load class
	Class PublicAPIClass = NSClassFromString(@"PublicAPI");
	if (!PublicAPIClass) {
		NSLog(@"Unable to load class");
		
	}
	
	NSObject *publicAPIObject = [PublicAPIClass new];
	[publicAPIObject performSelector:@selector(mainViewController)];
```

---

## 番外篇
### 关于lipo

```
$ lipo -info /Debug-iphoneos/Someframework.framwork/Someframework
# Architectures in the fat file: Someframework are: armv7 armv7s arm64 
```

```
# 合并
$ lipo –create a.framework b.framework –output output.framework
```

```
#拆分
$ lipo –create a.framework -thin armv7 -output a-output-armv7.framework
```

### 从源代码到app

> 当我们点击了 build 之后，做了什么事情呢？
 
- 预处理（Pre-process）：把宏替换，删除注释，展开头文件，产生 .i 文件。
- 编译（Compliling）：把之前的 .i 文件转换成汇编语言，产生 .s文件。
- 汇编（Asembly）：把汇编语言文件转换为机器码文件，产生 .o 文件。
- 链接（Link）：对.o文件中的对于其他的库的引用的地方进行引用，生成最后的可执行文件（同时也包括多个 .o 文件进行 link）。

### ld && libtool

- ld :用于产生可执行文件。
- libtool：产生 lib 的工具。

### Build phases &&  Build rules && Build settings

- **Build phases**: 主要是用来控制从源文件到可执行文件的整个过程的，所以应该说是面向源文件的，包括编译哪些文件，以及在编译过程中执行一些自定义的脚本什么的。
- **Build rules**: 主要是用来控制如何编译某种类型的源文件的，假如说相对某种类型的原文件进行特定的编译，那么就应该在这里进行编辑了。同时这里也会大量的运用一些 xcode 中的环境变量，完整的官方文档在这里：Build Settings Reference
- **Build settings**:则是对编译工作的细节进行设定，在这个窗口里可以看见大量的设置选项，从编译到打包再到代码签名都有，这里要注意 settings 的 section 分类，同时一般通过右侧的 inspector 就可以很好的理解选项的意义了。

---

### 谈谈 Mach-O
![](media/14750532302037/14751382596341.jpg)
- 在制作 framework 的时候需要选择这个 Mach-O Type.
- 为Mach Object文件格式的缩写，它是一种用于可执行文件，目标代码，动态库，内核转储的文件格式。作为a.out格式的替代，Mach-O提供了更强的扩展性，并提升了符号表中信息的访问速度。

---

### 参考资料

[苹果官方文档](https://developer.apple.com/library/content/documentation/DeveloperTools/Conceptual/DynamicLibraries/100-Articles/DynamicLibraryDesignGuidelines.html#//apple_ref/doc/uid/TP40002013-SW19)
[添加动态库的 app 提交 AppStore](https://forums.developer.apple.com/thread/21496)
[framework 动态更新](http://nixwang.com/2015/11/09/ios-dynamic-update/)

