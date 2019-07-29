//
//  ObservableViewController.swift
//  RxPractice
//
//  Created by 李凯 on 2019/7/22.
//  Copyright © 2019 LK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/* ⚠️
observable related demos, including observale creating, subscribe, dispose
 */

enum FileReadError: Error {
    case fileNotFound, unreadable, encodingFailed
}

typealias completionHandlerBlock = () -> Void

var completionHandlers: [completionHandlerBlock] = []

class ObservableViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        deferred()
        
//        sourceMap { (res) in
//            print(res)
//        }
        
//        let instance = SomeClass()
//        instance.doSomething()
//        print(instance.x)
        
//        completionHandlers.first?()
//        print(instance.x)
        
//        loadText(from: "text").subscribe(onSuccess: { str in
//            print(str)
//        }) { error in
//            print(error)
//        }.disposed(by: disposeBag)
        
        
        practiceDebug()
        
        
//        practiceDo()
        
        
    }
    
    func sourceMap(block: @escaping (_ result: Int) -> Void) {
        print("当前线程\(Thread.current)")
        block(23)
        print("闭包执行结束")
    }

}

extension ObservableViewController {
    
    // deferred
    func deferred() {
        var flip = false
        
        let factory: Observable<Int> = Observable.deferred {
            flip = !flip
            
            if flip {
                return Observable.of(1,2,3)
            } else {
                return Observable.of(4,5,6)
            }
        }
        
        for _ in 0...3 {
            factory.subscribe(onNext: { element in
                print(element, terminator: "")
            }, onError: { error in
                print(error)
            })
                .disposed(by: disposeBag)
        }
    }
    
    // single: emit either a .success(value) or .error event. .success(value) is actually a combination of the .next and .completed events. This is useful for one-time processes that will either succeed and yield a value or fail, such as downloading data or loading it from disk
    
    func loadText(from name: String) -> Single<String> {
        
        return Single.create { single in
            
            let disposable = Disposables.create()
            
            guard let path = Bundle.main.path(forResource: name, ofType: "txt") else {
                single(.error(FileReadError.fileNotFound))
                return disposable
            }
            
            guard let data = FileManager.default.contents(atPath: path) else {
                single(.error(FileReadError.unreadable))
                return disposable
            }
            
            guard let contents = String(data: data, encoding: .utf8) else {
                single(.error(FileReadError.encodingFailed))
                return disposable
            }
            
            single(.success(contents))
            return disposable
            
        }
    }

    
    // do: 用来查看observable的生命周期 (do先于subscribe打印)
    func practiceDo() {
        Observable.of([1, 2, 3])
            .do(onNext: { _ in
                print("before next")
            }, afterNext: { _ in
                print("after next")
            }, onError: { _ in
                print("before error")
            }, afterError: { _ in
                print("after error")
            }, onCompleted: {
                print("before completed")
            }, afterCompleted: {
                print("after completed")
            }, onSubscribe: {
                print("do subscribe")
            }, onSubscribed: {
                print("do subscribed")
            }) {
                print("do dispose")
            }
            .subscribe { event in
                switch event {
                case .next(let element):
                    print(element)
                case .error(let error):
                    print(error)
                case .completed:
                    print("completed")
                }
            }
            .disposed(by: disposeBag)
    }
    
    // debug 用于调试: 将observable被订阅的详细信息打印出来
    func practiceDebug() {
        
        Observable.of("2", "3")
            .startWith("1")
            .debug("调试1")
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
}

/// 测试闭包用
class SomeClass {
    var x = 10
    
    func doSomething() {
//        someFuncWithEscapingClousure {
//            self.x = 200
//        }
        
        someFuncWithNonEscapingClousure {
            x = 200
        }
    }
    
    func someFuncWithEscapingClousure(completionHandler: @escaping completionHandlerBlock) {
        completionHandlers.append(completionHandler)
        print("逃逸闭包函数执行完毕")
    }
    
    func someFuncWithNonEscapingClousure(completionHandler: completionHandlerBlock) {
//        completionHandlers.append(completionHandler)
        completionHandler()
        print("非逃逸闭包函数执行完毕")
    }
}
