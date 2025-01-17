//
//  LiveKnob.swift
//  LiveKnob
//
//  Created by Cem Olcay on 21.02.2018.
//  Copyright © 2018 cemolcay. All rights reserved.
//
import UIKit
import UIKit.UIGestureRecognizerSubclass

/// Knob controlling type. Rotating or horizontal and/or vertical touching.
public enum LiveKnobControlType: Int, Codable {
    /// Only horizontal sliding changes the knob's value.
    case horizontal
    /// Only vertical sliding changes the knob's value.
    case vertical
    /// Both horizontal and vertical sliding changes the knob's value.
    case horizontalAndVertical
    /// Only rotating sliding changes the knob's value.
    case rotary
}

@IBDesignable public class LiveKnob: UIControl {
    /// Whether changes in the value of the knob generate continuous update events.
    /// Defaults `true`.
    @IBInspectable public var continuous = true
    
    /// The minimum value of the knob. Defaults to 0.0.
    @IBInspectable public var minimumValue: Float = 0.0 { didSet { drawKnob() }}
    
    /// The maximum value of the knob. Defaults to 1.0.
    @IBInspectable public var maximumValue: Float = 1.0 { didSet { drawKnob() }}
    
    /// Value of the knob. Also known as progress.
    @IBInspectable public var value: Float = 0.0 {
        didSet {
            value = min(maximumValue, max(minimumValue, value))
            setNeedsLayout()
        }
    }
    
    var roundValue: Bool = false
    
    public var internalValue: Float = 0.0 {
        didSet {
            internalValue = min(maximumValue, max(minimumValue, internalValue))
            value = roundValue ? round(internalValue) : internalValue
        }
    }
    
    /// Default color for the ring base. Defaults black.
    @IBInspectable public var baseColor: UIColor = .gray { didSet { drawKnob() }}
    
    /// Default color for the pointer. Defaults black.
    @IBInspectable public var pointerColor: UIColor = .white { didSet { drawKnob() }}
    
    /// Default color for the progress. Defaults orange.
    @IBInspectable public var progressColor: UIColor = .orange { didSet { drawKnob() }}
    
    /// Line width for the ring base. Defaults 2.
    @IBInspectable public var baseLineWidth: CGFloat = 3 / UIScreen.main.scale { didSet { drawKnob() }}
    
    /// Line width for the progress. Defaults 2.
    @IBInspectable public var progressLineWidth: CGFloat = 2 { didSet { drawKnob() }}

    /// Line width for the pointer. Defaults 2.
    @IBInspectable public var pointerLineWidth: CGFloat = 2 { didSet { drawKnob() }}
    
    /// Layer for the base ring.
    public private(set) var baseLayer = CAShapeLayer()
    public private(set) var ringLayer = CAShapeLayer()
    public private(set) var gradientLayer = CAGradientLayer()
    public private(set) var ringGradientLayer = CAGradientLayer()

    /// Layer for the progress ring.
    public private(set) var progressLayer = CAShapeLayer()
    /// Layer for the value pointer.
    public private(set) var pointerLayer = CAShapeLayer()
    /// Start angle of the base ring.
    public var startAngle = -CGFloat.pi * 11 / 8.0
    /// End angle of the base ring.
    public var endAngle = CGFloat.pi * 3 / 8.0
    /// Knob's sliding type for changing its value. Defaults to rotary.
    public var controlType: LiveKnobControlType = .rotary
    /// Knob gesture recognizer.
    public private(set) var gestureRecognizer: LiveKnobGestureRecognizer!
    
    // MARK: Init
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        // Setup knob gesture
        gestureRecognizer = LiveKnobGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        addGestureRecognizer(gestureRecognizer)
        // Setup layers
        baseLayer.fillColor = UIColor.clear.cgColor
        ringLayer.fillColor = UIColor.clear.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        pointerLayer.fillColor = UIColor.clear.cgColor

        layer.addSublayer(ringGradientLayer)
        layer.addSublayer(gradientLayer)
        layer.addSublayer(progressLayer)
        layer.addSublayer(pointerLayer)
    }
    
    // MARK: Lifecycle
    public override func layoutSubviews() {
        super.layoutSubviews()
        drawKnob()
    }
    
    public func drawKnob() {
        gradientLayer.colors = [baseColor.adjust(relativeBrightness: 0.42).cgColor, baseColor.adjust(relativeBrightness: 0.5).cgColor]
        
        ringGradientLayer.colors = [baseColor.adjust(relativeBrightness: 1.2).cgColor, baseColor.adjust(relativeBrightness: 0.8).cgColor]
        
        // Setup layers
        baseLayer.bounds = bounds
        baseLayer.position = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        ringLayer.bounds = baseLayer.bounds
        ringLayer.position = baseLayer.position
        
        gradientLayer.position = baseLayer.position
        gradientLayer.bounds = baseLayer.bounds
        ringGradientLayer.position = baseLayer.position
        ringGradientLayer.bounds = baseLayer.bounds
        
        progressLayer.bounds = baseLayer.bounds
        progressLayer.position = baseLayer.position
        pointerLayer.bounds = baseLayer.bounds
        pointerLayer.position = baseLayer.position
        ringLayer.lineWidth = baseLineWidth
        progressLayer.lineWidth = progressLineWidth
        pointerLayer.lineWidth = pointerLineWidth
        ringLayer.strokeColor = baseColor.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        pointerLayer.strokeColor = pointerColor.cgColor
        
        // Draw base ring.
        let center = CGPoint(x: baseLayer.bounds.width / 2, y: baseLayer.bounds.height / 2)
        let radius = (min(baseLayer.bounds.width, baseLayer.bounds.height) / 2) - baseLineWidth
        let circle = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat(2.0 * Double.pi), clockwise: true)
        let ring = UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi, endAngle: 0, clockwise: true)
        //ring.lineWidth = 3.0

        baseLayer.path = circle.cgPath
        baseLayer.fillColor = UIColor.black.cgColor
        baseLayer.lineCap = .round
        
        ringLayer.path = ring.cgPath
        ringLayer.lineCap = .round
        ringLayer.lineWidth = baseLineWidth
        ringGradientLayer.mask = ringLayer
        gradientLayer.mask = baseLayer
        
        // Draw pointer.
        let pointer = UIBezierPath()
        pointer.move(to: center)
        pointer.addLine(to: CGPoint(x: center.x + radius, y: center.y))
        pointerLayer.path = pointer.cgPath
        pointerLayer.lineCap = .round
        
        let angle = CGFloat(angleForValue(value))
        var start = (minimumValue < 0.0) ? CGFloat(Double.pi * -1.0/2.0) : startAngle
        var end = angle
        if value < 0.0 {
            end = start
            start = angle
        }
        let progressRing = UIBezierPath(arcCenter: center, radius: radius, startAngle: start, endAngle: end, clockwise: true)
        progressLayer.path = progressRing.cgPath
        progressLayer.lineCap = .round
        
        // Draw pointer
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        pointerLayer.transform = CATransform3DMakeRotation(angle, 0, 0, 1)
        CATransaction.commit()
    }
    
    // MARK: Rotation Gesture Recogniser
    // note the use of dynamic, because calling
    // private swift selectors(@ gestureRec target:action:!) gives an exception
    @objc dynamic func handleGesture(_ gesture: LiveKnobGestureRecognizer) {
        
        switch controlType {
        case .horizontal:
            internalValue += Float(gesture.diagonalChange.width) * (maximumValue - minimumValue)
        case .vertical:
            internalValue -= Float(gesture.diagonalChange.height) * (maximumValue - minimumValue)
        case .horizontalAndVertical:
            internalValue += Float(gesture.diagonalChange.width) * (maximumValue - minimumValue)
            internalValue -= Float(gesture.diagonalChange.height) * (maximumValue - minimumValue)
        case .rotary:
            let midPointAngle = (2 * CGFloat.pi + startAngle - endAngle) / 2 + endAngle
            
            var boundedAngle = gesture.touchAngle
            if boundedAngle > midPointAngle {
                boundedAngle -= 2 * CGFloat.pi
            } else if boundedAngle < (midPointAngle - 2 * CGFloat.pi) {
                boundedAngle += 2 * CGFloat.pi
            }
            
            boundedAngle = min(endAngle, max(startAngle, boundedAngle))
            internalValue = min(maximumValue, max(minimumValue, valueForAngle(boundedAngle)))
        }
        
        // Inform changes based on continuous behaviour of the knob.
        if continuous {
            sendActions(for: .valueChanged)
            if gesture.state == .ended || gesture.state == .cancelled {
                sendActions(for: .touchUpInside)
            }
        } else {
            if gesture.state == .ended || gesture.state == .cancelled {
                sendActions(for: .valueChanged)
            }
        }
    }
    
    // MARK: Value/Angle conversion
    public func valueForAngle(_ angle: CGFloat) -> Float {
        let angleRange = Float(endAngle - startAngle)
        let valueRange = maximumValue - minimumValue
        return Float(angle - startAngle) / angleRange * valueRange + minimumValue
    }
    
    public func angleForValue(_ value: Float) -> CGFloat {
        let angleRange = endAngle - startAngle
        let valueRange = CGFloat(maximumValue - minimumValue)
        return CGFloat(self.value - minimumValue) / valueRange * angleRange + startAngle
    }
}

/// Custom gesture recognizer for the knob.
public class LiveKnobGestureRecognizer: UIPanGestureRecognizer {
    /// Current angle of the touch related the current progress value of the knob.
    public private(set) var touchAngle: CGFloat = 0
    /// Horizontal and vertical slide changes for the calculating current progress value of the knob.
    public private(set) var diagonalChange: CGSize = .zero
    /// Horizontal and vertical slide calculation reference.
    private var lastTouchPoint: CGPoint = .zero
    /// Horizontal and vertical slide sensitivity multiplier. Defaults 0.005.
    public var slidingSensitivity: CGFloat = 0.002
    
    // MARK: UIGestureRecognizerSubclass
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        
        // Update diagonal movement.
        guard let touch = touches.first else { return }
        lastTouchPoint = touch.location(in: view)
        
        // Update rotary movement.
        updateTouchAngleWithTouches(touches)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        
        // Update diagonal movement.
        guard let touchPoint = touches.first?.location(in: view) else { return }
        diagonalChange.width = (touchPoint.x - lastTouchPoint.x) * slidingSensitivity
        diagonalChange.height = (touchPoint.y - lastTouchPoint.y) * slidingSensitivity
        
        // Reset last touch point.
        lastTouchPoint = touchPoint
        
        // Update rotary movement.
        updateTouchAngleWithTouches(touches)
    }
    
    private func updateTouchAngleWithTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let touchPoint = touch.location(in: view)
        touchAngle = calculateAngleToPoint(touchPoint)
    }
    
    private func calculateAngleToPoint(_ point: CGPoint) -> CGFloat {
        let centerOffset = CGPoint(x: point.x - view!.bounds.midX, y: point.y - view!.bounds.midY)
        return atan2(centerOffset.y, centerOffset.x)
    }
    
    // MARK: Lifecycle
    public init() {
        super.init(target: nil, action: nil)
        maximumNumberOfTouches = 1
        minimumNumberOfTouches = 1
    }
    
    public override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        maximumNumberOfTouches = 1
        minimumNumberOfTouches = 1
    }
}
