//
//  PickerViewController.swift
//  BurnsAudio
//
//  Created by tom on 2019-12-07.
//  Copyright © 2019 tom. All rights reserved.
//

import Foundation
import UIKit

protocol PickerViewControllerDelegate: NSObject {
    func pickerViewController(_ picker: PickerViewController, didSelectRow row: Int)
}

class PickerViewController: UIViewController {
    let data: [String]
    weak var delegate: PickerViewControllerDelegate? = nil
    
    init(data: [String]) {
        self.data = data
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let picker = UIPickerView()
        view.addSubview(picker)
        picker.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            picker.topAnchor.constraint(equalTo: view.topAnchor),
            picker.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            picker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        picker.delegate = self
        picker.dataSource = self
    }
}

extension PickerViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data[row]
    }
}

extension PickerViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.pickerViewController(self, didSelectRow: row)
    }
}
