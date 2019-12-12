//
//  Menu.swift
//  BurnsAudio
//
//  Created by tom on 2019-12-07.
//  Copyright © 2019 tom. All rights reserved.
//

import Foundation
import CoreAudio
import UIKit
import AVFoundation
import CoreAudioKit

public protocol MenuPickerDelegate: NSObject {
    func menuPicker(showMenuRequest menu: UIAlertController, sender: UIView)
}

open class ParameterMenuPicker: MenuPicker, ParameterView, MenuPickerDelegate {
    let param: AUParameter
    let spectrumState: SpectrumState

    init(_ state: SpectrumState, _ address: AUParameterAddress, showLabel: Bool = true) {
        self.spectrumState = state
        guard let param = spectrumState.tree?.parameter(withAddress: address) else {
            fatalError("Could not find param for address \(address)")
        }
        self.param = param

        super.init(name: param.displayName, value: param.value, valueStrings: param.valueStrings!, showLabel: showLabel)
        super.delegate = self
        
        spectrumState.parameters[param.address] = (param, self)

        addControlEvent(.valueChanged) { [weak self] in
            guard let this = self else { return }
            this.param.value = this.value
        }
    }

    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func menuPicker(showMenuRequest menu: UIAlertController, sender: UIView) {
        spectrumState.rootViewController?.show(menu, sender: sender)
    }
}

open class MenuPicker: UIControl {
    let valueStrings: [String]
    let valueLabel = UIButton()
    let label = UILabel()
    public var value: Float {
        didSet {
            updateDisplay()
        }
    }
    let name: String
    let horizontal: Bool
    let showLabel: Bool
    
    weak var delegate: MenuPickerDelegate?
    
    public init(name: String, value: Float, valueStrings: [String], horizontal: Bool = false, showLabel: Bool = true) {
        self.valueStrings = valueStrings
        self.value = value
        self.name = name
        self.horizontal = horizontal
        self.showLabel = showLabel
        
        super.init(frame: CGRect.zero)

        setup()
    }
    
    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.text = name
        label.textColor = UILabel.appearance().tintColor

        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        //valueLabel.backgroundColor = SpectrumUI.colours.background
        
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.titleLabel?.textAlignment = .center
        valueLabel.titleLabel?.textColor = UILabel.appearance().tintColor
        valueLabel.titleLabel?.numberOfLines = 1
        valueLabel.titleLabel?.adjustsFontSizeToFitWidth = true
        valueLabel.contentEdgeInsets = UIEdgeInsets(top: 3.0, left: 10.0, bottom: 3.0, right: 10.0)
        valueLabel.setBackgroundImage(UIImage.from(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.15)), for: .normal)
        valueLabel.layer.borderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.05).cgColor
        valueLabel.layer.borderWidth = 1.0 / UIScreen.main.scale
        valueLabel.layer.cornerRadius = 5
        let heaven = UIImage.from(text: "☰",
                                  size: CGSize(width: 20.0, height: 20.0),
                                  attributes: [
                                    .font: UIFont.preferredFont(forTextStyle: .subheadline),
                                    .foregroundColor: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.2)
            ]
        )
        valueLabel.setImage(heaven, for: .normal)
        
        addSubview(valueLabel)
        if showLabel {
            addSubview(label)
        }
        
        var constraints: [NSLayoutConstraint] = []
        
        if horizontal {
            constraints = [
                label.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: topAnchor, multiplier: Spacing.margin),
                bottomAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: label.bottomAnchor, multiplier: Spacing.margin),
                label.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: Spacing.margin),
                label.trailingAnchor.constraint(equalToSystemSpacingAfter: valueLabel.leadingAnchor, multiplier: Spacing.inner),
                trailingAnchor.constraint(equalToSystemSpacingAfter: valueLabel.trailingAnchor, multiplier: Spacing.margin),
                label.centerYAnchor.constraint(equalTo: valueLabel.centerYAnchor),
                valueLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
                valueLabel.heightAnchor.constraint(lessThanOrEqualTo: valueLabel.widthAnchor),
            ]
        } else {
            constraints = [
                valueLabel.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: topAnchor, multiplier: Spacing.margin),
                trailingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: valueLabel.trailingAnchor, multiplier: Spacing.margin),
                valueLabel.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: leadingAnchor, multiplier: Spacing.margin),
                valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                valueLabel.widthAnchor.constraint(greaterThanOrEqualTo: widthAnchor, multiplier: 0.5),
                valueLabel.heightAnchor.constraint(lessThanOrEqualTo: valueLabel.widthAnchor),
                bottomAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: valueLabel.bottomAnchor, multiplier: Spacing.margin),
            ]
            if (showLabel) {
                constraints += [
                    label.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: valueLabel.bottomAnchor, multiplier: Spacing.inner),
                    label.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: Spacing.margin),
                    bottomAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: label.bottomAnchor, multiplier: Spacing.margin),
                    trailingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: label.trailingAnchor, multiplier: Spacing.margin),
                    label.centerXAnchor.constraint(equalTo: valueLabel.centerXAnchor),
                ]
            }
        }
        
        NSLayoutConstraint.activate(constraints)
        
        let tapGesture = UITapGestureRecognizer() { [weak self] in
            guard let this = self else { return }
            
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let picker = MenuPickerViewController(data: this.valueStrings, selectedRow: Int(this.value))
            picker.delegate = this
            alert.popoverPresentationController?.sourceView = this
            alert.setValue(picker, forKey: "contentViewController")
            
            this.delegate?.menuPicker(showMenuRequest: alert, sender: this)
        }
        valueLabel.addGestureRecognizer(tapGesture)
        valueLabel.isUserInteractionEnabled = true
        
        updateDisplay()
    }
    
    private func updateDisplay() {
        let index = Int(round(value)) % valueStrings.count
        valueLabel.setTitle(valueStrings[index], for: .normal)
    }
}

extension MenuPicker: MenuPickerViewControllerDelegate {
    func menuPickerViewController(_ picker: MenuPickerViewController, didSelectRow row: Int) {
        value = Float(row)
        sendActions(for: .valueChanged)
    }
}
