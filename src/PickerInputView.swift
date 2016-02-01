//
//  PickerInputView.swift
//  Alfredo
//
//  Created by Eric Kunz on 8/14/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

/**
The PickerDelegate protocol defines messages sent to a picker delegate
involving tapped buttons of its accessory view and changing selection.

*/
public protocol PickerInputDelegate: class {
    func pickerDidCancel(picker: PickerInputView)
    func pickerDidTapDone(picker: PickerInputView)
}

/**
A picker that can be used as an inputAccessoryView on a UITextField.
Set the pickerView of the PickerView and initialize with or set the picker's textField.

*/
public class PickerInputView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {

    // MARK: Configuratable Variables

    /// The delegate of an PickerView must adopt the PickerDelegate protocol. Methods of the protocol allow the delegate to handle the picker's cancel and done button actions.
    weak var delegate: PickerInputDelegate?

    /// The title at the top bar of the picker.
    var title: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }

    /// The text field that will be updated by the picker.
    public var textField: UITextField?

    /// Background color of the picker.
    var pickerBackgroundColor = UIColor.whiteColor()

    /// Background color of the top bar.
    var topBarBackgroundColor = UIColor.groupTableViewBackgroundColor()

    private let topBarHeight: CGFloat = 44
    private let topBarButtonWidth: CGFloat = 80
    private let defaultPickerHeight: CGFloat = 216

    /// A picker. Set its delegate and/or dataSource properties to display data.
    public var pickerView: UIPickerView {
        willSet {
            pickerView.removeFromSuperview()
        }
        didSet {
            addSubview(pickerView)
        }
    }

    private var titleLabel: UILabel!

    /// A button on the right side of the input accessory view.
    /// Recommended use as a 'next field' or 'done' button.
    public var doneButton: UIButton!

    /// A button on the left side of the input accessory view.
    public var cancelButton: UIButton!

    convenience init() {
        self.init(frame: UIScreen.mainScreen().bounds)
        pickerView = UIPickerView()
        pickerView.frame = CGRect(x: 0, y: topBarHeight, width: frame.size.width, height: defaultPickerHeight)
        pickerView.backgroundColor = pickerBackgroundColor
        self.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: topBarHeight + defaultPickerHeight)
    }

    /// :nodoc:
    public convenience init(textField: UITextField) {
        self.init()
        self.textField = textField
        textField.inputView = self
    }

    /// :nodoc:
    public convenience init(textField: UITextField, picker: UIPickerView) {
        self.init()
        self.textField = textField
        pickerView = picker
    }

    /// :nodoc:
    public convenience init(textField: UITextField, pickerDelegate: UIPickerViewDelegate?, pickerDataSource: UIPickerViewDataSource?, inputViewDelegate: PickerInputDelegate?) {
        self.init(textField: textField)
        pickerView.delegate = pickerDelegate
        pickerView.dataSource = pickerDataSource
        delegate = inputViewDelegate
        addSubview(pickerView)
    }

    override init(frame: CGRect) {
        pickerView = UIPickerView(frame: CGRect(x: 0, y: topBarHeight, width: frame.size.width, height: defaultPickerHeight))
        pickerView.backgroundColor = pickerBackgroundColor

        super.init(frame: frame)
        addSubview(layoutInputAccessoryView())
        self.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: topBarHeight + defaultPickerHeight)
    }

    required public init?(coder aDecoder: NSCoder) {
        pickerView = UIPickerView()
        super.init(coder: aDecoder)
        pickerView.frame = CGRect(x: 0, y: topBarHeight, width: frame.size.width, height: defaultPickerHeight)
        pickerView.backgroundColor = pickerBackgroundColor
        self.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: topBarHeight + defaultPickerHeight)
    }

    private var accessoryView: UIView?

    private func layoutInputAccessoryView() -> UIView {
        accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: topBarHeight))
        inputAccessoryView?.backgroundColor = topBarBackgroundColor

        titleLabel = UILabel(frame: CGRect(x: topBarButtonWidth, y: 0, width: frame.size.width, height: topBarHeight))
        titleLabel.backgroundColor = UIColor.clearColor()
        titleLabel.textAlignment = NSTextAlignment.Center
        accessoryView!.addSubview(titleLabel)

        cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: topBarButtonWidth, height: topBarHeight))
        cancelButton.backgroundColor = UIColor.clearColor()
        cancelButton.setTitle("Cancel", forState: UIControlState.Normal)
        addHandler(cancelButton, events: UIControlEvents.TouchUpInside, target: self, handler: self.dynamicType.didTapCancelButton)
        accessoryView!.addSubview(cancelButton)

        doneButton = UIButton(frame: CGRect(x: frame.size.width - topBarButtonWidth, y: 0, width: topBarButtonWidth, height: topBarHeight))
        doneButton.backgroundColor = UIColor.clearColor()
        doneButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        addHandler(doneButton, events: UIControlEvents.TouchUpInside, target: self, handler: self.dynamicType.didTapDoneButton)
        accessoryView!.addSubview(doneButton)

        return accessoryView!
    }

    // MARK: Button Actions

    private dynamic func didTapCancelButton(sender: UIButton) {
        delegate?.pickerDidCancel(self)
    }

    private dynamic func didTapDoneButton(sender: UIButton) {
        delegate?.pickerDidTapDone(self)
    }

    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 0
    }

    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 0
    }

}
