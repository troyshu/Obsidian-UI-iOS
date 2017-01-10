//
//  DimensionPicker.swift
//  Alfredo
//
//  Created by Eric Kunz on 8/14/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

/**
The DimensionPickerDelegate protocol defines messages sent to a picker delegate
involving tapped buttons of its accessory view and changing of selection.
A DimensionPickerDelegate must also conform to the PickerDelegate protocol.
*/
public protocol DimensionPickerDelegate: PickerInputDelegate {
    func didChangeDimension()
    func didChangeUnits()
}

/// A Unit of measure for an DimensionPicker.
public struct DimensionUnit: Equatable {

    /// The display name of the unit in the picker.
    let name: String

    /// Used for displaying the value with unit.
    let unit: LengthFormatter.Unit

    /// The smallest selectable value in the picker.
    let minimumDimension: Double

    /// The largest selectable value in the picker.
    let maximumDimension: Double

    /// The amount of this unit in one inch.
    let amountInOneInch: Double

    /**
    The amount between each fractional value.

    e.g. a fractionalStepValue of 0.1 leads to fractional values of 0.1, 0.2, 0.3...0.9 in the picker.

    */
    let fractionalStepValue: Double

    /// String representations of each fractional step.
    var fractionalParts: [String] {
        get {
            var fractions = [String]()
            for part in stride(from: 0.0, through: (1 - fractionalStepValue), by: fractionalStepValue) {
                var fractionString = "\(part)"
                fractionString.removeFirstCharacter()
                fractions.append(fractionString)
            }
            return fractions
        }
    }

    /// String representations of each possible whole value. Determined by minimumDimension and maximumDimension.
    var wholeParts: [String] {
        get {
            var wholeParts = [String]()
            let minimum = minimumDimension, maximum = maximumDimension
            for part in stride(from: minimum, to: maximum, by: 1.0) {
                wholeParts.append("\(Int(part))")
            }
            return wholeParts
        }
    }
}

/// :nodoc:
public func == (lhs: DimensionUnit, rhs: DimensionUnit) -> Bool {
    return  lhs.name == rhs.name &&
        lhs.unit == rhs.unit &&
        lhs.minimumDimension == rhs.minimumDimension &&
        lhs.maximumDimension == rhs.maximumDimension &&
        lhs.amountInOneInch == rhs.amountInOneInch &&
        lhs.fractionalStepValue == rhs.fractionalStepValue
}

/**
A picker view for dimensions. Use as an inputView for a UITextField.

Add dimension unit that is available as a NSLengthFormatterUnit can be added to the picker by adding a Dimension value to the dimensions Array.

*/
open class DimensionPicker: PickerInputView {

    /// Delegates must conform to DimensionPickerDelegate protocol.
    open var pickerDelegate: DimensionPickerDelegate?

    /// The dimensions provided in the picker. Initialized with inches and centimeters. Dimension values can be added or removed.
    open var dimensions = [DimensionUnit(name: "Inches", unit: LengthFormatter.Unit.inch, minimumDimension: 0, maximumDimension: 60, amountInOneInch: 1, fractionalStepValue: 0.125), DimensionUnit(name: "Centimeters", unit: LengthFormatter.Unit.centimeter, minimumDimension: 0, maximumDimension: 152, amountInOneInch: 2.54, fractionalStepValue: 0.1)]

    /// The current unit of the picker. Setting this will change the selected unit of the picker.
    open var selectedUnit: DimensionUnit? {
        didSet {
            if let unit = selectedUnit {
                if let index = dimensions.index(of: unit) {
                    pickerView.selectRow(index, inComponent: 0, animated: true)
                }
            }
        }
    }

    /// The dimension selected by the picker in the selected unit.
    /// Setting this will change the selected dimension value of the picker.
    open var selectedDimension: Double {
        get {
            return Double(wholePart) + fractionalPart
        }
        set {
            wholePart = Int(floor(newValue))
            fractionalPart = newValue.truncatingRemainder(dividingBy: 1)
            if let selected = selectedUnit {
                let wholePartRow = wholePart - Int(selected.minimumDimension)
                let fractionalPartRow = Int(round(fractionalPart/selected.fractionalStepValue))
                pickerView.selectRow(wholePartRow, inComponent: 1, animated: true)
                pickerView.selectRow(fractionalPartRow, inComponent: 2, animated: true)
            }
        }
    }

    fileprivate var selectedDimensionInches: Double?
    fileprivate var wholePart = 0
    fileprivate var fractionalPart = 0.0
    fileprivate var dimensionFormatterUnit: LengthFormatter.Unit
    fileprivate var previousDimension: DimensionUnit?

    convenience init() {
        self.init(frame: UIScreen.main.bounds)
    }

    override init(frame: CGRect) {
        selectedUnit = dimensions.first
        if let unit = selectedUnit {
            previousDimension = unit
            dimensionFormatterUnit = unit.unit
        } else {
            dimensionFormatterUnit = LengthFormatter.Unit.inch
        }
        super.init(frame: frame)
    }

    /// :nodoc:
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
    }

    fileprivate var dimensionFormatter = LengthFormatter()

    fileprivate func updateText() {
        if let unit = selectedUnit?.unit {
            let dimensionString = dimensionFormatter.string(fromValue: selectedDimension, unit: unit)
            textField?.text = dimensionString
        }
    }

    fileprivate func updateDimensionValue() {
        if let selected = selectedUnit {
            wholePart = pickerView.selectedRow(inComponent: 1)
            wholePart += Int(previousDimension!.minimumDimension)
            fractionalPart = previousDimension!.fractionalStepValue * Double(pickerView.selectedRow(inComponent: 2))
            selectedDimension = selectedDimension / previousDimension!.amountInOneInch * selected.amountInOneInch
        }
    }

    fileprivate func updatePickerValueComponentsWithNewlySelectedUnit(_ animated: Bool) {
        if let selectedInInches = selectedDimensionInches, let selected = selectedUnit {
            let newDimensionValue = selectedInInches / selected.amountInOneInch
            selectedDimension = newDimensionValue
        }
    }

    // MARK: Picker View Delegate

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.left

        var rowTitle = ""
        if component == 0 {
            paragraphStyle.alignment = NSTextAlignment.center
            rowTitle = dimensions[row].name
        } else if component == 1 {
            if let unit = selectedUnit {
                rowTitle = unit.wholeParts[row]
            }
            paragraphStyle.alignment = NSTextAlignment.center
        } else if component == 2 {
            if let unit = selectedUnit {
                rowTitle = unit.fractionalParts[row]
            }
            paragraphStyle.alignment = NSTextAlignment.left
        }

        let textAttributes = [NSParagraphStyleAttributeName : paragraphStyle]
        let attributedTitle = NSAttributedString(string: rowTitle, attributes: textAttributes)

        let label = UILabel()
        label.attributedText = attributedTitle
        return label
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            dimensionFormatterUnit = dimensions[row].unit
            selectedUnit = dimensions[row]
            updatePickerValueComponentsWithNewlySelectedUnit(true)
            pickerView.reloadComponent(1)
            pickerView.reloadComponent(2)
            updateDimensionValue()
            if let unit = selectedUnit {
                previousDimension = unit
                dimensionFormatterUnit = unit.unit
            }
            updateText()
        } else {
            updateDimensionValue()
            updateText()
            pickerDelegate?.didChangeDimension()
        }
    }

    override open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var rows = 0

        switch component {
        case 0:
            rows = dimensions.count
            break
        case 1:
            rows = selectedUnit?.wholeParts.count ?? 0
            break
        case 2:
            rows = selectedUnit?.fractionalParts.count ?? 0
            break
        default:
            break
        }
        return rows
    }

    open override func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }

    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        var width = CGFloat(0)
        let frameWidth = frame.size.width

        switch component {
        case 0:
            width = 0.4 * frameWidth
            break
        case 1:
            width = 0.3 * frameWidth
            break
        case 2:
            width = 0.3 * frameWidth
            break
        default:
            break
        }
        return width
    }

}
