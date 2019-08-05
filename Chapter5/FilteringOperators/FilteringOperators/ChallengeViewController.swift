//
//  ChallengeViewController.swift
//  FilteringOperators
//
//  Created by 李凯 on 2019/7/31.
//  Copyright © 2019 LK. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ChallengeViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let contacts = [
        "603-555-1212": "Florent",
        "212-555-1212": "Junior",
        "408-555-1212": "Marin",
        "617-555-1212": "Scott"
    ]
    let input = PublishSubject<Int>()

    override func viewDidLoad() {
        super.viewDidLoad()

        input
            // 保证不以0开头
            .skipWhile { $0 == 0 }
            // 每次传入的值要小于10
            .filter { $0 < 10 }
            // 取10个数字
            .take(10)
            // 返回一个Single
            .toArray()
            .subscribe(onSuccess: { number in
                let phone = self.phoneNumber(from: number)
                if let contact = self.contacts[phone] {
                    print("Dialing \(contact) (\(phone))...")
                } else {
                    print("Contact not found")
                }
            }) { error in
                print(error.localizedDescription)
            }
            .disposed(by: disposeBag)
        
        input.onNext(0)
        input.onNext(2)
        input.onNext(1)
        input.onNext(2)
        input.onNext(603)
        "5551212".forEach {
            if let number = (Int("\($0)")) {
                input.onNext(number)
            }
        }
    }
    
    
    // 将int数组转成字符串
    func phoneNumber(from inputs: [Int]) -> String {
        var ph = inputs.map { element -> String in
            return String(element)
        }
        var phone = inputs.map(String.init).joined()
        print(ph, phone)
        
        phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 3)
        )
        
        phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 7)
        )
        return phone
    }
}
