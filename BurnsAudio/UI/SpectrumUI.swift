//
//  KnobUI.swift
//  Granular
//
//  Created by tom on 2019-06-15.
//

import Foundation
import UIKit
import AVFoundation

public struct SpectrumColours {
    let primary: UIColor
    let panel2: UIColor
    let panel1: UIColor
    let background: UIColor
}

open class SpectrumState {
    var tree: AUParameterTree?
    var parameters: [AUParameterAddress: (AUParameter, ParameterView)] = [:]
    var isVertical: Bool = false
    public var colours: SpectrumColours = SpectrumUI.blue
    
    func update(address: AUParameterAddress, value: Float) {
        guard let uiParam = parameters[address] else { return }
        DispatchQueue.main.async {
            uiParam.1.value = value
        }
    }
}

open class SpectrumUI {
    
    public static let greyscale = SpectrumColours(
        primary: UIColor.init(hex: "#d0d6d9ff")!,
        panel2: UIColor.init(hex: "#38393bff")!,
        panel1: UIColor.init(hex: "#292a30ff")!, //"#313335ff")!,
        background: UIColor.init(hex: "#1e2022ff")!
    )
    
    public static let blue = SpectrumColours(
        primary: UIColor.init(hex: "#d0d6d9ff")!,
        panel2: UIColor.init(hex: "#092d81ff")!,
        panel1: UIColor.init(hex: "#072364ff")!, //"#313335ff")!,
        background: UIColor.init(hex: "#111111ff")!
    )
    
    public static let red = SpectrumColours(
        primary: UIColor.init(hex: "#d0d6d9ff")!,
        panel2: UIColor.init(hex: "#890916ff")!,
        panel1: UIColor.init(hex: "#640710ff")!, //"#313335ff")!,
        background: UIColor.init(hex: "#111111ff")!
    )
    
    public static let purple = SpectrumColours(
        primary: UIColor.init(hex: "#d0d6d9ff")!,
        panel2: UIColor.init(hex: "#890948ff")!,
        panel1: UIColor.init(hex: "#640735ff")!, //"#313335ff")!,
        background: UIColor.init(hex: "#111111ff")!
    )
    
    public static let green = SpectrumColours(
        primary: UIColor.init(hex: "#d0d6d9ff")!,
        panel2: UIColor.init(hex: "#147129ff")!,
        panel1: UIColor.init(hex: "#00570Fff")!, //"#313335ff")!,
        background: UIColor.init(hex: "#111111ff")!
    )
}

open class UI: UIView {
    let state: SpectrumState
    let containerView = UIView()
    let navigationView = UIStackView()
    let pages: [Page]
    var currentPage: Page
    var stackVertically = false
    
    public init(state: SpectrumState, _ pages: [Page]) {
        self.state = state
        self.pages = pages
        self.currentPage = self.pages[0]
        
        super.init(frame: CGRect.zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerView)
        addSubview(navigationView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        navigationView.translatesAutoresizingMaskIntoConstraints = false
        //containerView.contentMode = .scaleAspectFill
        navigationView.axis = .horizontal
        navigationView.distribution = .fillEqually
        
        let constraints = [
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: navigationView.topAnchor),
            navigationView.leadingAnchor.constraint(equalTo: leadingAnchor),
            navigationView.trailingAnchor.constraint(equalTo: trailingAnchor),
            navigationView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
                
        pages.enumerated().forEach { index, page in
            containerView.addSubview(page)
            
            let constraints = [
                page.topAnchor.constraint(equalTo: containerView.topAnchor),
                page.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                page.trailingAnchor.constraint(equalTo: trailingAnchor),
                page.bottomAnchor.constraint(greaterThanOrEqualTo: containerView.bottomAnchor)
            ]
            NSLayoutConstraint.activate(constraints)
            
            let button = UIButton()
            button.setTitle(page.name, for: .normal)
            button.setTitleColor(UIColor.black, for: .normal)
            
            button.addControlEvent(.touchUpInside) { [weak self] in
                self?.selectPage(index)
            }
            
            navigationView.addArrangedSubview(button)
        }
    }
    
    func selectPage(_ selectedIndex: Int) {
        pages.enumerated().forEach { index, page in
            page.isHidden = (selectedIndex != index)
            if selectedIndex == index {
                currentPage = page
            }
        }
                
        navigationView.arrangedSubviews.enumerated().forEach { index, view in
            guard let button = view as? UIButton else { return }
            if index == selectedIndex {
                button.backgroundColor = state.colours.panel2
                button.setTitleColor(UIColor.white, for: .normal)
            } else {
                button.backgroundColor = state.colours.background
                button.setTitleColor(state.colours.primary, for: .normal)
            }
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

open class Page: UIView {
    public let name: String
    public let requiresScroll: Bool
    
    public init(_ name: String, _ child: UIView, requiresScroll: Bool = false) {
        self.name = name
        self.requiresScroll = requiresScroll
        super.init(frame: CGRect.zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        if requiresScroll {
            let scrollView = UIScrollView()
            scrollView.isScrollEnabled = true
            scrollView.isDirectionalLockEnabled = true
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(scrollView)
            NSLayoutConstraint.activate(scrollView.constraints(filling: self))
            scrollView.addSubview(child)
            NSLayoutConstraint.activate(child.constraints(filling: scrollView))
            NSLayoutConstraint.activate(child.constraints(fillingHorizontally: self))

//            scrollView.contentSize = CGSize(width: scrollView.bounds.size.width,
//                                            height: child.bounds.height + 10)
        } else {
            addSubview(child)
            NSLayoutConstraint.activate(child.constraints(filling: self))
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

open class Stack: UIView {
    public enum Alignment {
        case fill
        case top
        case center
        case bottom
    }
    public convenience init(_ children: [UIView], alignment: Alignment = .fill) {
        self.init()
        let stack = UIStackView()
        translatesAutoresizingMaskIntoConstraints = false
        
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .equalCentering
        stack.spacing = 1.0/UIScreen.main.scale
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        children.forEach { stack.addArrangedSubview($0) }
        addSubview(stack)
        var constraints: [NSLayoutConstraint] = stack.constraints(fillingHorizontally: self)
        
        switch(alignment) {
        case .fill:
            constraints += [
                stack.topAnchor.constraint(equalTo: self.topAnchor),
                stack.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ]
        case .top:
            constraints += [
                stack.topAnchor.constraint(equalTo: self.topAnchor),
                stack.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor),
            ]
        case .center:
            constraints += [
                stack.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor),
                stack.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor),
                stack.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            ]
        case .bottom:
            constraints += [
                stack.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor),
                stack.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            ]
        }
       
        NSLayoutConstraint.activate(constraints)
    }
}

open class HStack: UIStackView {
    public convenience init(_ children: [UIView]) {
        self.init()
        
        axis = .horizontal
        alignment = .fill
        distribution = .fillEqually
        spacing = 1.0/UIScreen.main.scale
        translatesAutoresizingMaskIntoConstraints = false
        
        children.forEach { addArrangedSubview($0) }
    }
}

open class Panel: UIView {
    var outline: UIView? = nil
    
    let state: SpectrumState
    
    init(_ state: SpectrumState, _ child: UIView) {
        self.state = state
        
        super.init(frame: CGRect.zero)
        setup(child: child)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(child: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        let outline = UIView()
        outline.translatesAutoresizingMaskIntoConstraints = false
        outline.addSubview(child)
        addSubview(outline)
        NSLayoutConstraint.activate(child.constraints(insideWithSystemSpacing: outline, multiplier: 0.05))
        NSLayoutConstraint.activate(outline.constraints(insideWithSystemSpacing: self, multiplier: 0.05))
        outline.backgroundColor = state.colours.panel1
        outline.layer.borderColor = UIColor.black.cgColor
        outline.layer.borderWidth = 1.0 / UIScreen.main.scale
        self.outline = outline
    }
}

open class Panel2: Panel {
    override init(_ state: SpectrumState, _ child: UIView) {
        super.init(state, child)
        setup(child: child)
        outline?.backgroundColor = state.colours.panel2
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

open class Header: UIView {
    public init(_ text: String) {
        super.init(frame: CGRect.zero)
        setup(text: text)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(text: String) {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.text = text
        label.textColor = UILabel.appearance().tintColor
        
        addSubview(label)
        NSLayoutConstraint.activate(label.constraints(insideWithSystemSpacing: self, multiplier: 1.0))
        
    }
}

open class SettingsButton: UIView {
    public let button = UIButton()
    
    public init() {
        super.init(frame: CGRect.zero)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.black, for: .highlighted)
        
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1.0 / UIScreen.main.scale
        button.layer.cornerRadius = 10
        
        addSubview(button)
        translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(button.constraints(insideWithSystemSpacing: self, multiplier: 1.0))
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public extension BaseAudioUnitViewController {
    
    func showToast(message: String, font: UIFont) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}