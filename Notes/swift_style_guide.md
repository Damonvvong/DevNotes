# Swift 编码风格

## Table of Contents

- [1.代码格式](#1.代码格式)
- [2.命名](#2.命名)
- [3.编码风格](#3.编码风格)
  - [3.1 基础](#3.1-基础)
  - [3.2 访问修饰符](#3.2-访问修饰符)
  - [3.3 自定义操作符](#3.3-自定义操作符)
  - [3.4 `Switch` 语句和 `enum`s](#3.4-`Switch`-语句和-`enum`s)
  - [3.5 可选值 Optionals](#3.5-可选值-Optionals)
  - [3.6 协议 Protocols](#3.6-协议-Protocols)
  - [3.7 属性 Properties](#3.7-属性-Properties)
  - [3.8 闭包 Closures](#3.8-闭包-Closures)
  - [3.9 数组 Arrays](#3.9-数组-Arrays)
  - [3.10 错误处理 Error Handling](#3.10-错误处理-Error-Handling)
  - [3.11 使用 Guard](#3.11-使用-Guard)
- [4.文档及注释 Documentation / Comments](#4.文档及注释-Documentation-/-Comments)
  - [4.1 文档](#4.1-文档)
  - [4.2 Other Commenting Guidelines:其他的注释规则](#4.2-Other-Commenting-Guidelines:其他的注释规则)
- [参考](#参考)

## 1.代码格式

- 1.1 使用**4个空格**来代替Tabs
    - Xcode -> Preferences -> Text Editing -> Indentation - Tab width: **4** speaces
- 1.2 建议设置单行**最大长度**为160
    - Xcode -> Preferences -> Text Editing -> Editing - Page guide at column:**160**
- 1.3 保证每个文件最后都有一个**空行**
- 1.4 不要有无意义的**尾随空格**
    - Xcode -> Preferences -> Text Editing -> Editing - Automatically trim trailing whitespace & Including whitespace-only lines
- 1.5 不要将**左花括号**另起一行

```Swift
class DXYExample {
    func method() {
        if x == y {
            /* ... */
        } else if x == z {
            /* ... */
        } else {
            /* ... */
        }
    }
}
```

- 1.6 类型声明冒号前不需要**空格**，冒号后需要**空格**。

```Swift
// 类型声明
let name: String

// 字典
let dictionary: [String: Any] = [
    "boolKey": false,
    "stringKey": "value"
]

// 函数
func print(with value: String, without value: String) {
    /* ... */
}
// 函数调用
print(with: "123 ",without: " ")

// 继承
class Dog: Animal {
    /* ... */
}
```

- 1.7 **逗号**后面都要加一个**空格**

```Swift
let array = [1, 2, 3, 4, 5]
```

- 1.8 **二元操作符**前后都要加上**空格**。`(`、`)`除外

```Swift
let result = 10 + (10 / 5) * 2
```

- 1.9 严格遵循 **Xcode** 推荐的缩进格式「*在你按下 CTRL-I 的时候没有任何变化*」

- 1.10 在调用**多参数函数**的时候，把每个参数放置到单独的行中。
    - **多参数函数**: 参数大于等于 **4** 的函数.

```Swift
method(
    first: "DXY",
    second: 0,
    third: true,
    fourth: 1.0)
```

- 1.11 对于一个大的数组或者字典而言，应该将其分割到多行内，`[` 与 `]`类比于花括号进行处理。 

```Swift
methodWithSomeLargeArguments(
    largeArray: [
        "1", "2", "3", "4", "5", "6",
        "1234567890123456789012345678901234567890"
    ],
    largeDctionary:[
        "key1": "1234567890-1234567890",
        "key2": "-0987654321-0987654321"
    ])
```

- 1.12 使用临时变量的方式来代替多行的判断语句

```Swift
// 推荐
let first = x == firstReallyReallyLongFunction()
let second = y == secondReallyReallyLongFunction()
let third = z == thirdReallyReallyLongFunction()
if first && second && third {
    // ...
}

// 不推荐
if x == firstReallyReallyLongFunction()
    && y == secondReallyReallyLongFunction()
    && z == thirdReallyReallyLongFunction() {
    // ...
}
```

## 2.命名

- 2.1 类名不需要**前缀**。比如是 `String` 而不是 `NSString`
- 2.2 使用 `PascalCase` 规则对 `struct`, `enum`, `class`, `typedef`, `associatedtype` 类型命名
    - **PascalCase**: 大驼峰命名，它主要的特点是将描述变量作用所有单词的首字母大写，然后直接连接起来，单词之间没有连接符

- 2.3 使用`camelCase`规则，对函数名、方法名、属性名、常量名、变量名、参数名、枚举case等命名
    - **camelCase**: 小驼峰命名，它主要的特点是将描述变量作用第一个单词首字母小写其他所有单词的首字母大写，然后直接连接起来，单词之间没有连接符

- 2.4 在处理**缩写单词**的时候，尽可能的全部大写，并且保证代码中统一。如果遇到需要首字母小写且**缩写单词**在首字母时，所有的单词都需要小写

```Swift
// 推荐
let htmlBodyContent: String = "Hello, DXY!"
let userID: Int = 1
class URL {
    /* ... */
}
// 不推荐
let userId: Int = 1
let uRLString: String = "..."
```

- 2.5 所有不依赖于实例的常量都应该用 static 修饰，单例除外。所有被 `static` 修饰的常量最好放到一个 **enum** 容器中(为什么是 **enum** 参照 3.1.16)。容器不要命名成复数（比如是 `Constant` 而不是 `Constants`）。对于不能显而易见看出是一个容器的命名，建议用`Constant`作为命名的结尾，并用这个容器对同的前缀、后缀或者用例进行分组。

```Swift
class MyClassName {
    // 推荐
    enum AccessibilityIdentifier {
        static let pirateButton = "pirate_button"
    }
    enum SillyMathConstant {
        static let indianaPi = 3
    }
    static let shared = MyClassName()

    // 不推荐
    static let kPirateButtonAccessibilityIdentifier = "pirate_button"
    enum SillyMath {
        static let indianaPi = 3
    }
    enum Singleton {
        static let shared = MyClassName()
    }
}

```

- 2.6 对于泛型或者关联类型，使用 `PascalCase` 描述泛型，如果泛型名与父类或者子类重复，那么可以添加一个`Type`后缀名到泛型名上。

```Swift
class DXYClass<Model> {
    /* ... */
}

protocol Modelable {
    associatedtype Model
}

protocol Sequence {
    associatedtype IteratorType: Iterator
}
```

- 2.7 命名必须是**清晰**且**表意明确**的

```swift
// 推荐
class Cat: Animal {
    /* ... */
}

// 不推荐
class SmallAnimal: Animal {
    /* ... */
}
```

- 2.8 请勿**缩写**、**简写**或者**单个字母**命名

```swift
//推荐
class Cat: Animal {
    var eyeNumber: Int

    func eatFish() {
        // ...
    }
}
// 不推荐
class Cat: Animal {
    var eye: Int

    func eatF() {
        // ...
    }
}
```

- 2.9 对于类型不明确的常量或者变量，需要在名字中体现变量或者常量的类型

```swift
// 推荐
class ConnectionTableViewCell: UITableViewCell {
    let avatarImageView: UIImageView
    let pageNumber: Int
    // 名字明显是字符串，所以不需要 String 作为后缀
    let firstName: String
    // 虽然不推荐，但是也可以用 `Controller` 来代替 `ViewController`
    let popupController: UIViewController
    let popupViewController: UIViewController
    // 对于 `UIViewController`,建议在名字中完全的体现出它的类型。
    // 比如: UICollectionViewController\UITableViewController 等
    let popupCollectionViewController: UICollectionViewController
}
// 不推荐
class ConnectionTableViewCell: UITableViewCell {
    // 会让人误解，到底是 UIImage 还是 UIImageView
    let avatarImage: UIImageView
    // text 从语义上理解是 String，但是其实这里是 textLabel
    let text: UILabel
    // 因为不推荐使用缩写，所以不要用`VC` instead of `ViewController`
    let popupVC: UIViewController
    // 从 popupViewController 并不能看出到底是 CollectionViewController 还是 ViewController
    let popupViewController: UICollectionViewController
}
```

- 2.10 对于函数和构造器，除非上下文已经很清晰，最好为所有参数添加局部参数名。如果可以的话，最好也添加外部参数名来让函数调用语句更易读。

```Swift
func convertPointAt(column column: Int, row: Int) -> CGPoint
func timedAction(afterDelay delay: NSTimeInterval, perform action: SKAction) -> SKAction!

convertPointAt(column: 42, row: 13)
timedAction(afterDelay: 1.0, perform: someOtherAction)
```

- 2.11 根据 [Apple's API Design Guidelines](https://swift.org/documentation/api-design-guidelines/) ，一个 `protocol` 需要命名为一个名词用来描述需要做什么（比如，`Collection`）并且使用 `able`, `ible`, or `ing` 等后缀来描述其能力（比如，`Equatable`, `ProgressReporting`）。如果前面几个对你都没有意义，你可以添加 `Protocol` 来命名。

```swift
// 描述符合这个协议是什么？ TableViewSectionProvider
protocol TableViewSectionProvider {
    func rowHeight(at row: Int) -> CGFloat
    var numberOfRows: Int { get }
    /* ... */
}

// 描述符合这个协议能干嘛？ Loggable
protocol Loggable {
    func logCurrentState()
    /* ... */
}

// 当以上的后缀对你都没用时，添加一个Protocol，来表明这是一个协议
protocol InputTextViewProtocol {
    func sendTrackingEvent()
    func inputText() -> String
    /* ... */
}
```

## 3.编码风格

### 3.1 基础

- 3.1.1 尽可能地使用 **let** 来代替 **var**

- 3.1.2 当你想从一个集合变成另外一个的时候，尽可能地使用 `map`, `filter`, `reduce`等组合来进行操作。确保在使用这些方法时避免使用有副作用的闭包。

```swift
// 推荐
let stringOfInts = [1, 2, 3].flatMap { String($0) }
// ["1", "2", "3"]

// 不推荐
var stringOfInts: [String] = []
for integer in [1, 2, 3] {
    stringOfInts.append(String(integer))
}

// 推荐
let evenNumbers = [4, 8, 15, 16, 23, 42].filter { $0 % 2 == 0 }
// [4, 8, 16, 42]

// 不推荐
var evenNumbers: [Int] = []
for integer in [4, 8, 15, 16, 23, 42] {
    if integer % 2 == 0 {
        evenNumbers.append(integer)
    }
}
```

- 3.1.3 不要对能够推断出类型的变量名或者常量名中显示的声明类型名

- 3.1.4 当一个函数有多个返回参数时，用 `Tuple` 来代替 `inout` 参数，并在元祖上来上参数标签。当某个元祖被多处地方用到时，记得使用 `typealias`。当然，如果元祖的元素有 3 个或者更多的时候，你应该考虑使用 `struct` 或者 `class`。

```swift
func pirateName() -> (firstName: String, lastName: String) {
    return ("Guybrush", "Threepwood")
}

let name = pirateName()
let firstName = name.firstName
let lastName = name.lastName
```

- 3.1.5 在创建 delegates/protocol 的时候需要小心 **Retain Cycles**, 这些属性要声明为 weak

- 3.1.6 在闭包中直接使用 **self** 可能会导致 **Retain Cycles**, 建议使用**捕获列表**
  - **捕获列表:** [capture list](https://developer.apple.com/library/ios/documentation/swift/conceptual/Swift_Programming_Language/Closures.html#//apple_ref/doc/uid/TP40014097-CH11-XID_163)

```swift
myFunctionWithEscapingClosure() { [weak self] (error) -> Void in
    // you can do this
    self?.doSomething()
    // or you can do this
    guard let strongSelf = self else {
        return
    }
    strongSelf.doSomething()
}
```

- 3.1.7 不要使用**标记中断**(在某个代码处写一个标记，通过 break 或者 continue 个跳转)

- 3.1.8 不要在控制流逻辑判断的时候加上**圆括号**

```swift
// 推荐
if x == y {
    /* ... */
}
// 不推荐
if (x == y) {
    /* ... */
}
```

- 3.1.9 不要在使枚举的时候写出全名, 使用简写。

```Swift
//推荐
imageView.setImageWithURL(url, type: .person)

// 不推荐
imageView.setImageWithURL(url, type: AsyncImageView.Type.person)
```

- 3.1.10 不要使用**类方法**的简写，因为从类方法推断上下文通常比**枚举**更难

```Swift
// 推荐
imageView.backgroundColor = UIColor.white

// 不推荐
imageView.backgroundColor = .white
```

- 3.1.11 不到万不得已，不要使用 **self.**

- 3.1.12 在编写某个方法的时候注意考虑下这个方法是否有可能被重载，如果不可能被重载那么应该使用 **final** 修饰符。还要注意加上 **final** 之后也会导致无法在测试的时候进行复写，所以还是需要综合考虑。一般而言，加上 **final** 修饰符后会提高编译的效率，所以应该尽可能地使用该修饰符。

- 3.1.13 在使用 `else`, `catch`等等类似的语句的时候，将关键字与花括号放在一行

```swift
if someBoolean {
    // do something
} else {
    // do something else
}

do {
    let fileContents = try readFile("filename.txt")
} catch {
    print(error)
}
```

- 3.1.14 对于一个**类方法**或者**类属性**，推荐使用 `static` 而不是 `class`。如果你需要在子类中重载这个类方法或者类属性，那么只能用 `class`，虽然可以考虑是否用 `protocol` 来代替

- 3.1.15 如果你声明了一个不需要参数也不会产生影响的函数，并且返回了一个对象或者值，考虑使用**计算属性**来代替它。

- 3.1.16 为了给一组静态函数或者静态变量一个**命名空间**，建议使用`enum`，而不是 `struct` 或者 `class`。在这个方式下，你不需要为这个容器增加一个初始化方法 `private init() { }`

### 3.2 访问修饰符

- 3.2.1 **访问修饰符**需要放在第一位

```swift
// 推荐
private static let coount: Int

// 不推荐
static private let count: Int
```

- 3.2.2 **访问修饰符**应该和需要被它修饰的对象再同一行

```swift
// 推荐
open class DXY {
    /* ... */
}

// 不推荐
open
class DXY {
    /* ... */
}
```

- 3.2.3 不需要显示的声明默认类型 **internal**

- 3.2.4 如果某个变量需要被单元测试所使用，你必须把它标注为 **internal** 保证**@testable import ModuleName**。这里特别注意的是，哪些被声明为 **private** 的变量为了测试用途改成了 **internal**，那么需要注释声明一下。

- 3.2.5 优先使用 **private** 而不是 **fileprivate**

- 3.2.6 当你在 **public** 和 **open** 选择时。优先选择 **public**，除非你打算被外部模块继承并使用。值得注意的是，当使用 **@testable import**，任何 **internal**、**public**、**open**都可以被继承，所以这个不是你使用 **open**的理由。一般来说，使用 **open** 会让使用者更加领过，但出于一些模块的考虑，使用 **public** 会更加严谨和安全。

### 3.3 自定义操作符

尽可能使用命名函数，而不是自定义操作符。

如果你打算引入一个自定义操作符，你得有一个很好的理由来说明为什么需要这样一个自定义操作符到全局范围中而不是使用其他方式。

你可以重载已经存在的操作符去支持新的类型（尤其是 `==`）。但是，你的重载必须保留运算符语义。比如 `==` 一定是测试相等并返回一个布尔值

### 3.4 `Switch` 语句和 `enum`s

- 3.4.1 对于一个有限的枚举，在使用 **Switch** 语句的时候，尽量避免使用 **default**关键字，应该把没有使用的case放到最下面然后使用 **break** 关键字来阻止执行

- 3.4.2 不到万不得已，不需要写上 **break**

- 3.4.3 **case** 语句需要按照 **Swift** 标准来进行换行和对齐。

- 3.4.4 当定义了一个关联类型，确保关联类型的值有一个标签表述，而不单纯的是一个类型描述。（比如，使用 `hunger(hungerLevel: Int)` 去代替 `hunger(Int)`）

```Swift
enum URL {
    case article(id: Int)
    case message
}

func handleURL(url: URL) {
    switch url {
    case .article(let id):
        print("articleID:\(id)")
    case .message:
        print("message")
    }
}
```

- 3.4.5 优先使用 `case 1, 2, 3:` 而不是使用 **fallthrough** 关键字。

- 3.4.6 对于一个不应该处理的默认情况，你需要抛出一个异常(或者类似处理方式，比如断言)。

```Swift
func handleDigit(_ digit: Int) throws {
    switch digit {
    case 0, 1, 2, 3, 4, 5, 6, 7, 8, 9:
        print("Yes, \(digit) is a digit!")
    default:
        throw Error(message: "The given number was not a digit.")
    }
}
```

### 3.5 可选值 Optionals

- 3.5.1 只有使用 `@IBOutlets` 可以使用**隐式解包**，虽然在有些场景下，使用**隐式解包**也不会出现任何问题，但是为了保持一致和安全，建议不要使用。相同原因，**也不要在任何地方使用强制解包**！**不要在任何地方使用强制解包**！**不要在任何地方使用强制解包**！
- 3.5.2 不要使用 `as!` or `try!`
- 3.5.3 如果你只是想判断一个可选值是否为空，你应该直接拿这个值和`nil`作比较，而不是通过可选绑定（`if let`）把值给取出来。

```Swift
// 推荐
if optionalValue != nil {
    // ...
}

// 不推荐
if let _ = optionalValue {
    // ...
}
```

- 3.5.4 不建议使用 `unowned`。你可以理解 `unowned` 把 `weak变量` 做了一次**隐式解包**，虽然有时候使用 `unowned` 会比使用 `weak` 有一点点性能的提升，但是还是不建议使用 `unowned`。当然特殊情况除外。

```Swift
// 推荐
weak var parentViewController: UIViewController?

// 不推荐
weak var parentViewController: UIViewController!
unowned var parentViewController: UIViewController
```

- 3.5.5 当对**可选值**解包的时候，使用与**可选值**一致的变量名

```Swift
guard let optionalValue = optionalValue else {
    return
}
```

### 3.6 协议 Protocols

在实现协议的时候，大致有两种代码组织方式：
    1. 使用 `// MARK:` 来注释你实现协议中声明的方法。
    2. 在同一个文件内，通过借助 `extension` 把实现协议中声明的方法单独写到一块。
但是，有一点需要注意的是，如果你使用了第二种方式，那么定义在 `extension` 中的方法是无法被子类重载的，这样会让你的测试变得很困难。
最后，即便你使用了第二种方式，还是需要添加`// MARK:`注释，方便借助 Xcode 快速定位到相关代码。

### 3.7 属性 Properties

- 3.7.1 如果你要定义一个只读的计算属性，不需要显示的声明 `get { }`

```Swift
var computedProperty: String {
    if someBool {
        return "I'm a mighty pirate!"
    }
    return "I'm selling these fine leather jackets."
}
```

- 3.7.2 在使用 `get {}`、`set {}`、`willSet` 和 `didSet` 的时候，注意代码段的缩进
- 3.7.3 在 `willSet/didSet` 里面使用默认的 `newValue/oldValue` 的变量名。

```Swift
var storedProperty: String = "I'm selling these fine leather jackets." {
    willSet {
        print("will set to \(newValue)")
    }
    didSet {
        print("did set from \(oldValue) to \(storedProperty)")
    }
}

var computedProperty: String  {
    get {
        if someBool {
            return "I'm a mighty pirate!"
        }
        return storedProperty
    }
    set {
        storedProperty = newValue
    }
}
```

- 3.7.4 声明一个单例，用下面的方式：

```Swift
class PirateManager {
    static let shared = PirateManager()
    /* ... */
}
```

### 3.8 闭包 Closures

- 3.8.1 为了可读性和一致性，建议显示的声明传入参数的类型，除非这个参数的类型很容易被理解。

```swift
// 隐藏类型
doSomething() { response in
    // ...
}

// 显示声明类型
doSomething() { response: NSURLResponse in
    // ...
}

// 在使用flatMap使用简写
[1, 2, 3].flatMap { String($0) }
```

- 3.8.2 对于一个**闭包类型**，只有在这个闭包类型是个可选类型或者这个闭包类型是另外一个闭包类型的参数时才需要用括号包裹。对于闭包类型的参数类型列表，需要用括号包裹，并使用 Void 来表明不需要任何返回值。

```swift
let completion: (Bool) -> Void = { (success) in
    print("Success? \(success)")
}

let completion: () -> Void = {
    print("Completed!")
}

let completion: (() -> Void)? = nil
```

- 3.8.3 尽量保证让所有的参数名和左括号保持在同一行。（需要注意的是，一行不要超过 160 个字符）

- 3.8.4 尽量使用**尾随闭包**的方式，除非需要显示的声明闭包的含义。

```Swift
// 尾随闭包
doSomething(1.0) { (parameter1) in
    print("Parameter 1 is \(parameter1)")
}

// 非尾随闭包，需要表明闭包含义
doSomething(1.0, success: { (parameter1) in
    print("Success with \(parameter1)")
}, failure: { (parameter1) in
    print("Failure with \(parameter1)")
})
```

### 3.9 数组 Arrays

- 3.9.1 通常情况下，不要直接通过下标直接访问某个数组。尽可能的使用类似 .first、.last 这类不会造成闪退的方法进行访问。
- 3.9.2 使用 `for item in items` 来代替 `for i in 0` 的写法。
- 3.9.3 如果你不得不使用下标直接访问数组，一定要保证，不能越界。

- 3.9.4 (考虑到编译时间)不要使用 += 或者 + 运算符来增加或者链接数组，应该使用 `.append()` 或者 `.append(contentsOf:)`。
- 3.9.5 当你要声明一个数组是另外两个数组相加并且要保持这两个数组是不可变的。用 `let myNewArray = [arr1, arr2].joined()` 来代替 `let myNewArray = arr1 + arr2`。

### 3.10 错误处理 Error Handling

- 通常情况下，我们会选择可选值作为一个函数的返回值，当这个函数在某些条件下可能返回为空。示例如下：

```Swift

func readFile(named filename: String) -> String? {
    guard let file = openFile(named: filename) else {
        return nil
    }

    let fileContents = file.read()
    file.close()
    return fileContents
}

func printSomeFile() {
    let filename = "somefile.txt"
    guard let fileContents = readFile(named: filename) else {
        print("Unable to open file \(filename).")
        return
    }
    print(fileContents)
}

```

但是，有些时候，我们需要知道为什么会返回空值。这时候，我们就需要借助 `try/catch` 来处理。示例如下：

```Swift

struct Error: Swift.Error {
    public let file: StaticString
    public let function: StaticString
    public let line: UInt
    public let message: String

    public init(message: String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        self.file = file
        self.function = function
        self.line = line
        self.message = message
    }
}

func readFile(named filename: String) throws -> String {
    guard let file = openFile(named: filename) else {
        throw Error(message: "Unable to open file named \(filename).")
    }

    let fileContents = file.read()
    file.close()
    return fileContents
}

func printSomeFile() {
    do {
        let fileContents = try readFile(named: filename)
        print(fileContents)
    } catch {
        print(error)
    }
}

```

所以，当我们需要知道为什么返回为空时，且这个原因不能从语义上看出来，需要用 **Error Handling** 来处理。而对于空值产生原因不关心时，可以返回一个可选值。

### 3.11 使用 Guard

- 3.11.1 一般来说，我们会优先使用 **Early Return** 的策略来避免 **if** 表达式中多层嵌套的代码。在这个前提下，使用 **guard** 语句可以有效的提高代码的可读性

```Swift
// 推荐
func eatDoughnut(at index: Int) {
    guard index >= 0 && index < doughnuts.count else {
        // 越界情况需要提早结束
        return
    }

    let doughnut = doughnuts[index]
    eat(doughnut)
}

// 不推荐
func eatDoughnut(at index: Int) {
    if index >= 0 && index < doughnuts.count {
        let doughnut = doughnuts[index]
        eat(doughnut)
    }
}
```

- 3.11.2 对可选值解包时，优先使用 **guard** 来代替 **if**

```Swift

// 推荐
guard let monkeyIsland = monkeyIsland else {
    return
}
bookVacation(on: monkeyIsland)
bragAboutVacation(at: monkeyIsland)

// 不推荐
if let monkeyIsland = monkeyIsland {
    bookVacation(on: monkeyIsland)
    bragAboutVacation(at: monkeyIsland)
}

// 更不推荐
if monkeyIsland == nil {
    return
}
bookVacation(on: monkeyIsland!)
bragAboutVacation(at: monkeyIsland!)
```

- 3.11.3 当我们在没有可选解包时选择使用 **if** 还是 **guard**，没有太多的强制约束，基本的原则是，**以可读性为前提，因地制宜**

```Swift
// 用 if 更有可读性
if operationFailed {
    return
}

// 用 guard 更有可读性
guard isSuccessful else {
    return
}

// 不要写双重否定的逻辑
guard !operationFailed else {
    return
}
```

- 3.11.4 当我们要处理两个不同的状态时，优先使用 **if** 语句而不是 **guard** 语句。

```Swift
// 推荐
if isFriendly {
    print("Hello, nice to meet you!")
} else {
    print("You have the manners of a beggar.")
}

// 不推荐
guard isFriendly else {
    print("You have the manners of a beggar.")
    return
}

print("Hello, nice to meet you!")
```

- 3.11.5 **guard** 更适用于有一个上下文的情况下去使用。对于两个不同的场景，使用 **if** 比使用 **guard** 更好一点。

```Swift
if let monkeyIsland = monkeyIsland {
    bookVacation(onIsland: monkeyIsland)
}

if let woodchuck = woodchuck, canChuckWood(woodchuck) {
    woodchuck.chuckWood()
}
```

- 3.11.6 当我们需要处理多个可选值时，不要把所有解包过程放到一起，将其拆分到多个单表达式中去。（ **guard** 闭包里用 return, break, continue, throw, or some other @noescape 结束异常流）

```Swift
// 聚合在一起只能使用 return 结束异常流
guard let thingOne = thingOne,
    let thingTwo = thingTwo,
    let thingThree = thingThree else {
    return
}

// 分开写可以处理异常流
guard let thingOne = thingOne else {
    throw Error(message: "Unwrapping thingOne failed.")
}

guard let thingTwo = thingTwo else {
    throw Error(message: "Unwrapping thingTwo failed.")
}

guard let thingThree = thingThree else {
    throw Error(message: "Unwrapping thingThree failed.")
}
```

- 3.11.7 不要把 **guard** 写在一行。

```Swift
// 推荐
guard let thingOne = thingOne else {
    return
}

// 不推荐
guard let thingOne = thingOne else { return }
```

## 4.文档及注释 Documentation / Comments

### 4.1 文档

如果一个函数的复杂度不是 O(1),那么最好给这个函数添加一些文档注释，这样能有效的提高代码的可读性和可维护性。
如果通过一个比较独特方式去实现一个(有趣、棘手、不明显)的函数，也需要给这个函数添加注释。
同时也应该为复杂的 **classes/structs/enums/protocols/properties** 和 所有的被 **public** 修饰的 **functions/classes/properties/constants/structs/enums/protocols** 等，添加文档注释。

当写完注释以后，需要检查一下格式是否有问题。

格式规范，请参照 [Described in Apple's Documentation](https://developer.apple.com/library/tvos/documentation/Xcode/Reference/xcode_markup_formatting_ref/Attention.html#//apple_ref/doc/uid/TP40016497-CH29-SW1)

- 4.1.1 每行不应超过160个字符
- 4.1.2 即使某些注释只有一行，也应该使用块注释符： (/** */).
- 4.1.3 不用给每行的开头都加上 `*`
- 4.1.4 使用 `- parameter` 标识符来代替`:param: syntax`(注意是 **parameter** 而不是 **Parameter**)

```Swift
class Human {
    /**
     This method feeds a certain food to a person.

     - parameter food: The food you want to be eaten.
     - parameter person: The person who should eat the food.
     - returns: True if the food was eaten by the person; false otherwise.
    */
    func feed(_ food: Food, to person: Human) -> Bool {
        // ...
    }
}
```

- 4.1.5 如果你准备对参数/返回值/异常值来写注释，那么注意要一个不落的全局加上，尽管有时候会让文档显得重复冗余。有时候，如果只需要对单个参数进行注释，那么还不如直接放在描述里进行声明，而不需要专门的为参数写一个注释。
- 4.1.6 对于复杂的使用类，应该添加一些具体的使用用例来描述类的用法。注意 **Swift** 的注释文档中是支持MarkDown语法的，这是一个很好的特性。

```Swift
/**
 ## Feature Support

 This class does some awesome things. It supports:

 - Feature 1
 - Feature 2
 - Feature 3

 ## Examples

 Here is an example use case indented by four spaces because that indicates a
 code block:

     let myAwesomeThing = MyAwesomeClass()
     myAwesomeThing.makeMoney()

 ## Warnings

 There are some things you should be careful of:

 1. Thing one
 2. Thing two
 3. Thing three
 */
class MyAwesomeClass {
    /* ... */
}
```

- 4.1.7 使用 `-` 在注释中著名引用的代码

```Swift
/**
 This does something with a `UIViewController`, perchance.
 - warning: Make sure that `someValue` is `true` before running this function.
 */
func myFunction() {
    /* ... */
}
```

- 4.1.8 保证文档的注释尽可能的简洁

### 4.2 Other Commenting Guidelines:其他的注释规则

- 4.2.1 //后面总是要跟上一个空格

- 4.2.2 注释永远要放在单独的行中

- 4.2.3 在使用 `// MARK: - whatever` 的时候，注意 **MARK** 与代码之间保留一个空行

```Swift
class Pirate {
    // MARK: - instance properties
    private let pirateName: String

    // MARK: - initialization
    init() {
        /* ... */
    }
}
```

## 参考

- [Raywenderlich Swift Style Guide](https://github.com/raywenderlich/swift-style-guide)
- [Linkedin Swift Style Guide](https://github.com/linkedin/swift-style-guide)
- [Github Swift Style Guide](https://github.com/github/swift-style-guide)
- [Eure  Swift Style Guide](https://github.com/eure/swift-style-guide)
