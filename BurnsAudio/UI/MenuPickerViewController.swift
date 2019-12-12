//
//  MenuPickerViewController.swift
//  BurnsAudio
//
//  Created by tom on 2019-12-07.
//  Copyright © 2019 tom. All rights reserved.
//

import Foundation
import UIKit

protocol MenuPickerViewControllerDelegate: NSObject {
    func menuPickerViewController(_ picker: MenuPickerViewController, didSelectRow row: Int)
}

class MenuPickerViewController: UIViewController {
    let data: [String]
    var selectedRow: Int
    weak var delegate: MenuPickerViewControllerDelegate? = nil
    
    init(data: [String], selectedRow: Int) {
        self.data = data
        self.selectedRow = selectedRow
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
        picker.selectRow(selectedRow, inComponent: 0, animated: false)

    }
}

extension MenuPickerViewController: UIPickerViewDataSource {
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

extension MenuPickerViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.menuPickerViewController(self, didSelectRow: row)
        selectedRow = row
    }
}
