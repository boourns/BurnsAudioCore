//
//  UIImage+extensions.swift
//  iOSInstrumentDemoFramework
//
//  Created by tom on 2019-05-27.
//

import Foundation
import UIKit

extension UIImage {
    static func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
    static func from(text: String, size: CGSize, attributes: [NSAttributedString.Key:Any]?) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        NSString(string: text).draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height), withAttributes: attributes)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
