//
//  EnumViewController.swift
//  FunctionalSwift
//
//  Created by Abj on 2018/1/9.
//  Copyright © 2018年 Abj. All rights reserved.
//

import UIKit

/*  第7章 枚举
 *  在这一章，我们会介绍Swift中的枚举类型。
 *  借此，你可以创建更为严密的类型来表示应用中使用的数据。
 */

// 每一种编码都可以用一个数字来表示，enum关键字允许开发者为整数常量指派一些有意义的名字，以此来关联特定的字符编码。
// 在OC和其他类C语言中，枚举的声明是有一些缺陷的。
// 最需要注意的是，NSStringEncoding作为类型来说并不够严密--有些整数，比如16，并没有一个与之对应的合法编码。
// 最糟糕的是，正因为所有的枚举类型实际上都是整数，它们之间是可以进行运算的，就好像它们只是数字一样。

/*
typedef NSUInteger NSStringEncoding;
NS_ENUM(NSStringEncoding) {
    NSASCIIStringEncoding = 1,        
    NSNEXTSTEPStringEncoding = 2,
    NSJapaneseEUCStringEncoding = 3,
    NSUTF8StringEncoding = 4
}
*/
/*
 谁能想到NSASCIIStringEncoding + NSNEXTSTEPStringEncoding会等于NSJapaneseEUCStringEncoding呢？
 NSAssert(NSASCIIStringEncoding + NSNEXTSTEPStringEncoding == NSJapaneseEUCStringEncoding, @"Adds up...");
*/

// Swift函数式编程中的一条核心原则:高效地利用类型排除程序缺陷。
// Swift也有一种enum的构造方式，不过其用法与OC语法相距甚远,并与整数或者其他已经存在的类型没有关系。
// Encoding类型包含有四个可能值:ASCII、NEXTSTEP、JapaneseEUC、UTF8
// 我们将这些可能值视为枚举的成员值，也可以简称成员。
enum Encoding {
    case ASCII
    case NEXTSTEP
    case JapaneseEUC
    case UTF8
}

// 回过头看第4章中的populationOfCapital函数
// 它用来查找一个国家的首都，如果找到，则它会返回该城市的人口总数。
// 这个函数的返回类型是一个整数类型的可选值:如果所有信息都被找到，则返回人口数；否则，返回nil
// 使用Swift的可选值时有一个缺点：当有错误发生时，我们无法返回相关的信息，所以也无从判定到底是哪里错了。
// 所以我们会更希望populationOfCapital函数返回一个Int或者一个ErrorType。
// 与Encoding枚举相比，PopulationResult的成员是带有关联值的。它只有两个可能的成员值：Success和Error
// 每一个成员值都携带了额外信息:Success关联一个整数值，对应着国家首都的人口数；而Error则关联了一个ErrorType。

enum LookupError: Error {
    case CapitalNotFound
    case PopulationNotFound
}

enum PopulationResult {
    case Success(Int)
    case Error(LookupError)
}

// 这里的nsStringEncoding属性映射了每一个Encoding条件下对应的String.Encoding值。
extension Encoding {
    var nsStringEncoding: String.Encoding {
        switch self {
        case .ASCII:
            return String.Encoding.ascii
        case .NEXTSTEP:
            return String.Encoding.nextstep
        case .JapaneseEUC:
            return String.Encoding.japaneseEUC
        case .UTF8:
            return String.Encoding.utf8
        }
    }
}

// 当然我们也可以定义一个函数实现相反的功能，即根据String.Encoding来创建一个Encoding
// 由于这个精简版的Encoding枚举并没有列举所有可能的String.Encoding值，所以该构造方法是可失败的。
extension Encoding {
    init?(enc: String.Encoding) {
        switch enc {
        case String.Encoding.ascii: self = .ASCII
        case String.Encoding.nextstep: self = .NEXTSTEP
        case String.Encoding.japaneseEUC: self = .JapaneseEUC
        case String.Encoding.utf8: self = .UTF8
        default: return nil
        }
    }
}

// 某个编码的本地化名称
func localizedEncodingName(encoding: Encoding) -> String {
    return .localizedName(of: encoding.nsStringEncoding)
}



class EnumViewController: UIViewController {

    // 存储欧洲的几个城市人口数量的字典
    let cities = ["Paris": 2241, "Madrid": 3165, "Amsterdam": 827, "Berlin": 3562]
    
    // 国家和其首都相关联
    let capitals = ["France" : "Paris",
                    "Spain" : "Madrid",
                    "The Netherlands" : "Amsterdam",
                    "Belgium" : "Brussels"]

    // 国家首都和市长关联
    let mayors = ["Paris" : "Hidalgo",
                  "Madrid" : "Carmena",
                  "Amsterdam" : "van der Laan",
                  "Berlin" : "Muller"]
    
    // 首先检查capitals字典中是否存在对应的首都名，如果不存在，就返回一个.CapitalNotFound错误
    // 接着验证cities字典中是否存在对应的人口数，如果不存在，则返回一个.PopulationNotFound错误。
    // 最后如果两次查询都找到了对应的值，便返回一个Success
    func populationOfCapital(countray: String) -> PopulationResult {
        guard let capital = capitals[countray] else {
            return .Error(.CapitalNotFound)
        }
        guard let population = cities[capital] else {
            return .Error(.PopulationNotFound)
        }
        return .Success(population)
    }
    
    // 简单地查询一个国家的首都
    func mayorOfCapital(country: String) -> String? {
        return capitals[country].flatMap { mayors[$0] }
    }
    
    // 然而，使用可选值作为返回类型时，依旧不会告诉我们为什么会查询失败
    // 所以立即想到了枚举来解决
    enum MayorResult {
        case Success(String)
        case Error(Error)
    }
    
    // 但是这并不是一个好的设计,我们应该使用更为严密的类型来避免类似的类型编码转换编写额外的代码
    // 所以我们定义一个新枚举,将泛型作为Success的关联值
    enum Result<T> {
        case Success(T)
        case Error(Error)
        
        // 可选值类型提供了一些语法糖，像是后缀标记？以及可选值的展开机制等，使其更容易被使用。
        // 我们试着来定义这些操作
        // 我们可以在我们自己的Result类型中定义一些用于操作可选值的函数
        // 通过在Result中重新定义？？运算符，我们可以对Result进行运算
        static func ??<T>(result: Result<T>, handleError: (Error) -> T) -> T {
            switch result {
            case let .Success(value):
                return value
            case let .Error(error):
                return handleError(error)
            }
        }
    }
    
    // func populationOfCapital(country: String) -> Result<Int>
    // func mayorCapital(country: String) -> Result<String>
    
    // Swift内建的错误处理机制与我们上文定义的Result类型十分相似.
    // 不同主要有两点:Swift强制你注明那些代码可能抛出错误，并且必须使用try或try的变体来调用这些代码。
    // 如果换作Result类型，则我们是无法在静态环境下确保错误被处理的。
    // 另外，Swift内建的错误处理机制的局限性在于，它必须借助函数的返回类型来触发:如果我们想构建一个函数，且提供这个参数，会让一切变得复杂起来。若是换用可选值或Result，则函数编写起来就没有那么繁琐，处理也会更加简单
    func populationOfCapital1(country: String) throws -> Int {
        guard let capital = capitals[country] else {
            throw LookupError.CapitalNotFound
        }
        guard let population = cities[capital] else {
            throw LookupError.PopulationNotFound
        }
        return population
    }
    
    // Swift内建的可选值类型与Result类型很像
    enum Optional<T> {
        case None
        case Some(T)
        // ...
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "枚举"
        
        // 编译器不支持
        // let myEncoding = Encoding.ASCII + Encoding.UTF8
        let _: PopulationResult = .Success(1000)
        
        switch populationOfCapital(countray: "France") {
        case let .Success(population):
            print("France is capital has \(population) thousand inhabitants")

        case let .Error(error):
            print("Error: \(error)")
        }
        // print: France is capital has 2241 thousand inhabitants
        
        do {
            let population = try populationOfCapital1(country: "France")
            print("France is population is \(population)")
        } catch {
            print("Lookup error: \(error)")
        }
    }
}

extension EnumViewController {
    // 枚举也常常被称为"和类型"
    // 使用枚举和多元祖定义的类型有时候也被称作代数数据类型，因为它们就像自然数一样，具有代数学结构
    // 同构:如果两个类型A和B在相互转换时不会丢失任何信息，那么它们就是同构的.
    // 就像命名表达一样,Add枚举是T与U的成员相加之和:如果T有三个成员，而U又七个成员，那么Add<T, U>就会有是个可能的成员。
    enum Add<T, U> {
        case InLeft(T)
        case IntRight(U)
    }
    
    // 在算术中，0是加法的运算单元如x + 0 和 x 一样
    // swift允许我们这样定义一个这样的结构体
    // zero这个枚举和算术中的0有这相似的功能，对于任何一个类型T，Add<T, Zero>和T是同构的。
    enum zero { }
    
    // 我们再尝试下乘法
    // T:包含三个成员 U:包含两个成员
    // 我们定义一个混合类型Times<T, U>， 使其包含六个成员
    // 同时选择一个T成员和yigeU成员
    struct Times<T, U> {
        let fst: T
        let snd: U
    }
    
    // 空类型()也作为yigeTimes(乘法)的单元
    typealias One = ()
    
    // Times<One, T> 与 T是同构的
    // Times<Zero, T> 与 Zero是同构的
    // Times<T, U> 与 Times<U, T>是同构的
}
