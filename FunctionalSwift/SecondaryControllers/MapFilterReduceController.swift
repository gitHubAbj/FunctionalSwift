//
//  MapFilterReduceController.swift
//  FunctionalSwift
//
//  Created by Abj on 2017/12/25.
//  Copyright © 2017年 Abj. All rights reserved.
//

import UIKit

/*  第3章:Map、Filter和Reduce
 *  接受其他函数作为参数的函数有时被称为高阶函数
 *  本章介绍Swift标准库中作用于数组的高阶函数、以及泛型的介绍
 */

struct City {
    let name: String
    let population: Int
}

extension City {
    func cityByScalingPopulation() -> City {
        return City(name: name, population: population * 1000)
    }
}

class MapFilterReduceController: UIViewController {

    let exampleFiles = ["README.md", "HelloWorld.swift", "FlappyBird.swift"]
    
    let paris = City(name: "Paris", population: 2241)
    let madrid = City(name: "Madrid", population: 3165)
    let amsterdam = City(name: "Amsterdam", population: 827)
    let berlin = City(name: "Berlin", population: 3562)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Map、Filter和Reduce"
        
        let cities = [paris, madrid, amsterdam, berlin]
        
        // 应用map、filter、reduce函数来筛选出居民数量至少有一百万的城市
        print(cities.filter { $0.population > 1000 }
            .map { $0.cityByScalingPopulation() }
            .reduce("City: Population") { result, c in
                return result + "\n" + "\(c.name): \(c.population)"
        })
    }
    
}

//MARK: - 泛型介绍

extension MapFilterReduceController {
    ///  对给定数组中的整型数据加1,生成新数组
    func incrementArray(xs: [Int]) -> [Int] {
        var result: [Int] = []
        for x in xs {
            result.append(x + 1)
        }
        return result
    }
    
    /// 对给定数组中的整型数据翻倍,生成新数组
    func doubleArray1(xs: [Int]) -> [Int] {
        var result: [Int] = []
        for x in xs {
            result.append(x * 2)
        }
        return result
    }
    
    /// 上面两个函数相同有着大量的相同代码
    /// 我们对参数进行改变,用函数做为参数来重写函数,以达到相同目的
    func computeIntArray(xs: [Int], transform: (Int) -> Int) -> [Int] {
        var result: [Int] = []
        for x in xs {
            result.append(transform(x))
        }
        return result
    }
    
    /// 参数化后的新函数(所有整型数据翻倍)
    func doubleArray2(xs: [Int]) -> [Int] {
        return computeIntArray(xs: xs) { x in x * 2 }
    }
    
    /// 用于求数组中的数据是否为偶数
    func computeBoolArray(xs: [Int], transform: (Int) -> Bool) -> [Bool] {
        var result: [Bool] = []
        for x in xs {
            result.append(transform(x))
        }
        return result
    }
    
    /// 同理上面的函数中局限了输入数据必须为Int类型
    /// 所以我们再次都函数就行优化
    /// 对于任何Element的数组和transform:Element -> T函数,它都会生成一个T的新数组
    func map0<Element, T>(xs: [Element], transform: (Element) -> T) -> [T] {
        var result: [T] = []
        for x in xs {
            result.append(transform(x))
        }
        return result
    }
    
    /// 同理computeIntArray、computeBoolArray两个函数之间存在的大量的相同代码
    /// 这样的拓展性不好
    /// 所以我们应用泛型来处理这种情况
    func genericComputeArray1<T>(xs: [Int], transform: (Int) -> T) -> [T] {
        var result: [T] = []
        for x in xs {
            result.append(transform(x))
        }
        return result
    }
    
    /// 再次优化后可写成这样
    func genericComputeArray2<T>(xs: [Int], transform: (Int) -> T) -> [T] {
        return map0(xs: xs, transform: transform)
    }
    
    /* 按照Swift的惯例将map定义为Array的扩展会更合适
     * 所以我们的函数又可以再次优化成这样
     */
    func genericComputeArray<T>(xs: [Int], transform: (Int) -> T) -> [T] {
        return xs.map(transform: transform)
    }
}

extension Array {
    func map<T>(transform: (Element) -> T) -> [T] {
        var result: [T] = []
        for x in self {
            result.append(transform(x))
        }
        return result
    }
}


// MARK: - Filter

extension MapFilterReduceController {
    // 我们要从exampleFiles数组中找出包含.swift的字符串并由新数组组成新的数组
    func getSwiftFiles(files: [String]) -> [String] {
        var result: [String] = []
        for file in files {
            if file.hasSuffix(".swift") {
                result.append(file)
            }
        }
        return result
    }
    
    // 优化后的函数可以这么写
    func getSwiftFiles2(files: [String]) -> [String] {
        return files.filter { file in file.hasSuffix(".swift") }
    }
}

extension Array {
    // 我们接下来可以使用同样的函数去比对.swift或.md字符串
    // 为了进行一个这样的查找,我们可以定义一个名为filter的通用型函数
    func filter(includeElement: (Element) -> Bool) -> [Element] {
        var result: [Element] = []
        for x in self where includeElement(x) {
            result.append(x)
        }
        return result
    }
}


// MARK: - Reduce

extension MapFilterReduceController {
    // 定义一个计算数组中所有整型值之和的函数
    func sum(xs: [Int]) -> Int {
        var result: Int = 0
        for x in xs {
            result += x
        }
        return result
    }
    
    // 定义一个计算数组中所有项的相乘之积的函数
    func product(xs: [Int]) -> Int {
        var result: Int = 1
        for x in xs {
            result = x * result
        }
        return result
    }
    
    // 定义一个连接数组中所有字符串的函数
    func concatenate(xs: [String]) -> String {
        var result: String = ""
        for x in xs {
            result += x
        }
        return result
    }
    
    // 定义一个连接数组中所有字符串并插入一个单独的首行,以及在每一项后面追加一个换行符的函数
    func prettyPrintArray(xs: [String]) -> String {
        var result: String = "Entries in the array xs:\n"
        for x in xs {
            result = " " + result + x + "\n"
        }
        return result
    }
    
    // 假设有一个数组,它的每一项都是数组,而我们想将它展开为一个单一数组
    func flatten<T>(xss: [[T]]) -> [T] {
        var result: [T] = []
        for xs in xss {
            result += xs
        }
        return result
    }
    
    /* 这些函数都有什么共同点呢?
     * 1.将变量result初始化为某个值
     * 2.对输入数组xs的每一项进行遍历
     * 3.以某种方式更新结果
     * 所以为Array扩展一个reduce方法
     */
    
    // 上面的方法可更改为下面的样式
    func sumUsingReduce(xs: [Int]) -> Int {
        return xs.reduce(0) { result, x in result + x }
    }
    
    func productUsingReduce(xs: [Int]) -> Int {
        return xs.reduce(initial: 1, combine: *)
    }
    
    func concatUsingReduce(xs: [String]) -> String {
        return xs.reduce(initial: "", combine: +)
    }
    
    func flattenUsingReduce<T>(xss: [[T]]) -> [T] {
        return xss.reduce([]) { result, xs in result + xs }
    }
}

extension Array {
    // 在一些像OCaml和Haskell一样的函数式语言中,reduce函数被称为fold或fold_left
    func reduce<T>(initial: T, combine:(T, Element) -> T) -> T {
        var result = initial
        for x in self {
            result = combine(result, x)
        }
        return result
    }
    
    // 应用reduce重写map函数
    func mapUsingReduce<T>(transform: (Element) -> T) -> [T] {
        return reduce([]) { result, x in
            return result + [transform(x)]
        }
    }
    
    // 应用reduce重写filter函数
    func filterUsingReduce(includeElement: (Element) -> Bool) -> [Element] {
        return reduce([]) { result, x in
            return includeElement(x) ? result + [x] : result
        }
    }
}

// MARK: - 泛型和Any类型

/* Any类型和泛型两者都能用于定义接受两个不同参数的类型
 * 区别: 泛型可以用于定义灵活的函数,类型检查由编译器负责
 *      Any类型则可以避免Swift的类型系统
 */
extension MapFilterReduceController {
    // noOp和noOpAny两者都将接受任意参数
    // 关键的区别在于我们所知道的返回值
    // noOp返回值和输入值一样
    // noOpAny返回值则是任意类型--甚至可以是和原来的输入值不同的类型
    func noOp<T>(x: T) -> T {
        return x
    }
    
    func noOpAny(x: Any) -> Any {
        return x
    }
    
    // example: noOpAny的错误定义
    // 其结果可能导致各种各样的运行时错误,所以应少用
    func noOpAnyWrong(x: Any) -> Any {
        return 0
    }
}
