//
//  UIViewController.swift
//  Combinestagram
//
//  Created by 李凯 on 2019/7/30.
//  Copyright © 2019 LK. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

extension UIViewController {
    
    // Completable 只发出一个completed事件 或者一个error事件
    // 这里是一个completed事件
    func showAlert(_ title: String, _ message: String?) -> Completable {
        return Completable.create { completable in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "Close", style: .cancel, handler: { action in
                completable(.completed)
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return Disposables.create {
                print("alert销毁")
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
