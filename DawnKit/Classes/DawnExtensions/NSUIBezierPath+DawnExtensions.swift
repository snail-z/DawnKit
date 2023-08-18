//
//  NSUIBezierPath+DawnExtensions.swift
//  DawnExtensions
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z. All rights reserved.
//

import UIKit

#if os(OSX)

public extension NSBezierPath {
    
    /// 将NSBezierPath转为CGPath
    var cgPath: CGPath {
        let path = CGMutablePath()
        let points = UnsafeMutablePointer<NSPoint>.allocate(capacity: 3)
        let elementCount = self.elementCount
        
        if elementCount > 0 {
            for index in 0..<elementCount {
                let pathType = self.element(at: index, associatedPoints: points)
                
                switch pathType {
                case .moveTo:
                    path.move(to: CGPoint(x: points[0].x, y: points[0].y))
                case .lineTo:
                    path.addLine(to: CGPoint(x: points[0].x, y: points[0].y))
                case .curveTo:
                    let origin = CGPoint(x: points[0].x, y: points[0].y)
                    let control1 = CGPoint(x: points[1].x, y: points[1].y)
                    let control2 = CGPoint(x: points[2].x, y: points[2].y)
                    path.addCurve(to: origin, control1: control1, control2: control2)
                case .closePath:
                    path.closeSubpath()
                @unknown default: break
                }
            }
        }
        
        points.deallocate()
        return path
    }
}

#endif

public extension NSUIBezierPath {
    
    /// 通过CGPoint数组绘制多边形路径
    static func NGon(points: [CGPoint]) -> NSUIBezierPath? {
        guard points.count > 2 else {return nil}
        let path = NSUIBezierPath()
        path.move(to: points[0])
        for point in points[1...] {
            path.dwn_addLine(to: point)
        }
        path.close()
        return path
    }
    
    enum NGonOrigin {
        case top, bottom, left, right
    }
    
    /// 绘制正多边形路径
    ///
    /// - Parameters:
    ///   - center: 圆心点坐标 (正多形的外接圆)
    ///   - radius: 正多边形的半径
    ///   - sides: 边数 (至少为3)
    ///   - origin: 起始绘制点
    ///
    /// - Returns: 正多边形路径
    static func NGon(center: CGPoint, radius: CGFloat, sides: Int, origin: NGonOrigin)  -> NSUIBezierPath {
        func start() -> CGPoint {
            switch origin {
            case .top:
                return CGPoint(x: center.x, y: center.y - radius)
            case .bottom:
                return CGPoint(x: center.x, y: center.y + radius)
            case .left:
                return CGPoint(x: center.x - radius, y: center.y)
            case .right:
                return CGPoint(x: center.x + radius, y: center.y)
            }
        }
        
        func link(_ radian: CGFloat) -> CGPoint {
            switch origin {
            case .top:
                return CGPoint(x: center.x + radius * sin(radian), y: center.y - radius * cos(radian))
            case .bottom:
                return CGPoint(x: center.x + radius * sin(radian), y: center.y + radius * cos(radian))
            case .left:
                return CGPoint(x: center.x - radius * cos(radian), y: center.y + radius * sin(radian))
            case .right:
                return CGPoint(x: center.x + radius * cos(radian), y: center.y + radius * sin(radian))
            }
        }
        
        let count = max(3, sides)
        let path = NSUIBezierPath()
        path.move(to: start())
        for i in 0...count {
            let radian: CGFloat = .pi * CGFloat(2 * i) / CGFloat(count)
            path.dwn_addLine(to: link(radian))
        }
        path.close()
        return path
    }
    
    /// 添加矩形框
    func addRect(_ rect: CGRect) {
        move(to: rect.origin)
        dwn_addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        dwn_addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        dwn_addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        close()
    }
}

public extension NSUIBezierPath {
    
    /// 将数组中的点连成普通折线
    static func normalPath(points: [CGPoint]) -> UIBezierPath {
        guard points.count > 0 else {
            return UIBezierPath()
        }
        
        let path = UIBezierPath()
        for index in 0 ..< points.count {
            let point = points[index]
            if index == 0 {
                path.move(to: point)
            } else {
                path.dwn_addLine(to: point)
            }
        }
        return path
    }
    
    /// 将数组中的点连成平滑的曲线(granularity值越大越平滑)
    static func smoothPath(points: [CGPoint], granularity: Int = 3) -> UIBezierPath {
        guard points.count > 0 else {
            return UIBezierPath()
        }
        
        let smoothPath = UIBezierPath()
        var innerPoints = points
        innerPoints.insert(innerPoints[0], at: 0)
        innerPoints.append(innerPoints.last!)
        smoothPath.move(to: innerPoints[0])
        for index in 1 ..< innerPoints.count - 2 {
            let p0 = innerPoints[index - 1]
            let p1 = innerPoints[index]
            let p2 = innerPoints[index + 1]
            let p3 = innerPoints[index + 2]
            
            for i in 1 ..< granularity {
                let t = CGFloat(i) * (1.0 / CGFloat(granularity))
                let tt = t * t
                let ttt = tt * t
                
                var pi = CGPoint.zero
                pi.x = 0.5 * (2*p1.x+(p2.x-p0.x)*t + (2*p0.x-5*p1.x+4*p2.x-p3.x)*tt + (3*p1.x-p0.x-3*p2.x+p3.x)*ttt)
                pi.y = 0.5 * (2*p1.y+(p2.y-p0.y)*t + (2*p0.y-5*p1.y+4*p2.y-p3.y)*tt + (3*p1.y-p0.y-3*p2.y+p3.y)*ttt)
                smoothPath.dwn_addLine(to: pi)
            }
            smoothPath.dwn_addLine(to: p2)
        }
        return smoothPath
    }
}

fileprivate extension NSUIBezierPath {
    
    func dwn_addLine(to point: CGPoint) {
        #if os(OSX)
        line(to: point)
        #endif
        
        #if os(iOS) || os(tvOS)
        addLine(to: point)
        #endif
    }
}
