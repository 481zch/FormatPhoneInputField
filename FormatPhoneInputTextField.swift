//
//  FormatPhoneInputTextField.swift
//  FormatPhoneInputField
//
//  Created by zch on 2025/5/27.
//

import UIKit

public final class FormatPhoneInputTextField: UITextField {
    
    private let phoneNumberLength: Int
    private let delimiter: String
    private let separatePositions: [Int]
    ///  插入之后的位置更新
    private lazy var restorePositions:[Int] = { [weak self] in
        guard let self else { return [] }
        var positions = self.separatePositions
        let step = delimiter.count
        
        for (index, content) in separatePositions.enumerated() {
            if index == 0 {
                continue
            }
            positions[index] += step * index
        }
        
        return positions
    }()
    
    public var realPhoneNumber:String {
        getOriginPhoneNumber(text ?? "")
    }
    public var isFinished:Bool {
        realPhoneNumber.count == phoneNumberLength
    }
    
    public init(_ phoneNumberLength: Int, _ delimiter: String, _ separatePositions: [Int]) {
        self.phoneNumberLength = phoneNumberLength
        self.delimiter = delimiter
        self.separatePositions = separatePositions
        super.init(frame: .zero)
        delegate = self
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FormatPhoneInputTextField: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return string.isEmpty
            ? handleDelCommand(textField, shouldChangeCharactersIn: range, replacementString: string)
            : handleInsertCommand(textField, shouldChangeCharactersIn: range, replacementString: string)
    }
    
    private func handleDelCommand(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let curText = textField.text ?? ""
        var willDeleteLocation = range.location
        let deleteLength = range.length

        var originNumber = getOriginPhoneNumber(curText, &willDeleteLocation)

        if willDeleteLocation < originNumber.count {
            let start = originNumber.index(originNumber.startIndex, offsetBy: willDeleteLocation)
            let endIndex = originNumber.index(start, offsetBy: deleteLength, limitedBy: originNumber.endIndex) ?? originNumber.endIndex
            originNumber.removeSubrange(start..<endIndex)
        }

        var newCursorLocation = willDeleteLocation
        textField.text = getFormattedPhoneNumber(originNumber, &newCursorLocation)

        if let cursorPosition = textField.position(from: textField.beginningOfDocument, offset: newCursorLocation),
           let textRange = textField.textRange(from: cursorPosition, to: cursorPosition) {
            textField.selectedTextRange = textRange
        }

        return false
    }

    private func handleInsertCommand(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var content = string.filter { $0.isNumber }
        if content.isEmpty { return false }
        let curText = textField.text ?? ""
        var willInsertLocation = range.location
        
        var originNumber = getOriginPhoneNumber(curText, &willInsertLocation)
        let remainingLength = phoneNumberLength - originNumber.count
        if remainingLength <= 0 { return false }
        content = String(content.prefix(remainingLength))
        
        originNumber.insert(contentsOf: content, at: originNumber.index(originNumber.startIndex, offsetBy: willInsertLocation))
        willInsertLocation += content.count
        textField.text = getFormattedPhoneNumber(originNumber, &willInsertLocation)
        
        if let cursorPosition = textField.position(from: textField.beginningOfDocument, offset: willInsertLocation) {
            textField.selectedTextRange = textField.textRange(from: cursorPosition, to: cursorPosition)
        }
        
        return false
    }

    private func getFormattedPhoneNumber(_ originPhoneNumber: String,  _ willChangeLocation: inout Int) -> String {
        var res = ""
        let step = delimiter.count
        var start = 0
        let anchor = willChangeLocation
        var isArrived = false
        
        var index = 0
        while index < originPhoneNumber.count {
            if !isArrived && index == separatePositions[start] {
                if (index < anchor) {
                    willChangeLocation += step
                }
                start += 1
                res += delimiter
                isArrived = (start >= separatePositions.count)
                continue
            }
            res += String(originPhoneNumber[originPhoneNumber.index(originPhoneNumber.startIndex, offsetBy: index)])
            index += 1
        }
        
        return res
    }
    
    private func getOriginPhoneNumber(_ formattedPhoneNumber: String) -> String {
        var dummy = 0
        return getOriginPhoneNumber(formattedPhoneNumber, &dummy)
    }
    
    private func getOriginPhoneNumber(_ formattedPhoneNumber: String, _ willChangeLocation: inout Int) -> String {
        var res = ""
        let step = delimiter.count
        var start = 0
        let anchor = willChangeLocation
        var isArrived = false
        
        var index = 0
        while index < formattedPhoneNumber.count {
            if !isArrived && index == restorePositions[start] {
                if (index <= anchor) {
                    willChangeLocation -= step
                }
                start += 1
                index += step
                isArrived = (start >= restorePositions.count)
                continue
            }
            res += String(formattedPhoneNumber[formattedPhoneNumber.index(formattedPhoneNumber.startIndex, offsetBy: index)])
            index += 1
        }
        
        return res
    }
}
