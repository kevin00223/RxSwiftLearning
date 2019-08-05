//
//  MainViewController.swift
//  Combinestagram
//
//  Created by 李凯 on 2019/7/29.
//  Copyright © 2019 LK. All rights reserved.
//

/*
 本章(Chapter6)是在Chapter4的基础上进行开发
 */

/*
 涉及到的知识点
 Rx相关:
    1. publishSubject, Variable(BehaviorRelay), Observable
    2. single, completable
 
 其他:
    1.在固定大小的imageView上均匀展示多张图片 (UIImage的extension)
    2.利用原生Photos框架 将相册图片展示在自定义的collectionView中
    3.保存自定义图片到相册
    4.定义一个函数, 函数参数可以不传
 */

import UIKit
import RxSwift
import RxCocoa

class MainViewController: UIViewController {
    
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var itemAdd: UIBarButtonItem!
    
    private let disposeBag = DisposeBag()
    private let images = Variable<[UIImage]>([])
    
    var start = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 第一个订阅者: 订阅images, 显示图片
        images.asObservable()
            .subscribe(onNext: { [weak self] photos in
                self?.imagePreview.image = UIImage.collage(images: photos, size: (self?.imagePreview.frame.size)!)
            })
            .disposed(by: disposeBag)
        
        // 第二个订阅者: 订阅images, 更新UI
        images.asObservable()
            .subscribe(onNext: { [weak self] photos in
                self?.updateUI(photos: photos)
            })
            .disposed(by: disposeBag)
        
        multiSubscribeToTheSameObservableTest()
        
//        shareTest()
    }
    
    private func updateUI(photos: [UIImage]) {
        // 有图片, 且图片数量是偶数时, [save]按钮才可点击
        saveButton.isEnabled = photos.count > 0 && photos.count % 2 == 0
        // 有图片, [clear]按钮才可点击
        clearButton.isEnabled = photos.count > 0
        // 图片不多于6张 [+]按钮才可点击
        itemAdd.isEnabled = photos.count < 6
        // 设置标题
        title = photos.count > 0 ? "\(photos.count) photos" : "Collage"
    }
    
    @IBAction func actionClear() {
        // 清空数组
        images.value = []
    }
    
    @IBAction func actionSave() {
        guard let image = imagePreview.image else { return }
        //Observable转Single版本
//        PhotoWriter.save(image)
//            // 转成single, 只发出success/error事件
//            .asSingle()
//            .subscribe(onSuccess: { [weak self] id in
//                print("saved with id: \(id)")
//                self?.actionClear()
//            }) { error in
//                print("错误: \(error.localizedDescription)")
//            }
//            .disposed(by: disposeBag)
        
        //Single版本
        PhotoWriter.keep(image)
            .subscribe(onSuccess: { [weak self] id in
                self?.showMessage("Saved", description: id)
                self?.actionClear()
            }) { error in
                self.showMessage(error.localizedDescription)
            }
            .disposed(by: disposeBag)
    }
    
    @IBAction func actionAdd() {
//        images.value.append(UIImage(named: "IMG_1907.jpg")!)
        let photosViewController = storyboard!.instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController
        
        // 在控制器跳转之前, 对selectedPhotos这个可观察序列进行订阅
//        photosViewController.selectedPhotos
            let newPhotos = photosViewController.selectedPhotos.share()
            newPhotos.subscribe(onNext: { [weak self] newImage in
                guard let images = self?.images else { return }
                images.value.append(newImage)
            }) {
                print("completed photo selection")
            }
            .disposed(by: disposeBag)
        
        navigationController?.pushViewController(photosViewController, animated: true)
        
    }
    
    // 封装一个showMessage方法 其中参数description可以不传
    func showMessage(_ title: String, description: String? = nil) {
        showAlert(title, description)
            // 由于是Completable 只会发出一个completed或者一个error事件 (本例中是completed) 所以这里不用对事件做处理
            .subscribe()
            .disposed(by: disposeBag)
    }
    
}

extension MainViewController {
    
    /// 对同一个Observable进行多次subscribe的测试
    ///
    /// 说明: 每次subscribe, Observable都会执行create方法 即每次订阅 都会创建新的可观察序列, 因此导致每次订阅的结果可能不一样 (即便每次订阅的结果是一样的, 多次对同一个Observable进行订阅也是没必要的)
    func multiSubscribeToTheSameObservableTest() {
        let numbers = Observable<Int>.create { observer -> Disposable in
            let start = self.getStartNumber()
            observer.onNext(start)
            observer.onNext(start+1)
            observer.onNext(start+2)
            observer.onCompleted()
            return Disposables.create()
        }
        
        numbers.subscribe(onNext: { element in
            print("element \(element)")
        }, onCompleted: {
            print("-----")
        })
            .disposed(by: disposeBag)
        /*
         打印结果:
         element 1
         element 2
         element 3
         -----
         */
        
        
        numbers.subscribe(onNext: { element in
            print("element \(element)")
        }, onCompleted: {
            print("-----")
        })
            .disposed(by: disposeBag)
        /*
         打印结果:
         element 2
         element 3
         element 4
         -----
         */
    }
    
    func getStartNumber() -> Int {
        start += 1
        return start
    }
}

extension MainViewController {
    /// share操作符demo
    func shareTest() {
        let sequenceOfInts = PublishSubject<Int>()
        let a = sequenceOfInts.map{ i -> Int in
            print("MAP---\(i)")
            return i * 2
        }.shareReplay(3)
        
        let b = a.subscribe(onNext: { ele in
            print("--1--\(ele)")
        })

        sequenceOfInts.on(.next(1))
        sequenceOfInts.on(.next(2))
        
        let c = a.subscribe(onNext: { ele in
            print("--2--\(ele)")
        })

        sequenceOfInts.on(.next(3))
        sequenceOfInts.on(.next(4))
        
        let d = a.subscribe(onNext: { ele in
            print("--3--\(ele)")
        })
        
        sequenceOfInts.on(.completed)
    }
}
