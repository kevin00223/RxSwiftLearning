//
//  SubjectViewController.swift
//  RxPractice
//
//  Created by 李凯 on 2019/7/24.
//  Copyright © 2019 LK. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

/*
 subjects(which can act as both observables and observers) related demos, including PublishSubject,
 */

enum ProgramError: Error {
    case anError
}

class SubjectViewController: UIViewController {
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        publishSubjectDemo()
        
//        behaviorSubjectDemo()
        
//        replaySubjectDemo()
        
        variableDemo()
        
    }
}

extension SubjectViewController {
    
    // ⚠️PublishSubject demo
    /*
     订阅者只能收到订阅该observable之后, 该observable发出的event
     */
    func publishSubjectDemo() {
        let subject = PublishSubject<String>()
        subject.onNext("is anyone listening")
        let subscriptionOne = subject.subscribe(onNext: { str in
            print(str)
        })
        subject.on(.next("1")) // [打印 '1']
        subject.onNext("2") // [打印 '2']
        
        let subscriptionTwo = subject.subscribe{ event in
            print("2)", event.element ?? event)
        }
        subject.onNext("3") // [打印 '3' 和 '2) 3']
        
        subscriptionOne.dispose() //to terminate subscriptionOne, 因此subscriptionOne不会再收到event
        subject.onNext("4") // [打印 '2) 4']
        
        subject.onCompleted() // to terminate subject's observable sequence
        subject.onNext("5") // 接收一个新值 但由于subject的可观察序列已经被终止 因此新值不会发出
        subscriptionTwo.dispose() //to terminate subscriptionTwo: [打印'2) completed']
        subject.subscribe { print("3)", $0.element ?? $0) }.disposed(by: disposeBag) // 被终止的可观察序列又被订阅 此时会向订阅者发出stop event
        subject.onNext("?") // 任何类型的subject, 一旦被terminated 当接收到新值时 都会向订阅者发出stop event(.completed / .error)
    }
    
    
    
    // ⚠️ BehaviorSubject demo
    /*
     与PublishSubjects一样, 不同之处在于:
     1. BehaviorSubject会向订阅者发送订阅之前最后一次的event ('will replay the latest .next event to new subscribers')
     2. 初始化时 必须设置初始值
     */
    
    func printOut(label: String, event: Event<String>) {
        // label用来标记是第几个订阅者, 有element就打印 否则就打印error error也没有(即是completed事件)就打印event
        print(label, event.element ?? event.error ?? event as Any )
    }
    
    func behaviorSubjectDemo() {
        let subject = BehaviorSubject(value: "initial value")
        let disposeBag = DisposeBag()
        
        subject.onNext("X")
        
        subject.subscribe { event in
            self.printOut(label: "1)", event: event) // 打印: '1) X'
        }
        .disposed(by: disposeBag)
        
        subject.onError(ProgramError.anError) // 打印: '1) X'和'1) anError'
        
        subject.subscribe { event in
            self.printOut(label: "2)", event: event) // 打印: '1) X'和'1) anError'和'2) anError'
        }
        .disposed(by: disposeBag)
        
    }
    
    
    
    // ⚠️ ReplaySubject demo
    /*
     用来缓存指定的events, 在有新订阅者后 将缓存的events 发送给订阅者
        1. 由于缓存的events保存在内存中 因此过多的events可能会占用大量内存
     */
    func replaySubjectDemo() {
        let subject = ReplaySubject<String>.create(bufferSize: 2)
        let disposeBag = DisposeBag()
        
        subject.onNext("1")
        subject.onNext("2")
        subject.onNext("3")
        
        // 第一个订阅者
        subject.subscribe { event in
            self.printOut(label: "1)", event: event)
        }
        .disposed(by: disposeBag)
        
        // 第二个订阅者
        subject.subscribe { event in
            self.printOut(label: "2)", event: event)
        }
        .disposed(by: disposeBag)
        
        // observable接收一个next事件 并发出给订阅者
        subject.onNext("4")
        
        subject.onError(ProgramError.anError)
        
        subject.dispose()
        
        // 第三个订阅者
        subject.subscribe { event in
            self.printOut(label: "3)", event: event)
        }
        .disposed(by: disposeBag)
    }
    
    
    
    // ⚠️ Variable demo (Variable已过期 用BehaviorRelay代替)
    /*
     1. 是对BehaviorSubject的封装
     2. 通过value属性获取当前event的值, 并通过value属性向当前序列发送一个值(而不是通过onNext的方式)
     3. 不会发出error事件
     4. 通过asObservable先获取variable封装的subject对象, 再去订阅
     */
    
    func variableDemo() {
        let variable = Variable("initial value")
        let disposeBag = DisposeBag()
        
        // 不像其他subjects一样 通过onNext接收新值
        variable.value = "new initial value"
        variable.asObservable() //获取封装的behavior subject对象
            .subscribe { event in
                self.printOut(label: "1)", event: event)
            }
            .disposed(by: disposeBag)
        
        variable.value = "1"
        variable.asObservable()
            .subscribe { event in
                self.printOut(label: "2)", event: event)
        }
            .disposed(by: disposeBag)
        variable.value = "2"
    }
    
}
