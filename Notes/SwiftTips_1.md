# Swift 3 迁移工作总结

# 写在前面

- Swift 3.0 正式版发布了差不多快一个月了，断断续续的把手上和 Swift 相关的迁移到了Swift 3.0。所以写点小总结。

## 背景
#### 代码量（4万行）

- 首先，我是今年年初才开始入手 Swift 的。加上 Swift 的 ABI 和 API 一直不稳定，所以没有在项目中大范围的使用，所以这次迁移的代码量不多，大概在**4万行**左右。


#### 迁移时间（一天左右）

- 迁移时间上的话，大概是花了1天左右。两个**混编**项目，一个 **Swift 为主**的项目。期中 **Swift 为主**的项目 花了大概**大半天**时间，两个**混编**代码量差不多，但是一个花了**小半天**，还有一个差不多只花了**半个小时**(原因先留个悬念~)。

## 准备

> 在开发最初开发选择 Swift 的时候的很多决策也让我这次少了很多工作量。

#### 界面用 xib 而不用纯代码

- 阴差阳错的，和 Swift 相关的大部分界面都是用xib 画的。而这个 xib 在这次迁移中得到了很大的优势，xib 和 SB 的代码不适配 Swift 3。想当初要是使用代码写的 UI 的话，这次迁移改动估计会多很多吧。

#### 关于第三方库的选择：

- 对于一个项目来说，三方库似乎成了一道**必选菜**，但是如何去选择这道菜呢？
- 对于三方库，当初的选择是，**能用 OC 就尽量用 OC**。 毕竟可以OC 可以无缝衔接到 Swift，而且还相对稳定。
- 在选择 **Swift** 相关的三方库时，我尽量值选择使用者比较多的库，例如**Alamofire**、**Snap**、**Kingfisher**、**Fabric** 等，因为使用者比较多，开发者会更愿意去维护，而不至于跳票。所以不会存在现在许多小伙伴面临的问题，想迁移，但是有些库没有更新。至少对于我来说，当我想迁移的时候，所有和 Swift 相关的三方库都已经迁移到了 3.0 了。

>  得益于上面两点，在迁移过程中少了不少工作量。🙈

#### 知识储备升级

- 先了解了一下Swift 2 到 Swift 3 的变动，及变动的原因。（看完心中一万头草泥马飞过，但是其实是越来越好了）
    - [Swift官博](https://swift.org/)
    - [swift-evolution](https://github.com/apple/swift-evolution/blob/master/releases/swift-3_0.md)
    - [Swift 3 新特性一览](https://realm.io/cn/news/appbuilders-daniel-steinberg-whats-new-swift-3/)
- 然后把语法文档快速的重温了一遍。
    - [Swift Programming Language](https://developer.apple.com/swift/)
    - [中文版](http://wiki.jikexueyuan.com/project/swift/)

## 迁移中的问题

#### Any && AnyObject

- 我想在做迁移和做完迁移的同学改的最多的一个就是  ` as AnyObjct?` 吧?
- 至少对于我来说是的。
- 和这个相关的基本是**集合类型**。在 Swift 2 中我们一个用 **[AnyObject]** 来存放任何变量，甚至于存放struct类型的 `String`、`Array` 等。但是按道理 Swift 的 **AnyObject** 指的是类，而 **Any** 才是包括`struct`、`class`、`func` 等所有类型。但是为何 **Struct** 可以放入 **[AnyObject]** 呢？在  **Swift 2** 的时候会针对**String**、**Int** 等 **Struct** 进行一个 Implicit Bridging Conversions。而到了 **Swift 3** 则进行了一个[**Fully eliminate implicit bridging conversions from Swift](https://github.com/apple/swift-evolution/blob/master/proposals/0072-eliminate-implicit-bridging-conversions.md)**改动。
- 当然在我的项目中**[AnyObject]**其实是小事，最麻烦的就是 [String:AnyObject]。因为当初写项目的时候，还是处于 **OC To Swift** 的阶段所以对于 Dictionary ，基本采用了 [String:AnyObject], 所以在修改的时候，在很多地方为了这个修改。
    - 起初，我是照着 Xcode 的提示，在 Dictionary 后面的 value 后面加了一个 `as AnyObjct？`
    - 后来渐渐的发现我做了一件很傻比的事情，其实我只要把 [String:AnyObject] 改为 [String:Any] 就可以了。😂
- 这也就是为什么在第一混编的项目中我花了那么多时间去修改代码了！得益于混编的第二个项目学习了 Yep 的思路，是把 `[String:AnyObject]` 命名为一个叫做 `JSONDictionary` 的类型。所以在 **Any && AnyObect** 这个事情上，就花了一点点时间。

```Swift

// Swift 2
 var json = [String:AnyObect]()
json["key1"] = 1 
json["key2"] = "2" 

// to Swift 3 Step 1
 var json = [String:AnyObect]()
json["key1"] = 1 as AnyObject?
json["key2"] = "2" as AnyObject?
            
// to Swift 3 Step 2
 var json = [String:Any]()
json["key1"] = 1 
json["key2"] = "2"

// Swift 2 
public typealias JSONDictionary = [String: AnyObject]
// To Swift 3 Step 2
public typealias JSONDictionary = [String: Any]

```

#### Alamofire 等三方库支持 iOS8

- 虽然说我使用的三方库都在第一时间将库升级到了 **Swift 3** ，但是期中 **Alamofire** 和 **Snap** 两个库最低适配只支持到了 iOS 9，为了避免和产品撕逼，不得不想办法解决这个适配问题。下面以 **Alamofire**  为例
- 其实三方库么，不一定只用 Cocoapods 的。所以打算下载代码然后直接撸源码。
- 先**Alamofire**的 Xcode 修改为最低适配 8.0，然后编译查找不通过的函数，并删除。（其实这些函数都是 iOS 9 新加的函数，所以删除不影响什么。）
- 大概花了 半个小时左右就可以删完了，然后直接拖到项目中就可以了~
- **Snap** 其实只要拖进去就好了，暂时不需要修改什么。

```Swift

// 其实都是 !os(watchOS) 这个宏下面的
#if !os(watchOS)

@discardableResult
public func stream(withHostName hostName: String, port: Int) -> StreamRequest {
    return SessionManager.default.stream(withHostName: hostName, port: port)
}

@discardableResult
public func stream(with netService: NetService) -> StreamRequest {
    return SessionManager.default.stream(with: netService)
}

#endif
```

#### @escaping 

- 这个是我在适配中最蛋疼的坑
- 首先在看[swift-evolution](https://github.com/apple/swift-evolution/blob/master/releases/swift-3_0.md)只是了解到**@escaping** 必须显示声明。但是不知道**@escaping**的闭包，在函数体内无法再修改。

```Swift

	let pedonmeter:CMPedometer = CMPedometer()
	
	func getPedometerDataFromDate(_ datet:Date?, withHandler handler: @escaping (CMPedometerData?, Error?) -> ()){
		
		
		// 编译错误
		pedonmeter.queryPedometerDataFromDate(startTime, toDate:endTime, withHandler: { (pedometerData:CMPedometerData?, error:NSError?) -> Void in
			
			guard let pedometerData = pedometerData else { return }
			handler(pedometerData, error)
			
			// 做一些事情
			
		})
		// 最后逼不得已只能不修改了，函数外面就做一些事情了
		pedonmeter.queryPedometerData(from: startTime, to: endTime, withHandler:  handler as! CMPedometerHandler)
		
	}

```

#### Result of call to 'funtion' is unused

- 这其实不是一个 编译错误，但是这个警告最开始让我有点懵逼.返回值不用难道要我都修改一下？
- 最开始其实我是这么修改的 ` let _ = funtion() `,但是后面在看[SE-0047](https://github.com/apple/swift-evolution/blob/master/proposals/0047-nonvoid-warn.md)的时候发现`@discardableResult`也是可以达到这个效果的。

#### Date && NSDate

- 因为有个项目中使用的 **DateTools** 这个工具。它有一个 **NSDate + Tools** 的分类。
- 但是在写 Swift 3 的过程中我发现如果变量是 Date 类型的无法使用**NSDate + Tools** 这个类型，必须显示声明 **date as NSDate** 这样才能调用分类的一些个方法。
- 这个让使用 OC 的库的时候会感觉十分不舒服，毕竟很多 NS 的前缀去掉了。所有都显示声明太不友好了。

#### CAAnimationDelegate
- 这个其实好像是 Xcode 8 的修改。因为之前CAAnimationDelegate 是一个分类。大概声明如下：

```
@interface NSObject (CAAnimationDelegate)

- (void)animationDidStart:(CAAnimation *)anim;
- 
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag;

@end
```
- 之前是在 vc 中只要重写一下 `animationDidStart` 函数就可以了。但是新的不行，起初以为是 Swift 3 的变化，但是其实是 Xcode 8 中的修改。将 CAAnimationDelegate 变成了一个协议。我感觉这个修改是为了适配   Swift 3 ？变化如下：

```
@protocol CAAnimationDelegate <NSObject>
@optional

- (void)animationDidStart:(CAAnimation *)anim;
- 
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag;

@end

```

>  因为宽度时间比较长，其他的暂时想不到了。未完待续吧...



## 其他
- 还有许多微妙的变化让你似乎看不懂这个语言了，所以建议在适配之前看一下下面的文章。
    - [Swift 3 新特性一览](https://realm.io/cn/news/appbuilders-daniel-steinberg-whats-new-swift-3/)
    - [Swift 3.0 - Released on September 13, 2016]https://github.com/apple/swift-evolution/blob/master/releases/swift-3_0.md
    - 还有@卓同学 的 [Swift 3 必看系列](http://www.jianshu.com/notebooks/6709594/latest)
- 还有几个不错的总结
    - [Swift 3](http://tech.glowing.com/cn/swift3/) by [顾 鹏](http://gupeng.me/)
    - [适配 Swift 3 的一点小经验和坑](https://zhuanlan.zhihu.com/p/22584349) by [图拉鼎](http://weibo.com/tualatrix)

## 总结
- 总的说来这次迁移没有想象中的那么痛苦，虽然提案的改动很大，但是得益于 Xcode 8 的迁移工具，这次迁移花费时间不多，当然也有可能和我的代码量有关系~
- 在迁移完之后，再看代码，会发现 Swift 更加的优雅了，至少相比于 2 来说好了很多，至于好在哪里？你自己写写不就知道了咯。
- 最后，终于可以把 Xocde 7 卸载，再也不用担心两个一起开无脑闪退了！！！
- 最后对于明年的 **Swift 4** 只想说 快来吧~分分钟把你解决！
- 其实适配之路才刚刚开始，因为 Xcode 8 自动转的代码并没有很好的 Swift 3 化。目前只是说在 Swift 3 可以编译通过了而已~

