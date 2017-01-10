//
//  InputFormatter.swift
//  Alfredo
//
//  Created by Eric Kunz on 9/15/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

/// Formatting style options
public enum InputFormattingType {
    /// Use with custom validation
    case none
    /// e.g. $00.00. Valid with any value greater than $0.
    case dollarAmount
    /// e.g. 00/00/0000
    case date
    /// e.g. 00/00
    case creditCardExpirationDate
    /// e.g. 0000 0000 0000 0000 - VISA/MASTERCARD
    case creditCardSixteenDigits
    /// e.g. 0000 000000 00000 - AMEX
    case creditCardFifteenDigits
    /// e.g. 000
    case creditCardCVVThreeDigits
    /// e.g. 0000
    case creditCardCVVFourDigits
    /// Allows any characters. Limits the character count and valid only when at limit
    case limitNumberOfCharacters(Int)
    /// Limits the count of numbers entered. Valid only at set limit
    case limitNumberOfDigits(Int)
    /// Only allows characters from the NSCharacterSet to be entered
    case limitToCharacterSet(CharacterSet)
    /// Any input with more than zero characters
    case anyLength
}

class InputFormatter {

    typealias inputTextFormatter = ((_ text: String, _ newInput: String, _ range: NSRange, _ cursorPosition: Int) -> (String, Int))?
    typealias validChecker = ((_ input: String) -> Bool)?
    var formattingType = InputFormattingType.none

    fileprivate lazy var numberFormatter = NumberFormatter()
    fileprivate lazy var currencyFormatter = NumberFormatter()
    fileprivate lazy var dateFormatter = DateFormatter()

    init(type: InputFormattingType) {
        formattingType = type
    }

    var textFormatter: inputTextFormatter {
        switch self.formattingType {
        case .none:
            return nil
        case .dollarAmount:
            return formatCurrency
        case .date:
            return formatDate
        case .creditCardExpirationDate:
            return formatCreditCardExpirationDate
        case .creditCardSixteenDigits:
            return formatCreditCardSixteenDigits
        case .creditCardFifteenDigits:
            return formatCreditCardFifteenDigits
        case .creditCardCVVThreeDigits:
            return formatCreditCardCVVThreeDigits
        case .creditCardCVVFourDigits:
            return formatCreditCardCVVFourDigits
        case .limitNumberOfCharacters(let length):
            return limitToLength(length)
        case .limitNumberOfDigits(let length):
            return limitToDigitsWithLength(length)
        case .limitToCharacterSet(let characterSet):
            return limitToCharacterSet(characterSet)
        case .anyLength:
            return nil
        }
    }

    var validityChecker: validChecker {
        switch self.formattingType {
        case .none:
            return nil
        case .dollarAmount:
            return validateCurrency
        case .date:
            return isLength(10)
        case .creditCardExpirationDate:
            return isLength(5)
        case .creditCardSixteenDigits:
            return isLength(19)
        case .creditCardFifteenDigits:
            return isLength(17)
        case .creditCardCVVThreeDigits:
            return isLength(3)
        case .creditCardCVVFourDigits:
            return isLength(4)
        case .limitNumberOfCharacters(let numberOfCharacters):
            return isLength(numberOfCharacters)
        case .limitNumberOfDigits(let length):
            return isLength(length)
        case .limitToCharacterSet:
            return nil
        case .anyLength:
            return hasLength
        }
    }

    // MARK:- Formatters

    fileprivate func formatCurrency(_ text: String, newInput: String, range: NSRange, cursorPosition: Int) -> (String, Int) {
        if newInput != "" {
            guard isDigit(Character(newInput)) && text.length < 21 else {
                return (text, cursorPosition)
            }
        }

        let (noSpecialsString, newCursorPosition) = removeNonDigits(text, cursorPosition: cursorPosition)
        let removedCharsCorrectedRange = NSRange(location: range.location + (newCursorPosition - cursorPosition), length: range.length)
        let (newText, _) = resultingString(noSpecialsString, newInput: newInput, range: removedCharsCorrectedRange, cursorPosition: newCursorPosition)

        currencyFormatter.numberStyle = .decimal
        let number = currencyFormatter.number(from: newText) ?? 0
        let newValue = NSNumber(value: number.doubleValue / 100.0 as Double)
        currencyFormatter.numberStyle = .currency
        if let currencyString = currencyFormatter.string(from: newValue) {
            return (currencyString, cursorPosition + (currencyString.length - text.length))
        }
        return (text, cursorPosition)
    }

    fileprivate func formatDate(_ text: String, newInput: String, range: NSRange, cursorPosition: Int) -> (String, Int) {
        if newInput != "" {
            guard isDigit(Character(newInput)) && text.length < 10 else {
                return (text, cursorPosition)
            }
        }

        return removeNonDigitsAndAddCharacters(text, newInput: newInput, range: range, cursorPosition: cursorPosition, characters: [(2, "\\"), (4, "\\")])
    }

    fileprivate func formatCreditCardExpirationDate(_ text: String, newInput: String, range: NSRange, cursorPosition: Int) -> (String, Int) {
        if newInput != "" {
            guard isDigit(Character(newInput)) && text.length < 5 else {
                return (text, cursorPosition)
            }
        }

        return removeNonDigitsAndAddCharacters(text, newInput: newInput, range: range, cursorPosition: cursorPosition, characters: [(2, "\\")])
    }

    fileprivate func formatCreditCardSixteenDigits(_ text: String, newInput: String, range: NSRange, cursorPosition: Int) -> (String, Int) {
        if newInput != "" {
            guard isDigit(Character(newInput)) && text.length < 19 else {
                return (text, cursorPosition)
            }
        }

        return removeNonDigitsAndAddCharacters(text, newInput: newInput, range: range, cursorPosition: cursorPosition, characters: [(4, " "), (8, " "), (12, " ")])
    }

    fileprivate func formatCreditCardFifteenDigits(_ text: String, newInput: String, range: NSRange, cursorPosition: Int) -> (String, Int) {
        if newInput != "" {
            guard isDigit(Character(newInput)) && text.length < 17 else {
                return (text, cursorPosition)
            }
        }

        return removeNonDigitsAndAddCharacters(text, newInput: newInput, range: range, cursorPosition: cursorPosition, characters: [(4, " "), (10, " ")])
    }

    fileprivate func formatCreditCardCVVThreeDigits(_ text: String, newInput: String, range: NSRange, cursorPosition: Int) -> (String, Int) {
        return limitToDigitsAndLength(3, text: text, newInput: newInput, range: range, cursorPosition: cursorPosition)
    }

    fileprivate func formatCreditCardCVVFourDigits(_ text: String, newInput: String, range: NSRange, cursorPosition: Int) -> (String, Int) {
        return limitToDigitsAndLength(4, text: text, newInput: newInput, range: range, cursorPosition: cursorPosition)
    }

    fileprivate func limitToDigitsAndLength(_ length: Int, text: String, newInput: String, range: NSRange, cursorPosition: Int) -> (String, Int) {
        if newInput != "" {
            if text.length == length {
                return (text, cursorPosition)
            } else if !isDigit(Character(newInput)) {
                return (text, cursorPosition)
            }
        }

        return resultingString(text, newInput: newInput, range: range, cursorPosition: cursorPosition)
    }

    fileprivate func limitToLength(_ limit: Int) -> ((_ text: String, _ newInput: String, _ range: NSRange, _ cursorPosition: Int) -> (String, Int)) {

        func limitText(_ text: String, newInput: String, range: NSRange, cursorPosition: Int) -> (String, Int) {
            if text.length == limit && newInput != "" {
                return (text, cursorPosition)
            }
            return resultingString(text, newInput: newInput, range: range, cursorPosition: cursorPosition)
        }

        return limitText
    }

    fileprivate func limitToDigitsWithLength(_ limit: Int) -> ((_ text: String, _ newInput: String, _ range: NSRange, _ cursorPosition: Int) -> (String, Int)) {

        func limitText(_ text: String, newInput: String, range: NSRange, cursorPosition: Int) -> (String, Int) {
            if newInput != "" {
                guard isDigit(Character(newInput)) && text.length < limit else {
                    return (text, cursorPosition)
                }
            }

            return resultingString(text, newInput: newInput, range: range, cursorPosition: cursorPosition)
        }

        return limitText
    }

    fileprivate func limitToCharacterSet(_ set: CharacterSet) -> ((_ text: String, _ newInput: String, _ range: NSRange, _ cursorPosition: Int) -> (String, Int)) {

        func limitToSet(_ text: String, newInput: String, range: NSRange, cursorPosition: Int) -> (String, Int) {
            if newInput != "" {
                guard newInput.rangeOfCharacter(from: set) != nil else {
                    return (text, cursorPosition)
                }
            }

            return resultingString(text, newInput: newInput, range: range, cursorPosition: cursorPosition)
        }

        return limitToSet
    }

    // MARK: Validators

    fileprivate func validateCurrency(_ text: String) -> Bool {
        currencyFormatter.numberStyle = .currency
        let number = currencyFormatter.number(from: text) ?? 0

        return number.doubleValue > 0.0
    }

    fileprivate func isLength(_ length: Int) -> ((_ text: String) -> Bool) {

        func checkLength(_ text: String) -> Bool {
            return text.length == length
        }

        return checkLength
    }

    fileprivate func hasLength(_ text: String) -> Bool {
        return text.length > 0
    }

    // MARK:- Characters

    fileprivate func isDigit(_ character: Character) -> Bool {
        return isDigitOrCharacter("", character: character)
    }

    fileprivate func isDigitOrCharacter(_ additionalCharacters: String, character: Character) -> Bool {
        let digits = CharacterSet.decimalDigits
        let fullSet = NSMutableCharacterSet(charactersIn: additionalCharacters)
        fullSet.formUnion(with: digits)

        if isCharacter(character, aMemberOf: fullSet as CharacterSet) {
            return true
        }
        return false
    }

    func resultingString(_ text: String, newInput: String, range: NSRange, cursorPosition: Int) -> (String, Int) {
        guard range.location >= 0 else {
            return (text, cursorPosition)
        }

        let newText = (text as NSString).replacingCharacters(in: range, with: newInput)
        return (newText, cursorPosition + (newText.length - text.length))
    }

    fileprivate func removeNonDigits(_ text: String, cursorPosition: Int) -> (String, Int) {
        var originalCursorPosition = cursorPosition
        let theText = text
        var digitsOnlyString = ""
        for i in 0 ..< theText.length {
            let characterToAdd = theText[i]
            if isDigit(characterToAdd) {
                let stringToAdd = String(characterToAdd)
                digitsOnlyString.append(stringToAdd)
            } else if i < cursorPosition {
                originalCursorPosition -= 1
            }
        }

        return (digitsOnlyString, originalCursorPosition)
    }

    func insertCharactersAtIndexes(_ text: String, characters: [(Int, Character)], cursorPosition: Int) -> (String, Int) {
        var stringWithAddedChars = ""
        var newCursorPosition = cursorPosition

        for i in 0 ..< text.length {
            for (index, char) in characters {
                if index == i {
                    stringWithAddedChars.append(char)
                    if i < cursorPosition {
                        newCursorPosition += 1
                    }
                }
            }

            let characterToAdd = text[i]
            let stringToAdd = String(characterToAdd)
            stringWithAddedChars.append(stringToAdd)
        }

        return (stringWithAddedChars, newCursorPosition)
    }

    func isCharacter(_ c: Character, aMemberOf set: CharacterSet) -> Bool {
        return set.contains(UnicodeScalar(String(c).utf16.first!)!)
    }

    fileprivate func removeNonDigitsAndAddCharacters(_ text: String, newInput: String, range: NSRange, cursorPosition: Int, characters: [(Int, Character)]) -> (String, Int) {
        let (onlyDigitsText, cursorPos) = removeNonDigits(text, cursorPosition: cursorPosition)
        let correctedRange = NSRange(location: range.location + (cursorPos - cursorPosition), length: range.length)
        let (newText, cursorAfterEdit) = resultingString(onlyDigitsText, newInput: newInput, range: correctedRange, cursorPosition: cursorPos)
        let (withCharacters, newCursorPosition) = insertCharactersAtIndexes(newText, characters: characters, cursorPosition: cursorAfterEdit)
        return (withCharacters, newCursorPosition)
    }
}
