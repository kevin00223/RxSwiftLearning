//
//  TraitsSequence.swift
//  RxPractice
//
//  Created by 李凯 on 2019/7/30.
//  Copyright © 2019 LK. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/*
 特征(Traits)序列: Single, Maybe, Completable
 */


//与数据相关的错误类型
enum DataError: Error {
    case cantParseJSON
}

enum StringError: Error {
    case failedGenerated
}

enum CacheError: Error {
    case failedCaching
}

class TraitSequence: UIViewController {
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //single
        getPlayList("0")
            .subscribe(onSuccess: { json in
                print("json的结果是\(json)")
            }) { error in
                print("发送错误\(error)")
            }
            .disposed(by: disposeBag)
        
        //maybe
        generateString()
            .subscribe(onSuccess: { str in
                print("执行完毕, 获得元素\(str)")
            }, onError: { error in
                print("执行失败: \(error.localizedDescription)")
            }) {
                print("执行完毕, 且没有获得任何元素")
            }
            .disposed(by: disposeBag)
        
        //completable
        cacheLocally()
            .subscribe(onCompleted: {
                print("done")
            }) { (error) in
                print("缓存出错\(error)")
            }
            .disposed(by: disposeBag)
        
    }
}

extension TraitSequence {
    // Single
    // 1. 只能发出一个success事件(包括.next + .completed), 或者一个error事件(.error)
    // 2. 适用于下载/保存文件的操作, 成功就把文件相关信息(如文件ID)通过success事件发送给订阅者, 失败就发送一个error事件
    func getPlayList(_ channel: String) -> Single<[String : Any]> {
        return Single<[String : Any]>.create { single in
            let url = "https://douban.fm/j/mine/playlist?"
                + "type=n&channel=\(channel)&from=mainsite"
            let task = URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { (data, _, error) in
                if let error = error {
                    single(.error(error))
                    return
                }
                
                if let data = data {
                    let json = try? JSONSerialization.jsonObject(with: data,
                                                                 options: .mutableLeaves)
                    guard let result = json as? [String: Any] else {
                        single(.error(DataError.cantParseJSON))
                        return
                    }
                    single(.success(result))
                }
            })
            task.resume()
            return Disposables.create()
        }
    }
    
    
    // Maybe
    // 1. 只能发出一个event, 要么是一个.next, 要么是completed, 要么是error
    func generateString() -> Maybe<String> {
        return Maybe.create { maybe in
            // 发出一个元素
            maybe(.success("成功"))
            // 不发出元素, 而是一个completed事件
//            maybe(.completed)
            // 不发出元素, 而是一个error事件
//            maybe(.error(StringError.failedGenerated))
            
            return Disposables.create()
        }
    }
    
    
    // Completable
    // 1.只能发出一个completed 或者一个error
    // 2.适用于只关心任务是否完成 不关心任务返回值的情况
    func cacheLocally() -> Completable {
        return Completable.create { completable in
            let success = (arc4random() % 2 == 0)
            
            if success {
                completable(.completed)
            }else{
                completable(.error(CacheError.failedCaching))
            }
            return Disposables.create()
        }
    }
}
