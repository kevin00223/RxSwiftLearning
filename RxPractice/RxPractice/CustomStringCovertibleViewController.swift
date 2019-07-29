//
//  CustomStringCovertibleViewController.swift
//  RxPractice
//
//  Created by 李凯 on 2019/7/25.
//  Copyright © 2019 LK. All rights reserved.
//

import UIKit

/*
 ⚠️ Swift标准库协议--CustomStringConvertible协议的应用
 */

struct Person: CustomStringConvertible {
    // ⚠️ struct的属性:
    // 1. 可以只显示属性的类型 因为struct提供了默认的memberwise initializer
    // 2. 且类型不能是可选型, 因为可选意味着属性可能有值 也可能为空, 而struct的属性不能为空
    var age: Int
    var name: String
    var job: String
    
    // 遵守CustomStringConvertible协议后, 需要定制description
    var description: String {
        return "\(name) \(age) \(job)"
    }
    
}

class CustomStringCovertibleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // 🌰1: CustomStringConvertible在struct中的应用
        let person = Person(age: 25, name: "kevin", job: "iOSer")
        // 1. 未遵守协议的结果: Person(age: 25, name: "kevin", job: "iOSer")
        // 2. 遵守协议的结果: kevin 25 iOSer
        print(person)
        
        
        // 🌰2: CustomStringConvertible在class中的应用
        let wheel = Wheel(spokes: 36, diameter: 28)
        // 1. 未遵守协议的结果: RxPractice.Wheel
        // 2. 遵守协议(在Extension中)的结果: wheel has 36 spokes and 28.0 diameter
        print(wheel)
        
    }
}


class Wheel {
    // ⚠️ Class的属性 不能只显示所属类型, 必须让程序知道这个属性的值:
        // 1. 通过? 表示这个属性可能有值, 也可能是nil
        // 2. 通过! 表示这个属性肯定有值
        // 3. 通过赋初始值
        // 4. 通过自定义init方法, 通过外界设置值
    var spokes: Int
    var diameter: Double
    
    init(spokes: Int, diameter: Double) {
        self.spokes = spokes
        self.diameter = diameter
    }
}
// ⚠️ 对于Class, 在extension中遵守CustomStringConvertible协议
extension Wheel: CustomStringConvertible {
    var description: String {
        return "wheel has \(spokes) spokes and \(diameter) diameter"
    }
}


