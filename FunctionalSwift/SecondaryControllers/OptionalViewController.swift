//
//  OptionalViewController.swift
//  FunctionalSwift
//
//  Created by Abj on 2018/1/3.
//  Copyright © 2018年 Abj. All rights reserved.
//

import UIKit

/*  第4章 可选值
 *  Swift的可选类型可以用来表示可能缺失或是计算失败的值.
 *  本章会介绍如何有效利用可选类型以及它们在函数式编程范式中的使用方式.
 */

// Swift的类型系统相当严格,一旦我们有可选类型,就必须处理它可能为nil的问题
// 选择显示的可选类型更符合Swift增强静态安全的特性.强大的类型系统能在代码执行前捕获到错误,而且显式可选类型有助于避免由缺失值导致的意外崩溃

// Swift还给!运算提供了一个更安全的替代---??运算符.
// ??运算符提供了一个相比于强制可选解包更安全的替代,并且不想可选绑定那样繁琐
// 使用这个运算符,你需要额外的提供一个默认值,当运算符被用于nil时,这个默认值会被作为返回值
precedencegroup  ComparisonPrecedence {
    associativity: left
    higherThan: LogicalConjunctionPrecedence
}

///定义运算符??
infix operator ??: ComparisonPrecedence

// 这里的定义会有一个问题:如果default的值是通过某个函数或者表达式得到的,那么无论这个可选值是否为nil,defaultValue都会被求值.
//func ??<T>(optional: T?, defaultValue: T) -> T {
//    if let x = optional {
//        return x
//    } else {
//        return defaultValue
//    }
//}

// 我们使用() -> T类型作为默认值避免上诉情况
// 但是又有一个不足的点是: 当调用??运算符时需要为默认值创建一个显示闭包
// example: myOptional ?? { myDefaultValue }
//func ??<T>(optional: T?, defaultValue: () -> T) -> T {
//    if let x = optional {
//        return x
//    } else {
//        return defaultValue()
//    }
//}


// 所以Swift标准库中的定义通过使用Swift的autoClosure类型标签来避免创建显示闭包的需求
func ??<T>(optional: T?, defaultValue: @autoclosure () -> T) -> T {
    if let x = optional {
        return x
    } else {
        return defaultValue()
    }
}

struct Order {
    let orderName: Int
    let person: Person?
}

struct Person {
    let name: String
    let address: Address?
}

struct Address {
    let streeName: String
    let city: String
    let state: String?
}

class OptionalViewController: UIViewController {

    // 存储欧洲的几个城市人口数量的字典
    let cities = ["Paris": 2241, "Madrid": 3165, "Amsterdam": 827, "Berlin": 3562]
    let order = Order(orderName: 121, person: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "可选值"
        // 获取Madrid城市的人口数量
        // let madridPopulation: Int = cities["Madrid"]
        // madridPopulation类型为可选类型Int?,而非Int
        // 一个Int?类型的值是Int或者特殊的'缺失'值nil
        let madridPopulation: Int? = cities["Madrid"]
        
        // madridPopulation是一个可选值,所以我们得加上后缀运算符!强制将一个可选类型转换为一个不可选类型
        if madridPopulation != nil {
            print("The population of Madrid is \(madridPopulation! * 1000)")
        } else {
            print("Unknown city: Madrid")
        }
        
        // Swift中有一个特殊的'可选绑定'机制,可以避免写!后缀
        // 值得注意的是,我们这里不需要显示的使用强制解包
        // 可选绑定鼓励你显示地处理异常情况,从而避免运行时错误(使用强制解包,在碰到nil值可能会崩溃)
        if let madridPopulation = cities["Madrid"] {
            print("The population of Madrid is \(madridPopulation * 1000)")
        } else {
            print("Unknown city: Madrid")
        }
        
        // 获取一个order的客户地址的state值
        // 如果任意中间数据缺失,这么做可能会导致运行时异常
        //order.person!.address!.state!
        
        // 使用可选绑定
        // 这种方法很是繁琐
        if let myPerson = order.person {
            if let myAddress = myPerson.address {
                if let myState = myAddress.state {
                    print(myState)
                }
            }
        }
        
        // Swift有一个特殊的机制--可选链
        // 使用可选链
        // 我们使用问好运算符来尝试对可选类型解包,而不是强制将它们解包
        // 当任意一个组成失败时,整条语句链将返回nil
        if let myState = order.person?.address?.state {
            print("This order will be shipped to \(myState)")
        } else {
            print("Unknown person, address, or state")
        }
        
        
        // 再介绍其他两种分支语句: switch和guard
        // 为了在一个switch语句中匹配可选值,我们简单地为case分支的每个模式添加一个?后缀
        // 如果我们对一个特定值没有兴趣,也可以直接匹配Optional的None值或Some值
        switch madridPopulation {
        case 0?:
            print("Nobody in Madrid")
        case (1..<1000)?:
            print("Less than a million in Madrid")
        case .some(let x):
            print("\(x * 1000) people in Madrid")
        case .none:
            print("We donot know about Madrid")
        }
        
        
        // guard语句的设计旨在在一些条件不满足时,可以尽早退出当前作用域
        func populationDescriptionForCity(city: String) -> String? {
            guard let population = cities[city] else {
                return nil
            }
            return "The population of Madrid is \(population * 1000)"
        }
        
        print(populationDescriptionForCity(city: "Madrid") as Any)
    }
    
    // 可选映射
    // ?运算符允许我们选择性地访问可选值的方法或字段
    // 但是,在很多其他例子中,若可选值存在,你可能会想操作它,否则返回nil
    func incrementOptional(optional: Int?) -> Int? {
        guard let x = optional else { return nil }
        return x + 1
    }
    
    // 这里我们可以将incrementOptional函数和?运算符一般化,然后为可选值定义一个map函数,这样的函数不仅可以做增量运算还可以做其他类型的运算了
    func incrementOptional2(optional: Int?) -> Int? {
        return optional.map { $0 + 1 }
    }
    
    
    // 再谈可选绑定
    // 以下这段程序不被Swift编译器接受
    // 这里的问题是加法运算只支持Int值,而不支持我们的Int?值
    /* let x: Int? = 3
     * let y: Int? = nil
     * let z: Int? = x + y
     */
    
    // 方案1：
    func addOptionals(optionalX: Int?, optionalY: Int?) -> Int? {
        if let x = optionalX {
            if let y = optionalY {
                return x + y
            }
        }
        return nil
    }
    
    // 方案2:
    func addOptionals2(optionalX: Int?, optionalY: Int?) -> Int? {
        if let x = optionalX, let y = optionalY {
            return x + y
        }
        return nil
    }
    
    // 方案3:
    func addOptionals3(optionalX: Int?, optionalY: Int?) -> Int? {
        guard let x = optionalX, let y = optionalY else {
            return nil
        }
        return x + y
    }
    
    // 方案4:
    // 可选链和if let(或guard let)都是语言中让可选值能够更易使用的特殊构造
    // 不过Swift还提供了另一条途径来解决上述问题：借助于标准库中的flapMap函数
    func addOptionals4(optionalX: Int?, optionalY: Int?) -> Int? {
        return optionalX.flatMap { x in
            optionalY.flatMap { y in
                return x + y
            }
        }
    }
}

extension Optional {
    // map函数接受一个类型为(Wrapped) -> U的transform函数作为参数
    func map<U>(transform: (Wrapped) -> U) -> U? {
        guard let x = self else {
            return nil
        }
        return transform(x)
    }
    
    // flapMap定义
    func flatMap<U>(f: (Wrapped) -> U?) -> U? {
        guard let x = self else {
            return nil
        }
        return f(x)
    }
}




