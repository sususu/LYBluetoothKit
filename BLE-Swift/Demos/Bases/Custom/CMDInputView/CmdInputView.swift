//
//  CmdInputView.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/16.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

enum CmdInputType {
    case standard
    case original
}

protocol CmdInputViewDelegate: NSObjectProtocol {
    func didFinishEditing()
}

class CmdInputView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, CmdKeyBoardViewDelegate {

    private var textField: CmdTextField!
    private var collectionView: UICollectionView!
    
    private var keyboard = CmdKeyBoardView()
    
    var numCount = 0
    var units: [CmdUnit] = []
    
    var delegate: CmdInputViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func initViews() {
        let layout = CmdInputLayout()
        layout.itemSize = CGSize(width: 28, height: 15)
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.register(CmdInputCell.self, forCellWithReuseIdentifier: "cellId")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.clear
        
        textField = CmdTextField()
        textField.backgroundColor = UIColor.clear
        textField.textColor = UIColor.clear
        textField.tintColor = UIColor.clear
        textField.addTarget(self, action: #selector(textFieldChanged(textField:)), for: .editingChanged)
        textField.addTarget(self, action: #selector(textFieldDidBeginEditing(textField:)), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(textFieldDidEndEditing(textField:)), for: .editingDidEnd)
        
        textField.inputView = keyboard
        keyboard.delegate = self
        
        
        addSubview(collectionView)
        
        addSubview(textField)
        
        
        self.layer.cornerRadius = 5
        self.layer.borderColor = rgb(235, 235, 235).cgColor
        self.layer.borderWidth = 0.8
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor.white
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        textField.frame = self.bounds
        collectionView.frame = self.bounds

    }
    
    // MARK: - collectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if textField.isFirstResponder
        {
            return units.count + 1
        }
        else
        {
            return units.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! CmdInputCell
        if indexPath.row == units.count {
            let unit = CmdUnit()
            unit.type = .placeHolder
            cell.updateUI(withCmdUnit: unit)
        } else {
            cell.updateUI(withCmdUnit: units[indexPath.row])
        }
        return cell
    }
    
    // MARK: - 事件处理
    @objc func textFieldDidBeginEditing(textField: UITextField) {
        collectionView.reloadData()
    }
    @objc func textFieldDidEndEditing(textField: UITextField) {
        collectionView.reloadData()
        endEdit()
    }
    @objc func textFieldChanged(textField: UITextField) {
        textField.text = textField.text?.replacingOccurrences(of: " ", with: "")
        units = []
        guard let text = textField.text, text.count > 0 else {
            return
        }
        
        var i = 0
        while i < text.count {
            let unit = CmdUnit()
            
            let startIndex = text.index(text.startIndex, offsetBy: i)
            if text[startIndex] == "I" {
                
                let endIndex = text.index(text.startIndex, offsetBy: i + 4)
                let sub = String(text[startIndex ..< endIndex])
                unit.type = .variable
                unit.valueStr = sub
                unit.param = Param(type: .int)
                
                i += 4
            }
            else if text[startIndex] == "S" {
                
                let endIndex = text.index(text.startIndex, offsetBy: i + 3)
                let sub = String(text[startIndex ..< endIndex])
                unit.type = .variable
                unit.valueStr = sub
                unit.param = Param(type: .string)
                
                i += 3
            }
            else if text[startIndex] == "L" {
                let endIndex = text.index(text.startIndex, offsetBy: i + 3)
                let sub = String(text[startIndex ..< endIndex])
                unit.type = .variable
                unit.valueStr = sub
                unit.param = Param(type: .int)
                
                i += 3
            }
            else {
                
                let end = i + 2 > text.count ? (i + 1) : (i + 2)
                
                let endIndex = text.index(text.startIndex, offsetBy: end)
                let sub = String(text[startIndex ..< endIndex])
                unit.type = .cmd
                unit.valueStr = sub
                i += 2
            }
            
            units.append(unit)
        }
        
        
        /*
        let oneLength = 4
        let count = text.count / oneLength
        
        for i in 0 ..< count {
            let startIndex = text.index(text.startIndex, offsetBy: i * oneLength)
            let endIndex = text.index(text.startIndex, offsetBy: i * oneLength + oneLength)
            let sub = String(text[startIndex ..< endIndex])
            
            let unit = CmdUnit()
            unit.valueStr = sub
            
            if sub.hasPrefix("Int") || sub.hasPrefix("Str") {
                unit.type = .variable
            } else {
                unit.type = .cmd
            }
            
            units.append(unit)
            
        }
         */
 
        collectionView.reloadData()
        
    }
    
    func checkCanAddParams() -> Bool {
        if units.count == 0 {
            return true
        }
        
        let last = units.last!
        if last.valueStr!.count == 1 {
            return false
        }
        return true
    }
    
    
    func endEdit() {
        textField.resignFirstResponder()
        delegate?.didFinishEditing()
    }
    
    func beginEdit() {
        textField.becomeFirstResponder()
    }
    
    func didEnterStr(str: String) {
        if (str.hasPrefix("Str") ||
            str.hasPrefix("Int") ||
            str.hasPrefix("Len")) && !checkCanAddParams() {
            return
        }
        textField.text = (textField.text ?? "") + str
        textFieldChanged(textField: textField)
    }
    
    func didFinishInput() {
        endEdit()
    }
    func didFallback() {
        if units.count > 0 {
            units.removeLast()
        }
        var text = ""
        
        for u in units {
            text += u.valueStr ?? ""
        }
        
        textField.text = text
        
        collectionView.reloadData()
    }
}
