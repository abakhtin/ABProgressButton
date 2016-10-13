//
//  ABProgreeButton.swift
//  DreamHome
//
//  Created by Alex Bakhtin on 8/5/15.
//  Copyright © 2015 bakhtin. All rights reserved.
//

import UIKit

///    ABProgressButton provides functionality for creating custom animation of UIButton during processing some task.
///    Should be created in IB as custom class UIButton to prevent title of the button appearing.
///    Provides mechanism for color inverting on highlitening and using tintColor for textColor(default behavior for system button)
@IBDesignable @objc open class ABProgressButton: UIButton {

    @IBInspectable open var animationShift: CGSize = CGSize(width: 0.0, height: 0.0)

    /// **UI configuration. IBInspectable.** Allows change corner radius on default button state. Has default value of 5.0
    @IBInspectable open var cornerRadius: CGFloat = 5.0

    
    /// **UI configuration. IBInspectable.** Allows change border width on default button state. Has default value of 3.0
    @IBInspectable open var borderWidth: CGFloat = 3.0
    
    /// **UI configuration. IBInspectable.** Allows change border color on default button state. Has default value of control tintColor
    @IBInspectable open lazy var borderColor: UIColor = {
        return self.tintColor
    }()
    
    /// **UI configuration. IBInspectable.** Allows change circle radius on processing button state. Has default value of 20.0
    @IBInspectable open var circleRadius: CGFloat = 20.0
    
    /// **UI configuration. IBInspectable.** Allows change circle border width on processing button state. Has default value of 3.0
    @IBInspectable open var circleBorderWidth: CGFloat = 3.0
    
    /// **UI configuration. IBInspectable.** Allows change circle border color on processing button state. Has default value of control tintColor
    @IBInspectable open lazy var circleBorderColor: UIColor = {
        return self.tintColor
    }()
    
    /// **UI configuration. IBInspectable.** Allows change circle background color on processing button state. Has default value of UIColor.whiteColor()
    @IBInspectable open var circleBackgroundColor: UIColor = UIColor.white
    
    /// **UI configuration. IBInspectable.** Allows change circle cut angle on processing button state. 
    /// Should have value between 0 and 360 degrees. Has default value of 45 degrees
    @IBInspectable open var circleCutAngle: CGFloat = 45.0
    
    
    /// **UI configuration. IBInspectable.** 
    /// If true, colors of content and background will be inverted on button highlightening. Image should be used as template for correct image color inverting.
    /// If false you should use default mechanism for text and images highlitening. 
    /// Has default value of true
    @IBInspectable open var invertColorsOnHighlight: Bool = true
    
    /// **UI configuration. IBInspectable.** 
    /// If true, tintColor whould be used for text, else value from UIButton.textColorForState() would be used.
    /// Has default value of true
    @IBInspectable open var useTintColorForText: Bool = true

    
    /** **Buttons states enum**
    - .Default: Default state of button with border line.
    - .Progressing: State of button without content, button has the form of circle with cut angle with rotation animation. 
    */
    public enum State {
        case `default`, progressing
    }
    
    /** **State changing**
    Should be used to change state of button from one state to another. All transitions between states would be animated. To update progress indicator use `progress` value
    */
    open var progressState: State = .default {
        didSet {
            if(progressState == .default) { self.updateToDefaultStateAnimated(true)}
            if(progressState == .progressing) { self.updateToProgressingState()}
            self.updateProgressLayer()
        }
    }
    /** **State changing**
    Should be used to change progress indicator. Should have value from 0.0 to 1.0. `progressState` should be .Progressing to allow change progress(except nil value).
    */
    open var progress: CGFloat? {
        didSet {
            if progress != nil {
                assert(self.progressState == .progressing, "Progress state should be .Progressing while changing progress value")
            }
            progress = progress == nil ? nil : min(progress!, CGFloat(1.0))
            self.updateProgressLayer()
        }
    }

// MARK : Initialization
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.privateInit()
        self.registerForNotifications()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.privateInit()
        self.registerForNotifications()
    }
    override open func prepareForInterfaceBuilder() {
        self.privateInit()
    }
    deinit {
        self.unregisterFromNotifications()
    }

    fileprivate func privateInit() {
        if (self.useTintColorForText) { self.setTitleColor(self.tintColor, for: UIControlState()) }
        if (self.invertColorsOnHighlight) { self.setTitleColor(self.shapeBackgroundColor, for: UIControlState.highlighted) }
        
        self.layer.insertSublayer(self.shapeLayer, at: 0)
        self.layer.insertSublayer(self.crossLayer, at: 1)
        self.layer.insertSublayer(self.progressLayer, at: 2)
        self.updateToDefaultStateAnimated(false)
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        self.shapeLayer.frame = self.layer.bounds
        self.updateShapeLayer()
        self.crossLayer.frame = self.layer.bounds
        self.progressLayer.frame = self.layer.bounds
        self.bringSubview(toFront: self.imageView!)
    }
    
    override open var isHighlighted: Bool {
        didSet {
            if (self.invertColorsOnHighlight) { self.imageView?.tintColor = isHighlighted ? self.shapeBackgroundColor : self.circleBorderColor }
            self.crossLayer.strokeColor = isHighlighted ? self.circleBackgroundColor.cgColor : self.circleBorderColor.cgColor
            self.progressLayer.strokeColor = isHighlighted ? self.circleBackgroundColor.cgColor : self.circleBorderColor.cgColor
            if (isHighlighted) {
                self.shapeLayer.fillColor = (progressState == State.default) ? self.borderColor.cgColor : self.circleBorderColor.cgColor
            }
            else {
                self.shapeLayer.fillColor = (progressState == State.default) ? self.shapeBackgroundColor.cgColor : self.circleBackgroundColor.cgColor
            }
        }
    }

// MARK : Methods used to update states
    
    fileprivate var shapeLayer = CAShapeLayer()
    fileprivate lazy var crossLayer: CAShapeLayer = {
        let crossLayer = CAShapeLayer()
        crossLayer.path = self.crossPath().cgPath
        crossLayer.strokeColor = self.circleBorderColor.cgColor
        return crossLayer
        }()
    fileprivate lazy var progressLayer: CAShapeLayer = {
        let progressLayer = CAShapeLayer()
        progressLayer.strokeColor = self.circleBorderColor.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        return progressLayer
        }()
    fileprivate lazy var shapeBackgroundColor: UIColor = {
        return self.backgroundColor ?? self.circleBackgroundColor
        }()

    fileprivate func updateToDefaultStateAnimated(_ animated:Bool) {
        self.shapeLayer.strokeColor = self.borderColor.cgColor;
        self.shapeLayer.fillColor = self.shapeBackgroundColor.cgColor
        self.crossLayer.isHidden = true
        self.animateDefaultStateAnimated(animated)
    }
    fileprivate func updateToProgressingState() {
        self.titleLabel?.alpha = 0.0
        self.shapeLayer.strokeColor = self.circleBorderColor.cgColor
        self.shapeLayer.fillColor = self.circleBackgroundColor.cgColor
        self.crossLayer.isHidden = false
        self.animateProgressingState(self.shapeLayer)
    }
    fileprivate func updateShapeLayer() {
        if self.progressState == .default {
            self.shapeLayer.path = self.defaultStatePath().cgPath
        }
        self.crossLayer.path = self.crossPath().cgPath
    }
    fileprivate func updateProgressLayer() {
        self.progressLayer.isHidden = (self.progressState != .progressing || self.progress == nil)
        if (self.progressLayer.isHidden == false) {
            let progressCircleRadius = self.circleRadius - self.circleBorderWidth
            let progressArcAngle = CGFloat(M_PI) * 2 * self.progress! - CGFloat(M_PI_2)
            let circlePath = UIBezierPath()
            let center = CGPoint(x: self.bounds.midX + self.animationShift.width, y: self.bounds.midY + self.animationShift.height)
            circlePath.addArc(withCenter: center, radius:progressCircleRadius, startAngle:CGFloat(-M_PI_2), endAngle:progressArcAngle, clockwise:true)
            circlePath.lineWidth = self.circleBorderWidth
            
            let updateProgressAnimation = CABasicAnimation();
            updateProgressAnimation.keyPath = "path"
            updateProgressAnimation.fromValue = self.progressLayer.path
            updateProgressAnimation.toValue = circlePath.cgPath
            updateProgressAnimation.duration = progressUpdateAnimationTime
            self.progressLayer.path = circlePath.cgPath
            self.progressLayer.add(updateProgressAnimation, forKey: "update progress animation")
        }
    }

// MARK : Methods used to animate states and transions between them

    fileprivate let firstStepAnimationTime = 0.3
    fileprivate let secondStepAnimationTime = 0.15
    fileprivate let textAppearingAnimationTime = 0.2
    fileprivate let progressUpdateAnimationTime = 0.1

    fileprivate func animateDefaultStateAnimated(_ animated: Bool) {
        if !animated {
            self.shapeLayer.path = self.defaultStatePath().cgPath
            self.titleLabel?.alpha = 1.0
            self.showContentImage()
        } else {
            self.shapeLayer.removeAnimation(forKey: "rotation animation")
            
            let firstStepAnimation = CABasicAnimation();
            firstStepAnimation.keyPath = "path"
            firstStepAnimation.fromValue = self.shapeLayer.path
            firstStepAnimation.toValue = self.animateToCircleReplacePath().cgPath
            firstStepAnimation.duration = secondStepAnimationTime
            self.shapeLayer.path = self.animateToCircleFakeRoundPath().cgPath
            self.shapeLayer.add(firstStepAnimation, forKey: "first step animation")
            
            let secondStepAnimation = CABasicAnimation();
            secondStepAnimation.keyPath = "path"
            secondStepAnimation.fromValue = self.shapeLayer.path!
            secondStepAnimation.toValue = self.defaultStatePath().cgPath
            secondStepAnimation.beginTime = CACurrentMediaTime() + secondStepAnimationTime
            secondStepAnimation.duration = firstStepAnimationTime
            self.shapeLayer.path = self.defaultStatePath().cgPath
            self.shapeLayer.add(secondStepAnimation, forKey: "second step animation")
            
            let delay = secondStepAnimationTime + firstStepAnimationTime
            
            UIView.animate(withDuration: textAppearingAnimationTime, delay: delay, options: UIViewAnimationOptions(),
                animations: { () -> Void in
                    self.titleLabel?.alpha = 1.0
                },
                completion: { (complete) -> Void in
                    self.showContentImage()
                })
        }
    }
    fileprivate func animateProgressingState(_ layer: CAShapeLayer) {
        let firstStepAnimation = CABasicAnimation();
        firstStepAnimation.keyPath = "path"
        firstStepAnimation.fromValue = layer.path
        firstStepAnimation.toValue = self.animateToCircleFakeRoundPath().cgPath
        firstStepAnimation.duration = firstStepAnimationTime
        layer.path = self.animateToCircleReplacePath().cgPath
        layer.add(firstStepAnimation, forKey: "first step animation")
        
        let secondStepAnimation = CABasicAnimation();
        secondStepAnimation.keyPath = "path"
        secondStepAnimation.fromValue = layer.path
        secondStepAnimation.toValue = self.progressingStatePath().cgPath
        secondStepAnimation.beginTime = CACurrentMediaTime() + firstStepAnimationTime
        secondStepAnimation.duration = secondStepAnimationTime
        layer.path = self.progressingStatePath().cgPath
        layer.add(secondStepAnimation, forKey: "second step animation")
        
        let animation = CABasicAnimation();
        animation.keyPath = "transform.rotation";
        animation.fromValue = 0 * M_PI
        animation.toValue = 2 * M_PI
        animation.repeatCount = Float.infinity
        animation.duration = 1.5
        animation.beginTime = CACurrentMediaTime() + firstStepAnimationTime + secondStepAnimationTime
        layer.add(animation, forKey: "rotation animation")
        layer.anchorPoint = CGPoint(x: 0.5 + self.animationShift.width / self.bounds.size.width,
                                    y: 0.5 + self.animationShift.height / self.bounds.size.height)
        UIView.animate(withDuration: textAppearingAnimationTime, animations: { () -> Void in
            self.titleLabel?.alpha = 0.0
            self.hideContentImage()
        })
    }
    
// MARK : Pathes creation for different states
    
    fileprivate func defaultStatePath() ->  UIBezierPath {
        let bordersPath = UIBezierPath(roundedRect:self.bounds, cornerRadius:self.cornerRadius)
        bordersPath.lineWidth = self.borderWidth
        return bordersPath
    }
    fileprivate func progressingStatePath() ->  UIBezierPath {
        let center = CGPoint(x: self.bounds.midX + self.animationShift.width, y: self.bounds.midY + self.animationShift.height)
        let circlePath = UIBezierPath()
        let startAngle = self.circleCutAngle/180 * CGFloat(M_PI)
        let endAngle = 2 * CGFloat(M_PI)
        circlePath.addArc(withCenter: center, radius:self.circleRadius, startAngle:startAngle, endAngle:endAngle, clockwise:true)
        circlePath.lineWidth = self.circleBorderWidth
        return circlePath
    }
    fileprivate func animateToCircleFakeRoundPath() ->  UIBezierPath {
        let center = CGPoint(x: self.bounds.midX + self.animationShift.width, y: self.bounds.midY + self.animationShift.height)
        let rect = CGRect(x: center.x - self.circleRadius, y: center.y - self.circleRadius, width: self.circleRadius * 2, height: self.circleRadius * 2)
        let bordersPath = UIBezierPath(roundedRect: rect, cornerRadius: self.circleRadius)
        bordersPath.lineWidth = self.borderWidth
        return bordersPath
    }
    fileprivate func animateToCircleReplacePath() ->  UIBezierPath {
        let center = CGPoint(x: self.bounds.midX + self.animationShift.width, y: self.bounds.midY + self.animationShift.height)
        let circlePath = UIBezierPath()
        circlePath.addArc(withCenter: center, radius:self.circleRadius, startAngle:CGFloat(0.0), endAngle:CGFloat(M_PI * 2), clockwise:true)
        circlePath.lineWidth = self.circleBorderWidth
        return circlePath
    }
    fileprivate func crossPath() -> UIBezierPath {
        let crossPath = UIBezierPath()
        let center = CGPoint(x: self.bounds.midX + self.animationShift.width, y: self.bounds.midY + self.animationShift.height)
        let point1 = CGPoint(x: center.x - self.circleRadius/2, y: center.y + self.circleRadius / 2)
        let point2 = CGPoint(x: center.x + self.circleRadius/2, y: center.y + self.circleRadius / 2)
        let point3 = CGPoint(x: center.x + self.circleRadius/2, y: center.y - self.circleRadius / 2)
        let point4 = CGPoint(x: center.x - self.circleRadius/2, y: center.y - self.circleRadius / 2)
        crossPath.move(to: point1)
        crossPath.addLine(to: point3)
        crossPath.move(to: point2)
        crossPath.addLine(to: point4)
        crossPath.lineWidth = self.circleBorderWidth
        return crossPath
    }

// MARK : processing animation stopping while in background
// Should be done to prevent animation broken on entering foreground
    
    fileprivate func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector:#selector(self.applicationDidEnterBackground(_:)),
            name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.applicationWillEnterForeground(_:)),
            name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    fileprivate func unregisterFromNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func applicationDidEnterBackground(_ notification: Notification) {
        self.pauseLayer(self.layer)
    }
    
    func applicationWillEnterForeground(_ notification: Notification) {
        self.resumeLayer(self.layer)
    }
    
    fileprivate func pauseLayer(_ layer: CALayer) {
        let pausedTime = layer.convertTime(CACurrentMediaTime(), from:nil)
        layer.speed = 0.0
        layer.timeOffset = pausedTime
    }
    
    fileprivate func resumeLayer(_ layer: CALayer) {
        let pausedTime = layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
    }

// MARK : Content images hiding
// The only available way to make images hide is to set the object to nil
// If you now any way else please help me here
    
    fileprivate var imageForNormalState: UIImage?
    fileprivate var imageForHighlitedState: UIImage?
    fileprivate var imageForDisabledState: UIImage?
    
    fileprivate func hideContentImage() {
        self.imageForNormalState = self.image(for: UIControlState())
        self.setImage(UIImage(), for: UIControlState())
        self.imageForHighlitedState = self.image(for: UIControlState.highlighted)
        self.setImage(UIImage(), for: UIControlState.highlighted)
        self.imageForDisabledState = self.image(for: UIControlState.disabled)
        self.setImage(UIImage(), for: UIControlState.disabled)
    }
    
    fileprivate func showContentImage() {
        if self.imageForNormalState != nil {
            self.setImage(self.imageForNormalState, for: UIControlState());
            self.imageForNormalState = nil
        }
        if self.imageForHighlitedState != nil {
            self.setImage(self.imageForHighlitedState, for: UIControlState.highlighted)
            self.imageForHighlitedState = nil
        }
        if self.imageForDisabledState != nil {
            self.setImage(self.imageForDisabledState, for: UIControlState.disabled)
            self.imageForDisabledState = nil
        }
    }
}
