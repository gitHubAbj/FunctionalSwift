//
//  QuickCheckViewController.swift
//  FunctionalSwift
//
//  Created by Abj on 2018/1/6.
//  Copyright © 2018年 Abj. All rights reserved.
//

import UIKit

/*  第5章 案例研究: QuickCheck
 *  QuickCheck是一个用于随机测试的Haskell库。相比于独立的单元测试中每个部分都依赖特定
 *  输入来测试函数是否正确，QuickCheck允许你描述函数的抽象特性并生成测试来验证这些特性。
 *  当一个特性通过了测试，就没有必要再证明它的正确性。
 *  更确切的说，QuickCheck旨在找到证明特性错误的临界条件。
 */

class QuickCheckViewController: UIViewController {
    
    // 验证加法是一个满足交换律的运算
    func plusIsCommutative(x: Int, y: Int) -> Bool {
        return x + y == y + x
    }
    
    // 用QuickCheck检验这条语句就像调用check函数一样:
    // check函数一遍又一遍地调用plusIsCommutative函数且每次传递两个随机整型值作为参数,以此来完成上述检验。
    // 如果语句不为真，则它将会打印出导致测试失败的输入值。
    // 这里的关键是，我们可以用返回Bool的函数来描述代码的抽象特性(如交换律)
    // check("Plus should be commutative", plusIsCommutative)
    // print: "Plus should be commutative" passed 10 tests.
    
    // 当然，并不是所有的测试都能通过
    // 定义一个语句来描述减法满足交换律
    func minusIsCommutative(x: Int, y: Int) -> Bool {
        return x - y == y - x
    }
    
    // check("Minus should be commutative", minusIsCommutative)
    // print: "Minus should be commutative" does not hold: (3, 2)
    
    // 使用Swift的尾随闭包语法，我们也可以直接编写测试，而无需单独定义(像plusIsCommutative或minusIsCommutative这样的)特性:
    // check("Additive identity") { (x: Int) in x + 0 == x }
    // print: "Additive identity" passed 10 tests.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "案例研究: QuickCheck"
    
        // 生成随机数
        print(Int.arbitrary())
        print(String.arbitrary())
        
        // 测试特性
        // 这个例子充分的说明了何时QuickCheck会非常有用:它为我们找到了临界情况。
        // 如果尺寸有且只有一个负值，则我们的area函数将返回一个负值。
        check1(message: "Area should be at least 0") { (size: CGSize) -> Bool in
            size.area >= 0
        }
        // print: "Area should be at least 0" doesnot hold: (36.0, -33.0)
        
        check1(message: "Every string starts with Hello") { (s: String) -> Bool in
            s.hasPrefix("Hello")
        }
        // print: "Every string starts with Hello" doesnot hold: NRTYBRBSRNLOLGQPESSVKDMGRPTRXUOKRVE
        
        print(100.smaller() as Any)
        // print: Optional(50)
        
        // 验证我们所实现的快速排序,大量随机数组将会被生成并传递给我们的测试
        check(message: "qsort should behave like sort") { (x: [Int]) -> Bool in
            return qsort(array: x) == x.sorted(by: { (x, y) -> Bool in
                return x < y
            })
        }
        // print: "qsort should behave like sort" passed 10 tests
    }
}

// 为了构建Swift版本的QuickCheck，我们需要做几件事情:
// 1.我们需要一个方法来生成不同类型的随机数
// 2.实现check函数，然后将随机数传递给它的特性参数
// 3.如果一个测试失败了，我们会希望测试的输入值尽可能小。
// 4.做一些额外的工作以确保检验函数适用于带有泛型的类型

// 在理想情况下，我们希望失败的输入尽可能简单。
// 通常，反例所处的范围越小，越容易定位到失败是由哪一段代码引起的。
// 定义一个Smaller的协议，尝试缩小反例所处的范围
protocol Smaller {
    func smaller() -> Self?
}

// 定义一个可以表达如何生成随机数的协议
protocol Arbitrary: Smaller {
    static func arbitrary() -> Self
}



extension Int: Arbitrary {
    static func arbitrary() -> Int {
        return Int(arc4random())
    }
}

extension CGFloat: Arbitrary {
    func smaller() -> CGFloat? {
         return nil
    }
    
    static func arbitrary() -> CGFloat {
        return CGFloat(Int.random(from: -100, to:100))
    }
}

extension Int {
    static func random(from: Int, to: Int) -> Int {
        return from + (Int(arc4random()) % (to - from))
    }
}

extension Character: Arbitrary {
    func smaller() -> Character? {
        return nil
    }
    
    // 随机生成大写字母
    static func arbitrary() -> Character {
        return Character(UnicodeScalar(Int.random(from: 65, to: 90))!)
    }
}

func tabulate<A>(times: Int, transform: (Int) -> A) -> [A] {
    return (0..<times).map(transform)
}

extension String: Arbitrary {
    static func arbitrary() -> String {
        // 随机生成一个介于0~40的数作为字符创的长度。
        let randomLength = Int.random(from: 0, to: 40)
        // 生成x个随机字符
        let randomCharacters = tabulate(times: randomLength) { _ in
            Character.arbitrary()
        }
        return String(randomCharacters)
    }
}

// check1函数包含一个简单循环，每次迭代时为待检验特性生成随机的输入值，然后进行检验。一旦发现反例，就将其打印出来，并立即返回。否则check1函数将会汇报成功通过的测试数量。
func check1<A: Arbitrary>(message: String, _ property: (A) -> Bool) -> () {
    let numberOfInterations = 100
    for _ in 0..<numberOfInterations {
        let value = A.arbitrary()
        guard property(value) else {
            print("\"\(message)\" doesnot hold: \(value)")
            return
        }
        print("\"\(message)\" passed \(numberOfInterations) tests")
    }
}

extension CGSize {
    var area: CGFloat {
        return width * height
    }
}

extension CGSize: Arbitrary {
    func smaller() -> CGSize? {
        return CGSize.zero
    }
    
    static func arbitrary() -> CGSize {
        return CGSize(width: CGFloat.arbitrary(), height: CGFloat.arbitrary())
    }
}

extension Int: Smaller {
    // 对于整数，我们尝试将其除以2，直到等于0
    func smaller() -> Int? {
        return self == 0 ? nil : self / 2
    }
}

extension String: Smaller {
    // 对于字符串，则是移除第一个字符(除非该字符串为空)
    func smaller() -> String? {
        return isEmpty ? nil : String(self.dropFirst())
    }
}

// 接受一个条件和一个初始值，并且只要条件成立就反复调用本身
func iterateWhile<A>(condition: (A) -> Bool, initial: (A), next: (A) -> A?) -> A {
    if let x = next(initial), condition(x) {
        return iterateWhile(condition: condition, initial: x, next: next)
    }
    return initial
}

// 反复缩小测试中发现的反例所属范围
func check2<A: Arbitrary>(message: String, _ property: (A) -> Bool) -> () {
    // 生成随机输入值，再检验它们是否满足property参数，以及一旦发现反例，就反复缩小其范围
    let numberOfIterations = 10
    for _ in 0..<numberOfIterations {
        let value = A.arbitrary()
        guard property(value) else {
            let smallerValue = iterateWhile(condition: { !property($0) }, initial: value) {
                $0.smaller()
            }
            print("\"\(message)\" doesnot hold: \(smallerValue)")
            return
        }
    }
    print("\"\(message)\" passed \(numberOfIterations) tests.")
}



// 生成随机数组
// 函数式版本的快速排序
func qsort(array: [Int]) -> [Int] {
    var tmpArr = array
    if array.isEmpty { return [] }
    let pivot = tmpArr.removeFirst()
    let lesser = tmpArr.filter { $0 < pivot }
    let greater = tmpArr.filter { $0 >= pivot }
    let pivots = [pivot]
    return qsort(array: lesser) + pivots + qsort(array: greater)
}

extension Array: Smaller {
    // 移除数组的第一项
    func smaller() -> [Element]? {
        guard !isEmpty else {
            return nil
        }
        return Array(dropFirst())
    }
}

// 任何遵循Arbitrary协议的类型会生成一个随机长度的数组
extension Array where Element: Arbitrary {
    static func arbitrary() -> [Element] {
        let randomLength = Int(arc4random() % 50)
        return tabulate(times: randomLength) { _ in
            Element.arbitrary()
        }
    }
}

struct ArbitraryInstance<T> {
    let arbitrary: () -> T
    let smaller: (T) -> T?
}

// checkHelper的定义严格参照前面的check2函数.
// 两者之间唯一的不同是arbitrary和smaller被定义的位置.
// 在check2中，它们被泛型类型<A: Arbitrary>约束,而在checkHelper中，它们在ArbitraryInstance结构体中被显示的传递。这么做，灵活性更高
func checkHelper<A>(arbitraryInstance: ArbitraryInstance<A>, _ prorerty: (A) -> Bool, _ message: String) -> () {
    let numberOfIterations = 10
    for _ in 0..<numberOfIterations {
        let value = arbitraryInstance.arbitrary()
        guard prorerty(value) else {
            let smallerValue = iterateWhile(condition: { (x: A) -> Bool in
                return !prorerty(x)
            }, initial: value, next: arbitraryInstance.smaller)
            print("\"\(message)\" doesnot hold: \(smallerValue)")
            return
        }
    }
    print("\"\(message)\" passed \(numberOfIterations) tests")
}

func check<X: Arbitrary>(message: String, property: (X) -> Bool) -> () {
    let instance = ArbitraryInstance<X>(arbitrary: X.arbitrary() as! () -> X, smaller: { (x: X) -> X in
        return x.smaller()!
    })
    checkHelper(arbitraryInstance: instance, property, message)
}

// 如果无法定义所需要的Arbitrary实例，就像数组一样
// 则可以重载check函数并自己构造所需要的ArbitraryInstance结构体
func check<X: Arbitrary>(message: String, _ property: ([X]) -> Bool) -> () {
    let instance = ArbitraryInstance(arbitrary: Array.arbitrary, smaller: { (x: [X]) in x.smaller() })
    checkHelper(arbitraryInstance: instance, property, message)
}

