//
//  FunctionalThinkingController.swift
//  FunctionalSwift
//
//  Created by Abj on 2017/12/25.
//  Copyright © 2017年 Abj. All rights reserved.
//

import UIKit

/*   第一章： 函数式思想
 *   q: 判断一个给定的点是否在射程范围内，并且距离友方船舶和我们自身船都不太近
 *   issues: https://github.com/objcio/functional-swift/issues/128
 *   (个人默认为友方船和己方船只unsafeRange一样,所以未对此修改)
 */
typealias Distance = Double

struct Position {
    var x: Double
    var y: Double
}

struct Ship {
    /// 所在位置
    var position: Position
    
    /// 火力范围
    var firingRange: Distance
    
    /// 危险范围
    var unsafeRange: Distance
}

extension Position {
    /// 计算两个点之间横纵坐标差值并得到该他们差值的坐标
    func minus(p: Position) -> Position {
        return Position(x: x - p.x, y: y - p.y)
    }
    
    /// 离原点的长度
    var length: Double {
        return sqrt(x * x + y * y)
    }
    
    /// 该坐标是否在范围内
    func inRange(range: Distance) -> Bool {
        return sqrt(x * x + y * y) <= range
    }
}

/*
 extension Ship {
 func canEngageShip(target: Ship, friendly: Ship) -> Bool {
 let targetDistance = target.position.minus(p: position).length
 let friendlyDistance = friendly.position.minus(p: position).length
 return targetDistance <= firingRange && targetDistance >= unsafeRange && (friendlyDistance > unsafeRange)
 }
 }
 */

/*  问题根本: 判断一个点是否在范围内
 *  -> func pointInRange(Point: Position) -> Bool {
 // 方法的具体实现
 }
 */
typealias Region = (Position) -> Bool

/// 以原点为圆心的圆
func circle(radius: Distance) -> Region {
    return { point in point.length <= radius }
}

/// 不以原点为圆心的圆
func circle2(radius: Distance, center: Position) -> Region {
    return { point in point.minus(p: point).length <= radius }
}

/// 可能我们会有不同的图形(不只是圆形,还有矩形啥的)
/// 编写 区域变换函数
/// eg: 一个圆心为(5,5)半径为10的圆
/// shift(region: circle(radius: 10), offset: Position(x: 5, y: 5))
func shift(region: @escaping Region, offset: Position) -> Region {
    return { point in region(point.minus(p: offset)) }
}

/// 反转一个区域来定义另一个区域(区域外的所有点所组成)
func invert(region: @escaping Region) -> Region {
    return { point in !region(point) }
}

/// 两个区域的交集
func intersection(region1: @escaping Region, _ region2: @escaping Region) -> Region {
    return { point in region1(point) && region2(point) }
}

/// 两个区域的并集
func union(region1: @escaping Region, _ region2: @escaping Region) -> Region {
    return { point in region1(point) || region2(point) }
}

/// 在第一区域内且不再第二区域内的点构成一个区域
func difference(region: @escaping Region, minus: @escaping Region) -> Region {
    return intersection(region1: region, invert(region: minus))
}

extension Ship {
    func canSafelyEngageShip(target: Ship, friendly: Ship) -> Bool {
        let rangeRegion = difference(region: circle(radius: firingRange), minus: circle(radius: unsafeRange))
        let firingRegion = shift(region: rangeRegion, offset: position)
        let friendlyRegion = shift(region: circle(radius: unsafeRange), offset: friendly.position)
        let resultRegion = difference(region: firingRegion, minus: friendlyRegion)
        return resultRegion(target.position)
    }
}


class FunctionalThinkingController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
