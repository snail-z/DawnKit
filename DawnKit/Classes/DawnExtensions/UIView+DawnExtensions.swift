//
//  UIView+DawnExtensions.swift
//  DawnExtensions
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit

public extension UIView {
    
    /// 返回视图所在的控制器
    var respondViewController: UIViewController? {
        weak var dependResponder: UIResponder? = self
        while dependResponder != nil {
            dependResponder = dependResponder!.next
            if let viewController = dependResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }

    /// 设置视图禁用交互时长
    func disableInteraction(duration: TimeInterval) {
        guard self.isUserInteractionEnabled else { return }
        self.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.isUserInteractionEnabled = true
        }
    }
    
    /// 删除视图的所有子视图
    func removeAllSubviews() {
        self.subviews.forEach({ $0.removeFromSuperview() })
    }
    
    /// 返回对当前View的截图
    func screenshots() -> UIImage? {
        return self.layer.screenshots()
    }
    
    /// 为视图添加阴影效果
    /// - Parameters:
    ///   - radius: 阴影半径
    ///   - opacity: 阴影透明度，取值范围0至1
    ///   - offset: 阴影偏移量，默认CGSize.zero
    ///
    ///         offset设置为.zero时，可以为四周添加阴影效果
    ///         offset中的width为正数时，阴影向右偏移，为负数时，向左偏移
    ///         offset中的height为正数时，阴影向下偏移，为负数时，向上偏移
    ///
    ///   - color: 阴影颜色，默认灰色
    func setShadow(radius: CGFloat, opacity: Float, offset: CGSize = .zero, color: UIColor? = .gray) {
        if let colorValue = color {
            self.layer.shadowRadius = radius
            self.layer.shadowOpacity = opacity
            self.layer.shadowOffset = offset
            self.layer.shadowColor = colorValue.cgColor
            self.layer.shouldRasterize = true
            self.layer.rasterizationScale = UIScreen.main.scale
        } else {
            self.layer.shadowColor = UIColor.clear.cgColor
        }
    }
    
    /// 为视图指定位置添加圆角
    /// - Parameters:
    ///   - radius: 圆角半径
    ///   - corners: 添加圆角的位置，默认四周
    ///   - clips: 子图层超出是否需要裁减，默认true
    func setCorner(radius: CGFloat, byRoundingCorners corners: UIRectCorner, masksToBounds clips: Bool = true) {
        self.layer.masksToBounds = clips
        self.layer.cornerRadius = radius
        
        guard !corners.contains(.allCorners) else { return }
        
        var maskCorners = CACornerMask()
        if corners.contains(.topLeft) {
            maskCorners.insert(.layerMinXMinYCorner)
        }
        if corners.contains(.topRight) {
            maskCorners.insert(.layerMaxXMinYCorner)
        }
        if corners.contains(.bottomLeft) {
            maskCorners.insert(.layerMinXMaxYCorner)
        }
        if corners.contains(.bottomRight) {
            maskCorners.insert(.layerMaxXMaxYCorner)
        }
        self.layer.maskedCorners = maskCorners
    }
}

public extension UIView {
    
    /// 为视图添加轻按手势
    @discardableResult
    func addTapGesture(numberOfTaps: Int = 1, action: @escaping (UITapGestureRecognizer) -> Void) -> UITapGestureRecognizer {
        let tap = UITapGestureRecognizer.action.gestureClosure { (g) in
            action(g)
        }
        tap.numberOfTapsRequired = numberOfTaps
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
        return tap
    }
    
    /// 为视图添加双击手势 (参数-other：当响应双击手势时，使other手势不会被响应)
    @discardableResult
    func addDoubleTapGesture(lapsed other: UIGestureRecognizer? = nil, action: @escaping (UITapGestureRecognizer) -> Void) -> UITapGestureRecognizer {
        let doubleTap = UITapGestureRecognizer.action.gestureClosure { (g) in
            action(g)
        }
        doubleTap.numberOfTapsRequired = 2
        if let g = other { g.require(toFail: doubleTap) }
        self.addGestureRecognizer(doubleTap)
        self.isUserInteractionEnabled = true
        return doubleTap
    }
    
    /// 为视图添加长按手势
    @discardableResult
    func addLongPressGesture(action: @escaping (UILongPressGestureRecognizer) -> Void) -> UILongPressGestureRecognizer {
        let longPress = UILongPressGestureRecognizer.action.gestureClosure { (g) in
            action(g)
        }
        self.addGestureRecognizer(longPress)
        self.isUserInteractionEnabled = true
        return longPress
    }
    
    /// 为视图添加拖动手势
    @discardableResult
    func addPanGesture(action: @escaping (UIPanGestureRecognizer) -> Void) -> UIPanGestureRecognizer {
        let pan = UIPanGestureRecognizer.action.gestureClosure { (g) in
            action(g)
        }
        self.addGestureRecognizer(pan)
        self.isUserInteractionEnabled = true
        return pan
    }
    
    /// 为视图添加捏合手势
    @discardableResult
    func addPinchGesture(action: @escaping (UIPinchGestureRecognizer) -> Void) -> UIPinchGestureRecognizer {
        let pinch = UIPinchGestureRecognizer.action.gestureClosure { (g) in
            action(g)
        }
        self.addGestureRecognizer(pinch)
        self.isUserInteractionEnabled = true
        return pinch
    }
    
    /// 为视图添加滑动手势
    @discardableResult
    func addSwipeGesture(numberOfTouches: Int = 1, direction: UISwipeGestureRecognizer.Direction, action: @escaping (UISwipeGestureRecognizer) -> Void) -> UISwipeGestureRecognizer {
        let swipe = UISwipeGestureRecognizer.action.gestureClosure { (g) in
            action(g)
        }
        swipe.numberOfTouchesRequired = numberOfTouches
        swipe.direction = direction
        self.addGestureRecognizer(swipe)
        self.isUserInteractionEnabled = true
        return swipe
    }
}

public extension UIView {
    
    var left: CGFloat {
        get {
            return self.frame.origin.x
        } set(value) {
            self.frame = CGRect(x: value, y: top, width: width, height: height)
        }
    }

    var right: CGFloat {
        get {
            return left + width
        } set(value) {
            left = value - width
        }
    }

    var top: CGFloat {
        get {
            return self.frame.origin.y
        } set(value) {
            self.frame = CGRect(x: left, y: value, width: width, height: height)
        }
    }

    var bottom: CGFloat {
        get {
            return top + height
        } set(value) {
            top = value - height
        }
    }

    var width: CGFloat {
        get {
            return self.frame.size.width
        } set(value) {
            self.frame = CGRect(x: left, y: top, width: value, height: height)
        }
    }

    var height: CGFloat {
        get {
            return self.frame.size.height
        } set(value) {
            self.frame = CGRect(x: left, y: top, width: width, height: value)
        }
    }
    
    var origin: CGPoint {
        get {
            return self.frame.origin
        } set(value) {
            self.frame = CGRect(origin: value, size: self.frame.size)
        }
    }
    
    var size: CGSize {
        get {
            return self.frame.size
        } set(value) {
            self.frame = CGRect(origin: self.frame.origin, size: value)
        }
    }

    var centerX: CGFloat {
        get {
            return self.center.x
        } set(value) {
            self.center.x = value
        }
    }

    var centerY: CGFloat {
        get {
            return self.center.y
        } set(value) {
            self.center.y = value
        }
    }
}

#endif
