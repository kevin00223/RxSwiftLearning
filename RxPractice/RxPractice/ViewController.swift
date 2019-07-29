//
//  ViewController.swift
//  RxPractice
//
//  Created by 李凯 on 2019/7/10.
//  Copyright © 2019 LK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum MyError: Error {
    case anError
}

class ViewController: UIViewController {
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        let textField = UITextField()
//        textField.rx.text.bind(to: <#T##ObserverType...##ObserverType#>)
        
        let observable = Observable.of(1, 2, 3)
        observable.subscribe { event in
            if let element = event.element {
                print(element)
            }
        }
        .disposed(by: disposeBag)


        let obs = Observable<Void>.empty()

        let ob = Observable<Void>.empty()
        ob.subscribe { event in
            print(event)
        }
        .disposed(by: disposeBag)
        
        
        Observable<String>.create { observer in
            // 1
            observer.onNext("1")
            // 2
//            observer.onError(MyError.anError)
            // 3
//            observer.onCompleted()
            // 4
            observer.onNext("?")
            // 5
            return Disposables.create()
            }.subscribe(onNext: { print($0)
            }, onError: { print($0)
            }, onCompleted: {
                print("completed")
            }) {
                print("disposed")
            }
//            .disposed(by: disposeBag)
        
        
    }
    
//    func exampleDeferred() {
//        let disposeBag = DisposeBag()
//        
//        var filp = false
//        
//        let factory: Observable<Int> = Observable.deferred { () -> Observable<_> in
//            <#code#>
//        }
//    }


}

