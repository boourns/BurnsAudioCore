//
//  Knob.swift
//  iOSSpectrumApp
//
//  Created by tom on 2019-06-15.
//

import Foundation
import UIKit
import CoreAudioKit

open class IntKnob : Knob {
    override init(_ state: SpectrumState, _ address: AUParameterAddress, size: CGFloat = 60.0) {
        super.init(state, address, size: size)
        knob.roundValue = true
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override
    func displayString(_ val: Float) -> String {
        if pressed {
            if let values = param?.valueStrings {
                let index = Int(round(val))
                if values.count > index {
                    return values[index]
                } else {
                    return "??"
                }
            } else {
                return String(format:"%.0f", val)
            }
        } else  {
            return param?.displayName ?? ""
        }
    }
}

open class Knob: UIView, ParameterView {
    weak var param: AUParameter?
    let label = UILabel()
    let knob: LiveKnob = LiveKnob()
    
    deinit {
        NSLog("Knob deinit")
    }
    
    var pressed = false {
        didSet {
            label.text = displayString(knob.value)
        }
    }
    
    var value: Float {
        get {
            return knob.value
        }
        
        set(val) {
            if !pressed {
                knob.internalValue = val
            }
        }
    }
    
    let size: CGFloat
    let state: SpectrumState
    
    init(_ state: SpectrumState, _ address: AUParameterAddress, size: CGFloat = 60.0) {
        self.state = state
        guard let param = state.tree?.parameter(withAddress: address) else {
            fatalError("Could not find parameter for address \(address)")
        }
        
        self.param = param
        self.size = size
        
        super.init(frame: CGRect.zero)
        
        knob.baseColor = state.colours.accent.adjust(relativeBrightness: 0.75)
        
        state.parameters[param.address] = SpectrumParameterEntry(param, self)
        
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        
        label.textColor = UILabel.appearance().tintColor
        label.text = param?.displayName ?? ""
        label.font = UIFont.systemFont(ofSize: 15)
        
        label.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer() { [weak self] in
            guard let this = self else { return }
            this.param?.value = 0.0
        }
        label.addGestureRecognizer(tapGesture)
        
        knob.minimumValue = param?.minValue ?? 0.0
        knob.maximumValue = param?.maxValue ?? 1.0
        knob.continuous = true
        knob.controlType = .horizontalAndVertical
        
        knob.addControlEvent(.valueChanged) { [weak self] in
            guard let this = self else { return }
            this.param?.value = this.knob.value
            this.label.text = this.displayString(this.knob.value)
        }
        
        label.translatesAutoresizingMaskIntoConstraints = false
        knob.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(knob)
        addSubview(label)
        
        let constraints: [NSLayoutConstraint] = [
            knob.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 1.0),
            knob.widthAnchor.constraint(equalToConstant: size),
            knob.heightAnchor.constraint(equalToConstant: size),
            knob.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.topAnchor.constraint(equalToSystemSpacingBelow: knob.bottomAnchor, multiplier: 0.3),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            bottomAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: label.bottomAnchor, multiplier: 1.0),
            bottomAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: knob.bottomAnchor, multiplier: 1.0)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        knob.addControlEvent(.touchDown) { [weak self] in
            self?.pressed = true
        }
        
        knob.addControlEvent(.touchUpInside) { [weak self] in
            self?.pressed = false
        }
        
        knob.addControlEvent(.touchUpOutside) { [weak self] in
            self?.pressed = false
        }
        
        let knobTapGesture = UITapGestureRecognizer() { [weak self] in
            guard let this = self else { return }
            guard let param = this.param else { return }
            
            var inputTextField: UITextField?
            
            let alert = UIAlertController(title: "\(param.displayName) Value", message: "Set value between \(param.minValue) and \(param.maxValue)", preferredStyle: .alert)
            
            alert.addTextField() { field in
                inputTextField = field
                field.returnKeyType = .done
                field.text = "\(param.value)"
            }
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Save", comment: "Default action"), style: .default, handler: { alert in
                guard let this = self else { return }
                
                this.knob.internalValue = Float(inputTextField?.text ?? "0") ?? this.knob.minimumValue
                
                this.knob.sendActions(for: .valueChanged)
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel action"), style: .cancel, handler: nil))
            
            this.state.rootViewController?.present(alert, animated: true, completion: nil)
        }
        
        knobTapGesture.numberOfTapsRequired = 2
        knob.addGestureRecognizer(knobTapGesture)
        
        value = param?.value ?? 0.0
    }
    
    func displayString(_ val: Float) -> String {
        if pressed {
            if let values = param?.valueStrings {
                let index = Int(round(val))
                if values.count > index {
                    return values[index]
                } else {
                    return "??"
                }
            } else {
                var auval: AUValue = AUValue(val)
                return param?.string(fromValue: &auval) ?? ""
            }
        } else  {
            return param?.displayName ?? ""
        }
    }
}
