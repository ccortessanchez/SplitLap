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
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    
    let tableViewHeader = UILabel()
    
    var disposeBag = DisposeBag()
    var timer: Observable<NSInteger>!
    var isRunning: Observable<Bool>!
    var isntRunning: Observable<Bool>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isRunning = Observable.merge([playBtn.rx.tap.map({_ in true}), stopBtn.rx.tap.map({_ in false})]).startWith(false).share(replay: 2)
        isRunning.bind(to: stopBtn.rx.isEnabled).disposed(by: disposeBag)

        isntRunning = isRunning.map({running in !running}).share(replay: 1)
        isntRunning.bind(to: splitBtn.rx.isHidden).disposed(by: disposeBag)
        isntRunning.bind(to: playBtn.rx.isEnabled).disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        timer = Observable<NSInteger>
            .interval(0.1, scheduler: MainScheduler.instance).withLatestFrom(isRunning, resultSelector: {_, running in running}).filter({running in running}).scan(0, accumulator: {(acc,_) in
                return acc+1
            }).startWith(0).share(replay: 2)
        rxTimer(timer: timer)
        rxLapSequence()
    }
    
    //MARK: Rx methods
    /**
     Subscribes to a timer and binds it to a label
    */
    func rxTimer(timer: Observable<NSInteger>) {
        //To test if the timer emits
        //timer.subscribe(onNext: { msecs -> Void in
            //print("\(msecs)00ms")
        //}).disposed(by: disposeBag)
        timer.map(stringFromTimeInterval)
            .bind(to: timerLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    /**
    */
    func rxLapSequence() {
        let lapSequence = timer.sample(splitBtn.rx.tap)
            .map(stringFromTimeInterval)
            .scan([String](), accumulator: {lapTimes, newTime in
                return lapTimes + [newTime]
            })
            .share(replay: 1)
        
        lapSequence.bind(to: tableView.rx.items(cellIdentifier: "lapCell")) { (row,element,cell) in
            cell.textLabel!.text = "\(row+1)) \(element)"
            }.disposed(by: disposeBag)
        
        lapSequence.map({ laps -> String in
            return "\t\(laps.count) laps"
        })
            .startWith("\tno laps")
            .bind(to: tableViewHeader.rx.text)
            .disposed(by: disposeBag)
    }
    
    //MARK: Helper methods
    /**
     Formats time interval to user readable time
    */
    func stringFromTimeInterval(ms: NSInteger) -> String {
        return String(format: "%0.2d:%0.2d.%0.1d",
                      arguments: [(ms / 600) % 600, (ms % 600 ) / 10, ms % 10])
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableViewHeader
    }
}

