//
//  ContentResizingViewController.swift
//  ResizeVC
//
//  Created by tom on 2019-11-04.
//  Copyright © 2019 tom. All rights reserved.
//

import Foundation
import UIKit

class ContentResizingViewController : UIViewController {
    let scrollView = UIScrollView()
    var childView: UIView
    
    init(childView: UIView) {
        self.childView = childView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
        
        view.backgroundColor = UIColor.black
        scrollView.isScrollEnabled = false
        scrollView.delegate = self
        scrollView.maximumZoomScale = 20.0
        scrollView.minimumZoomScale = 0.001
        scrollView.bounces = false
        
        scrollView.addSubview(childView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        assess()
    }
    
    func assess() {
        print("child frame: \(childView.frame)")
        print("scrollview size: \(scrollView.frame)")
        // conditions:
        
        // if smaller than 1.0,
        // expand to fill height and permit scrolling for width
        
        // if larger than 1.0 zoom
        // expand to fill height or width, float to center for other dimension
        
        let originalHeight = childView.frame.height / scrollView.zoomScale
        let originalWidth = childView.frame.width / scrollView.zoomScale
        
        let finalZoom = min(scrollView.frame.height / originalHeight, scrollView.frame.width / originalWidth)
        let finalWidth = originalWidth * finalZoom
        
        scrollView.isScrollEnabled = false
            
        scrollView.setZoomScale(finalZoom, animated: true)
    }
    
}

extension ContentResizingViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return childView
    }
}
