//
//  ViewController.swift
//  FilteringOperators
//
//  Created by 李凯 on 2019/7/31.
//  Copyright © 2019 LK. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

enum CustomError: Error {
    case ignoreElementsError
}

/*
 Filtering Operators:
 
 1. ignoreElements
 2. elementAt
 3. filter
 4. skip
    4.1 skipWhile
    4.2 skipUntil
 5. take
    5.1 takeWhile
    5.2 takeUntil
 6. distinctUntilChanged
 
 */

class ViewController: UIViewController {
    
    let strikes = PublishSubject<String>()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        ignoreElemets()
//        elementAt()
//        filter()
//        skip()
//        skipWhile()
//        skipUntil()
        take()
//        takeWhile()
//        takeUntil()
//        distinctUntilChanged()
//        distinctUntilChangedWithComparer()
        
    }

}

extension ViewController {
    
    // ignoreElements
    // ⚠️忽略所有.next事件
    func ignoreElemets() {
        strikes
            // 转成一个Completable
            .ignoreElements()
            // 因此只会发出completed 或者 error事件
            .subscribe(onCompleted: {
                print("you are out")
            }) { error in
                print(error.localizedDescription)
            }
            .disposed(by: disposeBag)
        
        strikes.onNext("x")
        strikes.onNext("y")
        strikes.onNext("z")
//        strikes.onError(CustomError.ignoreElementsError)
        strikes.onCompleted()
    }
    
    
    // elementAt
    // ⚠️只发出指定索引的.next事件
    func elementAt() {
        strikes
            .elementAt(2)
            .subscribe(onNext: { str in
                print("you are out at \(str)")
            })
            .disposed(by: disposeBag)
        
        strikes.onNext("0")
        strikes.onNext("1")
        strikes.onNext("2")
    }
    
    // filter
    //  ⚠️Filter takes a predicate closure, which it applies to each element, allowing through only those elements for which the predicate resolves to true
    func filter() {
        Observable.of(1, 2, 3, 4, 5, 6)
            .filter { $0 % 2 == 0 }
            .subscribe(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)
    }
    
    
    // skip
    // ⚠️The skip operator allows you to ignore from the 1st to the number you pass as its parameter.
    func skip() {
        Observable.of("a", "b", "c", "d", "e", "f")
            .skip(3)
            .subscribe(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)
    }
    
    // skipWhile
    // ⚠️将符合条件的元素skip掉, 直到不符合条件的元素出现(即skip不掉的元素出现) 往后的所有元素 都发出 skipWhile will only skip up until something is not skipped, and then it will let everything else through from that point on
    func skipWhile() {
        Observable.of(2, 2, 3, 4, 4)
            .skipWhile { $0 % 2 == 0 }
            .subscribe(onNext: { element in
                print(element)
            })
            .disposed(by: disposeBag)
    }
    
    // skipUntil
    // ⚠️When trigger emits, skipUntil will stop skipping
    func skipUntil() {
        let subject = PublishSubject<String>()
        let trigger = PublishSubject<String>()
        
        subject
            .skipUntil(trigger)
            .subscribe(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)
        
        subject.onNext("a")
        subject.onNext("b")
        trigger.onNext("x")
        subject.onNext("c")
    }
    
    
    // take
    // ⚠️opposite of skipping. will take the first of the number of elements you specified
    func take() {
        Observable.of(1, 2, 3, 4, 5, 6)
            .take(3)
            .subscribe(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)
    }
    
    // takeWhile
    // ⚠️与skipWhile语义相反
    func takeWhile() {
        Observable.of(2, 2, 4, 4, 6, 6)
            // ⚠️返回元素以及元素对应索引的tuple
            .enumerated()
            .takeWhile({ index, element -> Bool in
                return element % 2 == 0 && index < 3
            })
            // ⚠️从符合条件的tuple中map出对应的element
            .map { $0.element }
            .subscribe(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)
    }
    
    // takeUntil
    // ⚠️与skipUntil语义相反
    func takeUntil() {
        let subject = PublishSubject<String>()
        let trigger = PublishSubject<String>()
        
        subject
            .takeUntil(trigger)
            .subscribe(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)
        
        subject.onNext("1")
        subject.onNext("2")
        trigger.onNext("x")
        subject.onNext("3")
    }
    
    
    // distinctUntilChanged
    // ⚠️distinctUntilChanged only prevents duplicates that are right next to each other
    func distinctUntilChanged() {
        Observable.of("a", "a", "b", "b", "a")
            .distinctUntilChanged()
            .subscribe(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)
    }
    
    func distinctUntilChangedWithComparer() {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        Observable<NSNumber>.of(10, 110, 20, 200, 210, 310)
            .distinctUntilChanged { (a, b) -> Bool in
                guard let aWords = formatter.string(from: a)?.components(separatedBy: " "), let bWords = formatter.string(from: b)?.components(separatedBy: " ") else {
                    return false
                }
                
                var containMatch = false
                
                for aWord in aWords {
                    for bWord in bWords {
                        if aWord == bWord {
                            containMatch = true
                            break
                        }
                    }
                }
                return containMatch
            }
            .subscribe(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)
    }
    
}

