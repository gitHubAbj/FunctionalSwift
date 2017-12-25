//
//  CoreImagePackageController.swift
//  FunctionalSwift
//
//  Created by Abj on 2017/12/25.
//  Copyright © 2017年 Abj. All rights reserved.
//

import UIKit

/*   第2章： 案例研究: 封装Core Image
 *   Core Image的API是弱类型的--我们通过键值编码(KVC)来配置图像滤镜.
 *   在使用参数的类型或名字时,我们都使用字符串来进行表示,这就十分容易出错.
 *   q: 开发新API,利用类型来避免这些原因导致的运行时错误,得到一组类型安全而且高度模块化的API.
 */

/* CIFilter对象几乎都是通过kCIInputImageKey键提供输入对象
 * 再通过kCIOutputImageKey键取回处理后的对象
 * 取回的结果可以作为下一个滤镜的输入值.
 */
/// 滤镜类型
typealias Filter = (CIImage) -> CIImage

// https://github.com/apple/swift-evolution/blob/master/proposals/0077-operator-precedence.md
/// 重载运算符
precedencegroup  ComparisonPrecedence {
    associativity: left
    higherThan: LogicalConjunctionPrecedence
}

///定义运算符>>>为左结合
infix operator >>>: ComparisonPrecedence

/// 滤镜将以从左到右的顺序被应用到图像上
func >>> (filter1: @escaping Filter, filter2: @escaping Filter) -> Filter {
    return { image in filter2(filter1(image)) }
}

class CoreImagePackageController: UIViewController {
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    
    /// 模糊滤镜
    func blur(radius: Double) -> Filter {
        return { image in
            let parameters = [
                kCIInputRadiusKey : radius,
                kCIInputImageKey : image
                ] as [String : Any]
            guard let filter = CIFilter(name: "CIGaussianBlur", withInputParameters: parameters) else { fatalError() }
            guard let outputImage = filter.outputImage else { fatalError() }
            return outputImage
        }
    }
    
    /// 颜色生成滤镜
    func colorGenerator(color: UIColor) -> Filter {
        return {_ in
            let c = CIColor(color: color)
            let paramters = [kCIInputColorKey : c]
            guard let filter = CIFilter(name: "CIConstantColorGenerator", withInputParameters: paramters) else { fatalError() }
            guard let outputImage = filter.outputImage else { fatalError() }
            return outputImage
        }
    }
    
    /// 合成滤镜
    func compositeSourceOver(overlay: CIImage) -> Filter {
        return { image in
            let paramters = [
                kCIInputBackgroundImageKey : image,
                kCIInputImageKey : overlay
            ]
            guard let filter = CIFilter(name: "CISourceOverCompositing", withInputParameters: paramters) else { fatalError() }
            guard let outputImage = filter.outputImage else { fatalError() }
            
            // 设置输出的图像裁剪为输入图像一致的尺寸
            let cropRect = image.extent
            return outputImage.cropped(to: cropRect)
        }
    }
    
    /// 颜色叠层滤镜
    func colorOverlay(color: UIColor) -> Filter {
        return { image in
            // 获取由颜色滤镜生成的图片
            let overlay = self.colorGenerator(color: color)(image)
            // 再次对生成的图片通过合成滤镜合成
            return self.compositeSourceOver(overlay: overlay)(image)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "封装Core Image"
        /*
         * 组合滤镜(复合函数,可类比为数学上常用的f(g(x)))
         * 首先将图像模糊,然后再覆盖上一层灰色叠层.
         */
        
        //url对应的图片未找到
        //let url = URL(string: "http://www.objc.io/images/covers/16.jpg")!
        //let image = CIImage(contentsOf: url)
        
        let testImage = UIImage(named: "test.jpg")!
        let image = CIImage(image: testImage)
        let blurRadius = 5.0
        let overlayColor = UIColor.lightGray.withAlphaComponent(0.1)
        
        // 方案1:
        let blurredImage = blur(radius: blurRadius)(image!)
        let overlaidImage = colorOverlay(color: overlayColor)(blurredImage)
        imageView1.image = UIImage(ciImage: overlaidImage)
        
        
        // 方案2:
        /*
        let result = colorOverlay(color: overlayColor)(blur(radius: blurRadius)(image!))
        imageView2.image = UIImage(ciImage: result)
        */
        
        // 方案3:
        /*
        func composeFilters(filter1: @escaping Filter, _ filter2: @escaping Filter) -> Filter {
            return { image in filter2(filter1(image)) }
        }
        
        let myFilter1 = composeFilters(filter1: blur(radius: blurRadius), colorOverlay(color: overlayColor))
        let result1 = myFilter1(image!)
        imageView3.image = UIImage(ciImage: result1)
         */
        
        // 方案4: 运算符重载
        /*
        let myFilter2 = blur(radius: blurRadius) >>> colorOverlay(color: overlayColor)
        let result2 = myFilter2(image!)
        imageView4.image = UIImage(ciImage: result2)
        */
        
        print(add1(1, 2))  // log: 3
        print(add2(1)(2))  // log: 3
    }
}

extension CoreImagePackageController {
    /*
     *  柯里化: 如何将一个接受多参数的函数变换为一系列只接受单个参数的函数的过程
     */
    
    // 1: 常用函数
    func add1(_ x: Int, _ y: Int) -> Int {
        return x + y
    }
    
    // 2: 柯里化后的函数
    //func add2(_ x: Int) -> ((Int) -> Int) {
    //    return { y in
    //        return x + y
    //    }
    //}
    
    func add2(_ x: Int) -> (Int) -> Int {
        return { y in x + y }
    }
}

