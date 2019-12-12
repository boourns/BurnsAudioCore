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
    var rootViewController: UIViewController?
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

open class PageContainerView: UIView {
    let startColor: UIColor
    let endColor: UIColor
    
    init(startColor: UIColor, endColor: UIColor) {
        self.startColor = startColor
        self.endColor = endColor
        super.init(frame: CGRect.zero)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func draw(_ rect: CGRect) {
      
      // 2
      let context = UIGraphicsGetCurrentContext()!
      let colors = [startColor.cgColor, endColor.cgColor]
      
      // 3
      let colorSpace = CGColorSpaceCreateDeviceRGB()
      
      // 4
      let colorLocations: [CGFloat] = [0.0, 1.0]
      
      // 5
      let gradient = CGGradient(colorsSpace: colorSpace,
                                     colors: colors as CFArray,
                                  locations: colorLocations)!
      
      // 6
//      let startPoint = CGPoint.zero
//      let endPoint = CGPoint(x: 0, y: bounds.height)
//      context.drawLinearGradient(gradient,
//                          start: startPoint,
//                            end: endPoint,
//                        options: [])
        
        let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        let radius = max(self.bounds.size.width, self.bounds.size.height)

        context.drawRadialGradient(gradient, startCenter: center, startRadius: 0.0, endCenter: center, endRadius: radius, options: [.drawsAfterEndLocation])
    }
}

open class UI: UIView {
    let state: SpectrumState
    let containerView: PageContainerView
    let navigationBar: NavigationBar
    let pages: [Page]
    
    public init(state: SpectrumState, _ pages: [Page]) {
        self.state = state
        self.pages = pages
        self.navigationBar = NavigationBar(state: state, pages: pages)
        self.containerView = PageContainerView(startColor: state.colours.panel2.adjust(relativeBrightness: 0.5), endColor: state.colours.background)
        
        super.init(frame: CGRect.zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerView)
        addSubview(navigationBar)
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let constraints = [
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: navigationBar.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            navigationBar.bottomAnchor.constraint(equalTo: bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
                
        pages.enumerated().forEach { index, page in
            containerView.addSubview(page)
            
            let constraints = [
                page.topAnchor.constraint(equalTo: containerView.topAnchor),
                page.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                page.trailingAnchor.constraint(equalTo: trailingAnchor),
                page.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ]
            NSLayoutConstraint.activate(constraints)
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func selectPage(_ selectedIndex: Int) {
        navigationBar.selectPage(selectedIndex)
    }
}

public protocol NavigationBarDelegate: NSObject {
    
}

open class NavigationBar: UIView {
    public let pageSelectors = UIStackView()
    let pages: [Page]
    let state: SpectrumState
    var currentPage: Page
    weak var delegate: NavigationBarDelegate?

    init(state: SpectrumState, pages: [Page]) {
        self.state = state
        self.pages = pages
        self.currentPage = pages[0]
        
        super.init(frame: CGRect.zero)
        translatesAutoresizingMaskIntoConstraints = false
        pageSelectors.axis = .horizontal
        pageSelectors.distribution = .fillEqually
        pageSelectors.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pageSelectors)
        
        let constraints = [
            pageSelectors.topAnchor.constraint(equalTo: topAnchor),
            leadingAnchor.constraint(equalTo: pageSelectors.leadingAnchor),
            bottomAnchor.constraint(equalTo: pageSelectors.bottomAnchor),
            pageSelectors.widthAnchor.constraint(equalToConstant: 1024.0 * 2.0 / 3.0)
        ]
        NSLayoutConstraint.activate(constraints)
        
        pages.enumerated().forEach { index, page in
            let button = UIButton()
            button.setTitle(page.name, for: .normal)
            button.setTitleColor(UIColor.black, for: .normal)
            button.titleEdgeInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)

            button.addControlEvent(.touchUpInside) { [weak self] in
                self?.selectPage(index)
            }
            
            pageSelectors.addArrangedSubview(button)
        }
    }
    
    func selectPage(_ selectedIndex: Int) {
        pages.enumerated().forEach { index, page in
            page.isHidden = (selectedIndex != index)
            if selectedIndex == index {
                currentPage = page
            }
        }
                
        pageSelectors.arrangedSubviews.enumerated().forEach { index, view in
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
    
    public required init?(coder: NSCoder) {
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

open class HStack: UIView {
    let stackView = UIStackView()
    
    public init(_ children: [UIView], title: String? = nil) {
        super.init(frame: CGRect.zero)
        
        setup(title)
        
        children.forEach { stackView.addArrangedSubview($0) }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(_ title: String?) {
        addSubview(stackView)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 1.0/UIScreen.main.scale
        translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints = [
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ]
        if (title != nil) {
            let label = UILabel()
            addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = title
            label.transform = CGAffineTransform(rotationAngle: -.pi / 2)
            constraints += [
                label.leadingAnchor.constraint(equalTo: leadingAnchor),
                label.topAnchor.constraint(equalTo: topAnchor),
                label.bottomAnchor.constraint(equalTo: bottomAnchor),
                label.trailingAnchor.constraint(equalTo: stackView.leadingAnchor)
            ]
        } else {
            constraints += [
                stackView.leadingAnchor.constraint(equalTo: leadingAnchor)
            ]
        }
        NSLayoutConstraint.activate(constraints)
    }
}

open class Panel: UIView {
    let state: SpectrumState
    
    var startColor: UIColor {
        return state.colours.panel1
    }
    
    var endColor: UIColor {
        return UIColor.black
    }
    
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
    
        addSubview(child)
        NSLayoutConstraint.activate(child.constraints(filling: self))
        
        //outline.backgroundColor = state.colours.panel1
        layer.borderColor = state.colours.panel1.cgColor
        layer.borderWidth = 1.0 / UIScreen.main.scale
    }
    
}

open class Panel2: Panel {
    override init(_ state: SpectrumState, _ child: UIView) {
        super.init(state, child)
        setup(child: child)
        //outline?.backgroundColor = state.colours.panel2
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
