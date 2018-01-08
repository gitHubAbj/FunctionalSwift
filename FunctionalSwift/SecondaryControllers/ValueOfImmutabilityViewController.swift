//
//  ValueOfImmutabilityViewController.swift
//  FunctionalSwift
//
//  Created by Abj on 2018/1/6.
//  Copyright © 2018年 Abj. All rights reserved.
//

import UIKit

/*  第6章 不可变性的价值
 *  Swift中有几个可以控制值的变化方式的机制.
 *  本章会介绍这些不同的机制是如何工作的,以及如何区别值类型和引用类型,并证明为什么限制可变状态的使用是一个良好的理念.
 */

// 不可变性不止存在于变量声明中.
// Swift的类型分为值类型和引用类型.
// 两者最典型的例子分别为结构体和类.
// 值类型与引用类型之间的关键区别: 当被赋以一个新值或是作为一个参数传递给函数时,值类型会被复制.
// Swift几乎所有类型都是值类型,包括数组、字典、数值、布尔值、元祖和枚举,只有类是例外的。

struct PointStruct {
    var x: Int
    var y: Int
}

class PointClass {
    var x: Int
    var y: Int
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

struct ImmutablePointStruce {
    let x: Int
    let y: Int
}

func setStructToOrigin(point: PointStruct) -> PointStruct {
    var tmpPoint = point
    tmpPoint.x = 0
    tmpPoint.y = 0
    return tmpPoint
}

func setClassToOrigin(point: PointClass) -> PointClass {
    point.x = 0
    point.y = 0
    return point
}

class ValueOfImmutabilityViewController: UIViewController {

    // 使用let声明的变量被称为不可变量,而使用var声明的变量则被称为可变变量.
    // 使用let声明的变量无法被改变
    var x: Int = 1
    let y: Int = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "不可变性的价值"

        x = 3  // 没问题
        // y = 4  // 被编译器拒绝
        
        var structPoint = PointStruct(x: 1, y: 2)
        var sameStructPoint = structPoint
        sameStructPoint.x = 3
        print("structPoint.x = \(structPoint.x), sameStructPoint.x = \(sameStructPoint.x)")
        // structPoint.x = 1
        // sameStructPoint.x = 3
        
        
        // 类是引用类型
        var classPoint = PointClass(x: 1, y: 2)
        var sameClassPoint = classPoint
        sameClassPoint.x = 3
        print("classPoint.x = \(classPoint.x), sameClassPoint.x = \(sameClassPoint.x)")
        // classPoint.x = 3
        // sameClassPoint.x = 3

        // 当被赋以一个新变量或传递给函数时,值类型总是会被复制,而引用类型并不会被复制.
        var structOrigin: PointStruct = setStructToOrigin(point: structPoint)
        print("structOrigin = \(structOrigin), structPoint = \(structPoint)")
        // structOrigin = PointStruct(x: 0, y: 0), structPoint = PointStruct(x: 1, y: 2)

        var classOrigin = setClassToOrigin(point: classPoint)
        print("classOrigin.x = \(classOrigin.x), classPoint.x = \(classPoint.x)")
        // classOrigin.x = 0, classPoint.x = 0
        
        let immutablePoint = PointStruct(x: 0, y: 0)
        // immutablePoint = PointStruct(x: 1, y: 1) // 被拒绝
        // immutablePoint.x = 3  // 被拒绝
        
        var mutablePoint = PointStruct(x: 1, y: 1)
        mutablePoint.x = 3
        print(mutablePoint)
        // mutablePoint.x = 3
        
        var immutablePoint2 = ImmutablePointStruce(x: 1, y: 1)
        // immutablePoint.x = 3 // 被拒绝
        print(immutablePoint2)

        immutablePoint2 = ImmutablePointStruce(x: 2, y: 2)
        print(immutablePoint2)
        
    }

}
