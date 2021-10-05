//
//  ViewModel.swift
//  NewLotto
//
//  Created by kbcard on 2021/07/19.
//

import Foundation
import RxSwift
import RealmSwift

typealias LottoModelElement = LazyFilterSequence<LazyMapSequence<Results<Object>, LottoModel>>.Element

class ViewModel: NSObject {
    
    let SequenceTime = RxTimeInterval.seconds(1)
    
    lazy var realm = try! Realm()
    let model = Model()
    
    /// DisposeBack
    let disposeBack = DisposeBag()
    
    /// 타이머 관련 옵저버
    var timer: Disposable?
    
    let dataObserver = PublishSubject<[LottoModelElement]>()
    let lottoObserver = PublishSubject<String>()
    
    override init() {
        super.init()
    }
    
    func loadData() {
        
        let arrData = model.loadData()
        dataObserver.onNext(arrData)
        
    }
    
    func dataClear() {
        
        let arrData: [LottoModelElement] = []
        dataObserver.onNext(arrData)
        
    }
    
    func randomLotto() {
        
        guard timer == nil else {
            return
        }
        
        timer = Observable<Int>
            .interval(SequenceTime, scheduler: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { (owner, _) in
                owner.randomPick()
        })
    }
    
    func jackPot() {
        
        let arrData = model.loadData()
        let highCount = Int(arrData.first?.count ?? 0)
        guard highCount > 0 else {
            return
        }
        
        let result = jackPotRandom(highCount: highCount, array: [])
        
        dataObserver.onNext(result)
    }
    
    private func jackPotRandom(highCount: Int, array: [LottoModelElement]) -> [LottoModelElement] {
        
        let arrData = model.loadData()
        var temp = array
        
        let result = arrData.filter { $0.count == highCount }
        
        let cnt = result.count
        
        if cnt > 5 {
            
            while true {
                if let random = result.randomElement(), temp.filter({ $0.lotto == random.lotto }).count == 0 {
                    temp.append(random)
                }
                
                if temp.count == 5 {
                    break
                }
            }
            
        } else if cnt < 5 {
            temp = result
            temp = jackPotRandom(highCount: highCount - 1, array: temp)
            
        } else {
            
            temp = result
        }
        
        return temp
        
    }
    
    private func randomPick() {
        var ran: [Int] = []
        for _ in 1...6 {
            ran.append(getRandom())
            ran = ran.map { getOverlap(ran: $0, array: ran) }.sorted { $0 < $1 }
        }
        
        model.observer.asDriver().drive(onNext: { [weak self] pickResult in
            guard let self = self, !pickResult.lotto.isEmpty else { return }
            self.lottoObserver.onNext(pickResult.lotto)
            self.randomLotto()
        }).disposed(by: disposeBack)
        
        model.dataSet(one: ran[0], two: ran[1], three: ran[2], four: ran[3], five: ran[4], six: ran[5])
    }
    
    private func getRandom() -> Int {
        
        return Int.random(in: 1...45)
    }
    
    private func getOverlap(ran: Int, array: [Int]) -> Int {
        
        var ranModify = array
        if array.filter({ ran == $0 }).count == 1 {

            return ran
        } else {
            var newRan = getRandom()
            
            guard let index = ranModify.firstIndex(of: ran) else {
                return newRan
            }
            ranModify[index] = newRan
            newRan = getOverlap(ran: newRan, array: ranModify)
            
            return newRan
        }
    }
    
    func getjetPackLottoNum(lottoNum: [Int]) {
        let arrData = model.loadData(count: 1)
        
        let result = arrData.filter {
            
            var count = 0
            if checkNum(lottoNum: lottoNum, num: $0.one) {
                count += 1
            }
            if checkNum(lottoNum: lottoNum, num: $0.two) {
                count += 1
            }
            if checkNum(lottoNum: lottoNum, num: $0.three) {
                count += 1
            }
            if checkNum(lottoNum: lottoNum, num: $0.four) {
                count += 1
            }
            if checkNum(lottoNum: lottoNum, num: $0.five) {
                count += 1
            }
            if checkNum(lottoNum: lottoNum, num: $0.six) {
                count += 1
            }
            
            if count >= 5 {
                return true
            }
            return false
        }
        
        dataObserver.onNext(result)
    }
    
    func checkNum(lottoNum: [Int], num: Int) -> Bool {
        lottoNum.filter { $0 == num }.count >= 1
    }
    
    
    
    // MARK: - Realm
    
    func getObject(filter: NSPredicate, cls: Object.Type) -> Results<Object> {
        
        return realm.objects(cls).filter(filter)
    }
    
    func deleteObject(objs : Object) {
        try? realm.write ({
            realm.delete(objs)
        })
    }
    
    func deleteObject<Element: Object>(_ objs: Results<Element>) {
        try? realm.write ({
            realm.delete(objs)
        })
    }
    
    // primaryKey 없을 경우
    func addObject(objs: Object) {
        try? realm.write ({
            realm.add(objs)
        })
    }
    
    // primaryKey 있을 경우
    func saveObject(objs: Object) {
        try? realm.write ({
            realm.add(objs, update: .modified)
        })
    }
    
    func editObject(objs: Object) {
        try? realm.write ({
            realm.add(objs, update: .modified)
        })
    }
    
    func deleteAll() {
        try? realm.write {
            realm.deleteAll()
        }
    }
}
