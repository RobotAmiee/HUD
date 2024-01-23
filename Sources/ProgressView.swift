//
//  ProgressView.swift
//  Splaaash
//
//  Created by 张龙 on 2021/12/23.
//

import UIKit

class ProgressView: UIView {
    var minStrokeLength: CGFloat = 0.05 {
        didSet {
            if progress == -1 {
                stopAnimating()
                circleLayer.strokeEnd = minStrokeLength
                startAnimating()
            }
        }
    }
    var maxStrokeLength: CGFloat = 0.7 {
        didSet {
            if progress == -1 {
                stopAnimating()
                circleLayer.strokeEnd = minStrokeLength
                startAnimating()
            }
        }
    }
    var circleLineWidth: CGFloat = 3 {
        didSet {
            circleLayer.path = UIBezierPath(arcCenter: bounds.boundsCenter, radius: bounds.boundsCenter.x - circleLineWidth / 2 - (circleBackgroudLineWidth - circleLineWidth) / 2, startAngle: -(.pi / 2), endAngle: -(.pi / 2) + .pi * 2, clockwise: true).cgPath
            circleLayer.lineWidth = circleLineWidth
        }
    }
    var circleColor: UIColor = .white {
        didSet {
            circleLayer.strokeColor = circleColor.cgColor
        }
    }
    var circleBackgroudLineWidth: CGFloat = 5 {
        didSet {
            circleBackgroudLayer.path = UIBezierPath(arcCenter: bounds.boundsCenter, radius: bounds.boundsCenter.x - circleBackgroudLineWidth / 2, startAngle: -(.pi / 2), endAngle: -(.pi / 2) + .pi * 2, clockwise: true).cgPath
            circleBackgroudLayer.lineWidth = circleBackgroudLineWidth
            
            circleLayer.path = UIBezierPath(arcCenter: bounds.boundsCenter, radius: bounds.boundsCenter.x - circleLineWidth / 2 - (circleBackgroudLineWidth - circleLineWidth) / 2, startAngle: -(.pi / 2), endAngle: -(.pi / 2) + .pi * 2, clockwise: true).cgPath
            circleLayer.lineWidth = circleLineWidth
        }
    }
    var circleBackgroudColor: UIColor = UIColor(white: 0, alpha: 0.5) {
        didSet {
            circleBackgroudLayer.strokeColor = circleBackgroudColor.cgColor
        }
    }
    var progress: CGFloat = 0 {
        didSet {
            DispatchQueue.main.async {
                self.stopAnimating()
                
                if self.progress == -1 {
                    self.circleLayer.strokeEnd = self.minStrokeLength
                    self.startAnimating()
                } else {
                    self.circleLayer.strokeEnd = self.progress
                }
            }
        }
    }
    
    private let circleBackgroudLayer = CAShapeLayer()
    private let circleLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
        
        initcircleBackgroudLayer()
        initShapeLayer()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if circleBackgroudLayer.frame.width != frame.width {
            circleBackgroudLayer.frame = bounds
            circleBackgroudLayer.path = UIBezierPath(arcCenter: bounds.boundsCenter, radius: bounds.boundsCenter.x - circleBackgroudLineWidth / 2, startAngle: -(.pi / 2), endAngle: -(.pi / 2) + .pi * 2, clockwise: true).cgPath
            
            circleLayer.frame = bounds
            circleLayer.path = UIBezierPath(arcCenter: bounds.boundsCenter, radius: bounds.boundsCenter.x - circleLineWidth / 2 - (circleBackgroudLineWidth - circleLineWidth) / 2, startAngle: -(.pi / 2), endAngle: -(.pi / 2) + .pi * 2, clockwise: true).cgPath
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initcircleBackgroudLayer() {
        circleBackgroudLayer.backgroundColor = UIColor.clear.cgColor
        circleBackgroudLayer.strokeColor = circleBackgroudColor.cgColor
        circleBackgroudLayer.fillColor = UIColor.clear.cgColor
        circleBackgroudLayer.lineWidth = circleBackgroudLineWidth
        circleBackgroudLayer.frame = bounds
        circleBackgroudLayer.path = UIBezierPath(arcCenter: bounds.boundsCenter, radius: bounds.boundsCenter.x - circleBackgroudLineWidth / 2, startAngle: -(.pi / 2), endAngle: -(.pi / 2) + .pi * 2, clockwise: true).cgPath
        layer.addSublayer(circleBackgroudLayer)
    }
    
    func initShapeLayer() {
        circleLayer.actions = ["strokeEnd" : NSNull(),
                               "strokeStart" : NSNull(),
                               "transform" : NSNull()]
        circleLayer.backgroundColor = UIColor.clear.cgColor
        circleLayer.strokeColor = circleColor.cgColor
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineWidth = circleLineWidth
        circleLayer.lineCap = .round
        circleLayer.strokeStart = 0
        circleLayer.strokeEnd = 0
        circleLayer.frame = bounds
        circleLayer.path = UIBezierPath(arcCenter: bounds.boundsCenter, radius: bounds.boundsCenter.x - circleLineWidth / 2 - (circleBackgroudLineWidth - circleLineWidth) / 2, startAngle: -(.pi / 2), endAngle: -(.pi / 2) + .pi * 2, clockwise: true).cgPath
        layer.addSublayer(circleLayer)
    }
    
    private func startAnimating() {
        if layer.animation(forKey: "rotation") == nil {
            startStrokeAnimation()
            startRotatingAnimation()
        }
    }
    
    private func startRotatingAnimation() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = Double.pi * 2
        rotation.duration = 2.2
        rotation.isCumulative = true
        rotation.isAdditive = true
        rotation.repeatCount = .infinity
        layer.add(rotation, forKey: "rotation")
    }
    
    private func startStrokeAnimation() {
        let easeInOutSineTimingFunc = CAMediaTimingFunction(controlPoints: 0.39, 0.575, 0.565, 1.0)
        let progress: CGFloat = maxStrokeLength
        let endFromValue: CGFloat = circleLayer.strokeEnd
        let endToValue: CGFloat = endFromValue + progress
        let strokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        strokeEnd.fromValue = endFromValue
        strokeEnd.toValue = endToValue
        strokeEnd.duration = 0.5
        strokeEnd.fillMode = CAMediaTimingFillMode.forwards
        strokeEnd.timingFunction = easeInOutSineTimingFunc
        strokeEnd.beginTime = 0.1
        strokeEnd.isRemovedOnCompletion = false
        let startFromValue: CGFloat = circleLayer.strokeStart
        let startToValue: CGFloat = abs(endToValue - minStrokeLength)
        let strokeStart = CABasicAnimation(keyPath: "strokeStart")
        strokeStart.fromValue = startFromValue
        strokeStart.toValue = startToValue
        strokeStart.duration = 0.4
        strokeStart.fillMode = CAMediaTimingFillMode.forwards
        strokeStart.timingFunction = easeInOutSineTimingFunc
        strokeStart.beginTime = strokeEnd.beginTime + strokeEnd.duration + 0.2
        strokeStart.isRemovedOnCompletion = false
        let pathAnim = CAAnimationGroup()
        pathAnim.animations = [strokeEnd, strokeStart]
        pathAnim.duration = strokeStart.beginTime + strokeStart.duration
        pathAnim.fillMode = CAMediaTimingFillMode.forwards
        pathAnim.isRemovedOnCompletion = false
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            if self.circleLayer.animation(forKey: "stroke") != nil {
                self.circleLayer.transform = CATransform3DRotate(self.circleLayer.transform, .pi * 2 * progress, 0, 0, 1)
                self.circleLayer.removeAnimation(forKey: "stroke")
                self.startStrokeAnimation()
            }
        }
        circleLayer.add(pathAnim, forKey: "stroke")
        CATransaction.commit()
    }
    
    private func stopAnimating() {
        circleLayer.removeAllAnimations()
        layer.removeAllAnimations()
        circleLayer.transform = CATransform3DIdentity
        layer.transform = CATransform3DIdentity
        
        circleLayer.strokeStart = 0
        circleLayer.strokeEnd = 0
    }
}

extension CGRect {
    var boundsCenter: CGPoint {
        return CGPoint(x: width / 2, y: height / 2)
    }
}
