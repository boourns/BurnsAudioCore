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
        
        NSLog("RotatedLabel layout subview")
        
        bounds = CGRect(
            x: label.frame.minX + 1.0/3.0,
            y: label.frame.minY + 1.0/3.0,
            width: label.frame.width + 1.0/3.0,
            height: label.frame.height + 1.0/3.0)
    }
}
