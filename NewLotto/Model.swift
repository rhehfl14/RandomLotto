//
//  Model.swift
//  NewLotto
//
//  Created by kbcard on 2021/07/19.
//

import Foundation
import RxSwift
import RealmSwift
import RxCocoa


class LottoModel: Object {
    
    @objc dynamic var one: Int = -1
    @objc dynamic var two: Int = -1
    @objc dynamic var three: Int = -1
    @objc dynamic var four: Int = -1
    @objc dynamic var five: Int = -1
    @objc dynamic var six: Int = -1
    
    @objc dynamic var lotto: String = ""
    @objc dynamic var count: Int = 0
    
    override class func primaryKey() -> String? {
        return "lotto"
    }
    
    func dataSet(one: Int, two: Int, three: Int, four: Int, five: Int, six: Int) {
        self.one = one
        self.two = two
        self.three = three
        self.four = four
        self.five = five
        self.six = six
    }
}

struct PickResult {
    var isCanceled = false
    var lotto = ""
}


class Model: NSObject {
    
    lazy var realm = try! Realm()
    
    let observer: BehaviorRelay<PickResult> = BehaviorRelay(value: PickResult(isCanceled: false, lotto: ""))
    
    var isCanceled = false
    
    override init() {
        super.init()
    }
    
    func dataSet(one: Int, two: Int, three: Int, four: Int, five: Int, six: Int) {
        
        var lotto = ""
        var array: [Int] = [one, two, three, four, five, six]
        array.sort { $0 < $1 }
        
        for ball in array {
            lotto += "\(ball)|"
        }
        lotto.removeLast()
        
        let data = LottoModel()
        data.dataSet(one: one, two: two, three: three, four: four, five: five, six: six)
        data.lotto = lotto
        
        let result = getObject(filter: NSPredicate(format: "lotto = %@", lotto), cls: LottoModel.self)
        
        if result.count > 0 {
            if let beforeData = result.first as? LottoModel {
                data.count = beforeData.count + 1
            }
            
        } else {
            data.count = 1
        }
        saveObject(objs: data)
        print(data.lotto + "\t\t count : \(data.count)")
//        observer.onNext(!isCanceled)
        observer.accept(PickResult(isCanceled: !isCanceled, lotto: lotto))
    }
    
    
    /// Lotto Data Load
    func loadData(count: Int = 3) -> [LottoModelElement] {
        let result = getObjectAll(cls: LottoModel.self)
        let countCheck = result.map { $0 as! LottoModel }.filter{ $0.count == count }
        let arrData = countCheck.sorted { $0.count > $1.count }
//        let bbb = arrData
//        arr
        return arrData
    }
    
    
    
    // MARK: - Realm Function
    
    func getObject(filter: NSPredicate, cls: Object.Type) -> Results<Object> {
        
        return realm.objects(cls).filter(filter)
    }
    
    func getObjectAll(cls: Object.Type) -> Results<Object> {
        
        return realm.objects(cls)
    }
    
    func deleteObject(objs : Object) {
        try? realm.write ({ [weak self] in
            guard let self = self else { return }
            self.realm.delete(objs)
        })
    }
    
    func deleteObject<Element: Object>(_ objs: Results<Element>) {
        try? realm.write ({ [weak self] in
            guard let self = self else { return }
            self.realm.delete(objs)
        })
    }
    
    // primaryKey 없을 경우
    func addObject(objs: Object) {
        try? realm.write ({ [weak self] in
            guard let self = self else { return }
            self.realm.add(objs)
        })
    }
    
    // primaryKey 있을 경우
    func saveObject(objs: Object) {
        try? realm.write ({ [weak self] in
            guard let self = self else { return }
            self.realm.add(objs, update: .modified)
        })
    }
    
    func editObject(objs: Object) {
        try? realm.write ({ [weak self] in
            guard let self = self else { return }
            self.realm.add(objs, update: .modified)
        })
    }
    
    func deleteAll() {
        try? realm.write { [weak self] in
            guard let self = self else { return }
            self.realm.deleteAll()
        }
    }
}
