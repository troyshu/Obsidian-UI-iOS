//
//  CountryPickerView.swift
//  Alfredo
//
//  Created by Eric Kunz on 8/18/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

/**
The PickerDelegate protocol defines messages sent to a picker delegate
involving tapped buttons of its accessory view and changing selection.
A CountryPickerDelegate must also conform to the PickerDelegate protocol.
*/
public protocol CountryPickerDelegate: PickerInputDelegate {
    func pickerDidChangeCountry(_ picker: CountryPicker)
}

/// A picker view with all known legal countries.
/// The picker defaults to the country of the device's current locale.
open class CountryPicker: PickerInputView {

    convenience init() {
        self.init(frame: UIScreen.main.bounds)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCountries()
    }

    /// :nodoc:
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// The delegate of a CountryPicker must adopt the CountryPickerDelegate protocol. Methods of the protocol help
    open var countryPickerDelegate: CountryPickerDelegate? {
        didSet {
            delegate = countryPickerDelegate
        }
    }

    /// The ISO code of the selected country
    open fileprivate(set) var countryCode: String?

    /// The name of the selected country. Set this to change the picker to the specified country
    /// as well as the text of the field.
    open var countryName: String? {
        didSet {
            if let name = countryName {
                if let index = alphabeticalCountryNames.index(of: name) {
                    pickerView.selectRow(index, inComponent: 0, animated: true)
                    textField?.text = countryName
                } else {
                    assertionFailure("Country is not a known legal country.")
                }
            }
        }
    }

    fileprivate var alphabeticalCountryNames = [String]()
    fileprivate var codesAndCountries = [String : String]()

    /// :nodoc:
    override open func layoutSubviews() {
        super.layoutSubviews()
    }

    func loadCountries() {
        let currentLocale = Locale.current
        let countryCodes = Locale.isoRegionCodes

        for countryCode in countryCodes {
            let countryName = (currentLocale as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value: countryCode)
            if let name = countryName {
                codesAndCountries[countryCode] = name
            }
        }

        let allCountryNames = codesAndCountries.values
        alphabeticalCountryNames = allCountryNames.sorted()
    }

    fileprivate func updateCountry() {
        countryName = alphabeticalCountryNames[pickerView.selectedRow(inComponent: 0)]
        if let name = countryName {
            countryCode = codesAndCountries[name]
        }
    }

    fileprivate func updateText() {
        textField?.text = countryName
    }

    /// Sets the picker view to the country of the current user's locale
    open func selectCurrentUserLocale() {
        
        let currentLocale = Locale.current
        
        guard let currentCountryCode = (currentLocale as NSLocale).object(forKey: NSLocale.Key.countryCode) as? String else {
            return
        }
        
        let currentCountryName = codesAndCountries[currentCountryCode]
        
        countryName = currentCountryName
        countryCode = currentCountryCode
    }

    // MARK: Picker View Delegate

    open func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        let title = alphabeticalCountryNames[row]

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        let textAttributes = [NSForegroundColorAttributeName : UIColor.black, NSParagraphStyleAttributeName : paragraphStyle]
        let attributedTitle = NSAttributedString(string: title, attributes: textAttributes)

        let label = UILabel()
        label.attributedText = attributedTitle
        return label
    }

    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateCountry()
        updateText()
        countryPickerDelegate?.pickerDidChangeCountry(self)
    }

    open override func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    open override func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return alphabeticalCountryNames.count
    }

    open func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return frame.size.width
    }
}
