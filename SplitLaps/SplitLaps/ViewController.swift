//
//  ViewController.swift
//  SplitLaps
//
//  Created by Carlos Cortés Sánchez on 15/12/2017.
//  Copyright © 2017 Carlos Cortés Sánchez. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var splitBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var disposeBag = DisposeBag()
    var timer: Observable<NSInteger>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timer = Observable<NSInteger>
            .interval(0.1, scheduler: MainScheduler.instance)
        timer.subscribe(onNext: { msecs -> Void in
            print("\(msecs)00ms")
        }).disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

