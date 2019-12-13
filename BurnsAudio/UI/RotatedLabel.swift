//
//  RotatedLabel.swift
//  BurnsAudio
//
//  Created by tom on 2019-12-12.
//  Copyright © 2019 tom. All rights reserved.
//

import Foundation
import UIKit

class RotatedLabel: UIView {
    let label = UILabel()
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(label)
        label.transform = CGAffineTransform(rotationAngle: -.pi / 2)
        translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bounds = label.frame
    }
}
