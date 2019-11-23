# Diff 算法在 iOS 中的应用(一)

在计算机领域中，[Diff](https://en.wikipedia.org/wiki/Diff) 是一个很重要的概念，被广泛的运用于各式各样的场景。比如说，React 利用 Diff 大大减少了刷新导致的性能问题；Git 借助 Diff 算法实现了版本之间的差异化对比；腾讯 Tinker 热修复借助 Diff 算法生成 patch 包等等。

这系列文章，我会以 UICollectionView 为例，结合 IGListKit 、 DeepDiff 等几个优秀开源库，聊一下 Diff 算法在 iOS 中的一些应用和实现原理。

## UICollectionView 中的局部刷新

UICollectionView 提供了 insert、delete、reload、move 四个局部刷新的 API，具体如下:

- 插入（insert）

```Swift
var items = ["iOS","Weekly","Damonwong"]
items.append(contentsOf: ["Diff","UICollectionView"])
let indexPaths = Array(3...4).map { IndexPath(item: $0, section: 0) }
collectionView.insertItems(at: indexPaths)
```

- 删除（delete）

```Swift
var items = ["iOS","Weekly","Damonwong","Diff","UICollectionView"]
items.removeLast()
items.removeLast()
let indexPaths = Array(3...4).map { IndexPath(item: $0, section: 0) }
collectionView.deleteItems(at: indexPaths)
```

- 更新（reload）

```Swift
var items = ["iOS","Weekly","Damonwong"]
items[2] = "OldDriver"
let indexPath = IndexPath(item: 2, section: 0)
collectionView.reloadItems(at: indexPaths)
```

- 移动（move）

```Swift
var items = ["iOS","Weekly","Damonwong"]
items.remove(at: 1)
items.append("Weekly")
collectionView.moveItem(
  at: IndexPath(item: 1, section: 0),
  to: IndexPath(item: 2, section :0)
)
```

在实际开发过程中，通常需要通过上面四个基本操作相互组合才能达到效果。但是，我认为苹果在这方面的 API 设计的很不合理。稍微使用不当就会出问题。

> Invalid update: invalid number of items in section 0.  The number 
of items contained in an existing section after the update (11) 
must be equal to the number of items contained in that section 
before the update (7), plus or minus the number of items inserted 
or deleted from that section (1 inserted, 0 deleted) and plus or 
minus the number of items moved into or out of that section (0 moved in, 0 moved out).

遇到这个问题的原因千奇百怪，本质原因还是因为数据源和 IndexPath 不对应，导致刷新的时候出问题了。所以，通常情况下，如果要在项目中使用局部刷新，建议使用 `performBatchUpdates` 这个方法。可以减少很多问题。但是对于 `performBatchUpdates` 这个方法来说，也有一个重点需要关注，就是组合操作有执行步骤。具体文档如下:

> Deletes are processed before inserts in batch operations. This means the indexes for the deletions are processed relative to the indexes of the collection view’s state before the batch operation, and the indexes for the insertions are processed relative to the indexes of the state after all the deletions in the batch operation.

大概意思就是，无论你的数据源如何变化(是先删除，后新增，还是先新增，后删除)，对于 `performBatchUpdates` 而言，都需要先执行 `deleteItems` 再执行 `insertItems` 并且需要正确的 IndexPath。示例如下: 

```Swift
var items = ["a","b","c","d","e","f"]
items.append(contentsOf: [“g”, “h”, “i”])
items.removeFirst()
items.removeFirst()
items.removeFirst()
collectionView.performBatchUpdates({
  let deleteIndexPaths = Array(0…2).map { IndexPath(item: $0, section: 0) }
  collectionView.deleteItems(at: deleteIndexPaths)
  let insertIndexPaths = Array(3…5).map { IndexPath(item: $0, section: 0) }
  collectionView.insertItems(at: insertIndexPaths)
}, completion: nil)
```

总而言之，UICollectionView 提供了局部刷新的方式，但是对于实际使用过程中，还是有不少困难的。特别是找到正确的 IndexPath 和对应操作。

## 编辑路径

如果我们把刷新之前的数据源叫 **Old**，经过一系列变化之后变成了 **New**。我们把这「一系列变化」称之为 **编辑路径**。前文描述的插入（insert）、删除（delete）、更新（reload、移动（move）则是编辑路径的具体步骤。

举一个例子，从 `Wong` 变成 `VVong` 的编辑路径是: 
- **删除** 第一位的 `W`
- 在第一位 **插入** `V`
- 在第一位 **插入** `V`

所以，如果想要愉快的使用 `performBatchUpdates`，那么就要计算出从 **Old** 到 **New** 的编辑路径。

## Wagner–Fischer 算法

寻找编辑路径的方式有很多，[Wagner–Fischer 算法](https://en.wikipedia.org/wiki/Wagner%E2%80%93Fischer_algorithm) 就是一种，主要是通过动态规划的思路，限定**删除**、**插入**、**替换**三种步骤，找到一条最优的编辑路径。

#### 动态规划

> 动态规划（英语：Dynamic programming，简称DP）是一种在数学、管理科学、计算机科学、经济学和生物信息学中使用的，通过把原问题分解为相对简单的子问题的方式求解复杂问题的方法。

以 "wong" 变成 "vvong" 为例。

如果要解决 "wong" -> "vvong"，其实只需要解决 "won" -> "vvon"
而如果要解决 "won" -> "vvon"，其实只需要解决 "wo" -> "vvo"
而如果要解决 "wo" -> "vvo"，其实只需要解决 "w" -> "vv"
如果要解决 "w" -> "vv",其实只需要解决 "w" -> "v" + 插入 v
所以最后的答案是替换 w 为 v, 并插入 v。

#### 编辑步骤

- **替换** : 从 “w” 变成 “v”，需要一次替换。步数长度为 1。
- **删除** : 从 “w” 变成 “”，需要一次删除。步数长度为 1。
- **插入** : 从 “” 变成 “v”，需要一次插入。步数长度为 1。

#### 计算最小编辑路径

##### 1. 把问题分解为，从 “wong” -> "" 和 “” -> "vvong" 两个问题，并放到矩阵中。

![](https://images.xiaozhuanlan.com/photo/2018/60a96d4f0cafbdd7bfe18caa613cee85.png)

垂直方向的变化为删除，水平方向的变化为插入。每个方格对应从 A 到 B 的编辑路径。

以选中方格为例，指的是，从 "" -> "v" 的编辑路径为「1 * 插入」

##### 2. 根据上述矩阵，逐行计算出编辑路径。

因为已经确定了第一行和第一列的编辑路径，剩下的就需要一行一行的计算。
每一个新的编辑路径，都由方块所对应的「上」、「左上」、「左」三个编辑路径决定，具体规则如下:

- 如果方格所对应字母不同，则取「上边编辑路径长度」、「左上编辑路径长度」、「左边编辑路径长度」中的最小值。
    - 如果「上边编辑路径长度」最小，新的编辑路径为「上边编辑路径 + 1 * 删除」
    - 如果「左上编辑路径长度」最小，新的编辑路径为「左上编辑路径 + 1 * 替换」
    - 如果「左边编辑路径长度」最小，新的编辑路径为「左边的编辑路径 + 1 * 插入」
- 如果方格所对应字母相同，新的编辑路径为「左上编辑路径」

规则看不懂没关系，看下面几种情况。

![](https://images.xiaozhuanlan.com/photo/2018/6ecd5a72edb36aa610d6b0abe879cf6b.png)

因为 w != v，所以，所选中框的编辑路径为 min(1 * 插入 + 1 * 删除，1 * 替换，1 * 删除 + 1 * 插入) = 1 * 替换
(这里所求的min是编辑路径长度)

![](https://images.xiaozhuanlan.com/photo/2018/f35dcbaf2020be24fed4ca5163dbd117.png)

因为 v != o, 所以，所选中框的编辑路径为 min(1 * 替换 + 1 * 删除，1 * 删除 + 1 * 替换，2 * 删除 + 1 * 插入) = 1 * 替换 + 1 * 删除
(这里所求的min是编辑路径长度)

![](https://images.xiaozhuanlan.com/photo/2018/f6ca08326084ade704080a50b223eb3a.png)

因为 o != n，所选中框的编辑路径为 min(2 * 插入 + 1 * 替换 + 1 * 删除，2 * 插入 + 2 * 替换，2 * 插入 + 1 * 替换) = 2 * 插入 + 1 * 替换
(这里所求的min是编辑路径长度)

![](https://images.xiaozhuanlan.com/photo/2018/b3bca64350e4b123efb2e04ae82e2a58.png)

因为 o == o, 所以，所选中框的编辑路径为左上角的编辑路径 = 1 * 插入 + 1 * 替换

最终，右下角的 「1 * 插入 + 1 * 替换」 就是最终的答案。

#### 代码实现

```Swift
/// A single edit step.
public enum EditStep<Value> {
    case insert(location: Int, value: Value)
    case substitute(location: Int, value: Value)
    case delete(location: Int)

    public var location: Int {
        switch self {
        case .insert(let location, _): return location
        case .substitute(let location, _): return location
        case .delete(let location): return location
        }
    }
}

extension EditStep: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .insert(let index, let value):
            return "Insert(\(index), \(value))"
        case .substitute(let index, let value):
            return "Substitute(\(index), \(value))"
        case .delete(let index):
            return "Delete(\(index))"
        }
    }
}

public func editSteps<T>(_ source: [T], _ destination: [T], compare: (T, T) -> Bool) -> [EditStep<T>] {

    // Return all insertions if the source is empty.
    if source.isEmpty {
        return destination.enumerated().map(EditStep.insert)
    }

    // Return all deletions if the destination is empty.
    if destination.isEmpty {
        return (0..<source.count).reversed().map(EditStep.delete)
    }

    var matrix = Matrix<[EditStep<T>]>(
        rows: source.count + 1,
        columns: destination.count + 1,
        repeatedValue: [])

    for i in 1...source.count {
        matrix[i, 0] = (0...i).map(EditStep.delete)
    }

    for j in 1...destination.count {
        matrix[0, j] = (1...j).lazy.map({ $0 - 1 }).map({
            let destinationValue = destination[$0]
            return EditStep.insert(location: $0, value: destinationValue)
        })
    }

    for i in 1...source.count {
        for j in 1...destination.count {
            let destinationValue = destination[j - 1]
            if compare(source[i - 1], destinationValue) {
                matrix[i, j] = matrix[i - 1, j - 1]
            }
            else {
                let a = matrix[i - 1, j] + CollectionOfOne(.delete(location: i - 1))
                let b = matrix[i, j - 1] + CollectionOfOne(.insert(location: j - 1, value: destinationValue))
                let c = matrix[i - 1, j - 1] + CollectionOfOne(.substitute(location: j - 1, value: destinationValue))
                matrix[i, j] = shortest(a, b, c)
            }
        }
    }

    return matrix[source.count, destination.count]
}
```

#### 优点和不足

因为采用了动态规划的思路，所以最终找到的编辑路径一定是一个最优解。但是，也正是因为采用了动态规划，时间复杂度相对来说会比较复杂，是 O(m*n)，对于数据量比较大的场景来说会有很严重的性能问题。

我会在下篇文章中，说一种线性复杂度的 Diff 算法。也正是 IGListKit 中的列表 Diff 的实现原理。

