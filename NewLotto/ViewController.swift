//
//  ViewController.swift
//  NewLotto
//
//  Created by kbcard on 2021/07/19.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController, UIScrollViewDelegate {
    
    let disposeBack = DisposeBag()
    let viewModel = ViewModel()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btn5Pick: UIButton!
    @IBOutlet weak var btnRemoveAll: UIButton!
    @IBOutlet weak var btnStop: UIButton!
    @IBOutlet weak var btnResult: UIButton!
    @IBOutlet weak var btnClear: UIButton!
    @IBOutlet weak var btnJackPot: UIButton!
    
    @IBOutlet weak var label5ran: UILabel!
    
    
    @IBOutlet weak var txfLotto_1: UITextField!
    @IBOutlet weak var txfLotto_2: UITextField!
    @IBOutlet weak var txfLotto_3: UITextField!
    @IBOutlet weak var txfLotto_4: UITextField!
    @IBOutlet weak var txfLotto_5: UITextField!
    @IBOutlet weak var txfLotto_6: UITextField!
    
    @IBOutlet weak var btnLottoFind: UIButton!
    @IBOutlet weak var btnLottoClear: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        register6Pick()
        registerRemoveAll()
        registerStop()
        registerRun()
        registerTableView()
        registerDataClear()
        registerJackpot()
        
        registerLottoTextFieldInput(textField: txfLotto_1)
        registerLottoTextFieldInput(textField: txfLotto_2)
        registerLottoTextFieldInput(textField: txfLotto_3)
        registerLottoTextFieldInput(textField: txfLotto_4)
        registerLottoTextFieldInput(textField: txfLotto_5)
        registerLottoTextFieldInput(textField: txfLotto_6)
        registerLottoFindBtn()
        
        viewModel.lottoObserver.subscribe { [weak self] element in
            guard let self = self else { return }
            if let str = element.element {
//                self.label5ran.text = str
            }
        }.disposed(by: disposeBack)
    }

    func registerTableView() {
        tableView.rx.setDelegate(self).disposed(by: disposeBack)
        viewModel.dataObserver.bind(to: tableView.rx.items(cellIdentifier: "LottoTableCell", cellType: LottoTableCell.self)) { row, model, cell in
            
            cell.labelOne.text = "\(model.one)"
            cell.labelTow.text = "\(model.two)"
            cell.labelThree.text = "\(model.three)"
            cell.labelFour.text = "\(model.four)"
            cell.labelFive.text = "\(model.five)"
            cell.labelSix.text = "\(model.six)"
            cell.labelCount.text = "\(model.count)"
        }.disposed(by: disposeBack)
    }
    
    func register6Pick() {
        btn5Pick.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            
            self.viewModel.randomLotto()
            
        }.disposed(by: disposeBack)
    }
    
    func registerRemoveAll() {
        btnRemoveAll.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            
            self.viewModel.deleteAll()
        }.disposed(by: disposeBack)
    }
    
    func registerStop() {
        btnStop.rx.tap.bind { [weak self] in
            guard let self = self, let timer = self.viewModel.timer  else { return }
            timer.dispose()
            self.viewModel.timer = nil
            
        }.disposed(by: disposeBack)
    }
    
    func registerRun() {
        btnResult.rx.tap.bind{ [weak self] in
            guard let self = self else { return }
            self.viewModel.loadData()
            
            if let timer = self.viewModel.timer {
                timer.dispose()
                self.viewModel.timer = nil
            }
            
        }.disposed(by: disposeBack)
    }
    
    func registerDataClear() {
        btnClear.rx.tap.bind{ [weak self] in
            guard let self = self else { return }
            self.viewModel.dataClear()
            
        }.disposed(by: disposeBack)
    }
    
    func registerJackpot() {
        btnJackPot.rx.tap.bind{ [weak self] in
            guard let self = self else { return }
            self.viewModel.jackPot()
            
        }.disposed(by: disposeBack)
        
    }
    
    func registerLottoTextFieldInput(textField: UITextField) {
        textField.keyboardType = .numberPad
        textField.rx.text
            .orEmpty
            .distinctUntilChanged()
            .map(lottoNumCheck(_:))
            .subscribe {
                guard let next = $0.element, next else {
                    return
                }
                textField.resignFirstResponder()
            }.disposed(by: disposeBack)
    }
    
    private func lottoNumCheck(_ id: String) -> Bool {
        id.count >= 2
    }
    
    func registerLottoFindBtn() {
        
        btnLottoFind.rx.tap.bind { [weak self] in
            
            
            guard let self = self, let num1 = self.txfLotto_1.text, let num2 = self.txfLotto_2.text, let num3 = self.txfLotto_3.text, let num4 = self.txfLotto_4.text, let num5 = self.txfLotto_5.text, let num6 = self.txfLotto_6.text, let num1Int = Int(num1), let num2Int = Int(num2), let num3Int = Int(num3), let num4Int = Int(num4), let num5Int = Int(num5), let num6Int = Int(num6) else { return }
            
            let lottoNum = [num1Int, num2Int, num3Int, num4Int, num5Int, num6Int]
            self.viewModel.getjetPackLottoNum(lottoNum: lottoNum)
            
        }.disposed(by: disposeBack)
        
        
        btnLottoClear.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            self.txfLotto_1.text = ""
            self.txfLotto_2.text = ""
            self.txfLotto_3.text = ""
            self.txfLotto_4.text = ""
            self.txfLotto_5.text = ""
            self.txfLotto_6.text = ""
            
            self.viewModel.dataClear()
            
        }.disposed(by: disposeBack)
    }
    
}


class LottoTableCell: UITableViewCell {
    
    @IBOutlet weak var labelOne: UILabel!
    @IBOutlet weak var labelTow: UILabel!
    @IBOutlet weak var labelThree: UILabel!
    @IBOutlet weak var labelFour: UILabel!
    @IBOutlet weak var labelFive: UILabel!
    @IBOutlet weak var labelSix: UILabel!
    
    @IBOutlet weak var labelCount: UILabel!
    
}
