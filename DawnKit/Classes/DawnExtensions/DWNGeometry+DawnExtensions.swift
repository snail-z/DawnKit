//
//  DWNGeometry+DawnExtensions.swift
//  DawnExtensions
//
//  Created by zhang on 2023/8/16.
//

import UIKit

// MARK: - DWNHorizontalLayoutEquate

/// 水平分布
public struct DWNHorizontalLayoutEquate {
    
    public init(count: Int, leadSpacing: CGFloat, tailSpacing: CGFloat) {
        self.count = count
        self.leadSpacing = leadSpacing
        self.tailSpacing = tailSpacing
    }

    /// 最大布局宽度，默认屏幕宽
    public var maxLayoutWidth: CGFloat = UIScreen.main.bounds.size.width
    
    /// 水平均分数量 (count > 1)
    public let count: Int
    
    /// 起始位置间距
    public let leadSpacing: CGFloat
    
    /// 末尾位置间距
    public let tailSpacing: CGFloat
}

extension DWNHorizontalLayoutEquate {
    
    /// 固定间距计算出合适的宽度
    public func calculateWidthThatFits(_ fixedSpacing: CGFloat) -> CGFloat {
        let value = maxLayoutWidth - leadSpacing - tailSpacing
        guard count > 1 else { return value }
        let width =  (value - CGFloat(count - 1) * fixedSpacing) / CGFloat(count)
        return floor(width)
    }
    
    /// 固定宽度计算出合适的间距
    public func calculateSpacingThatFits(_ fixedWidth: CGFloat) -> CGFloat {
        let value = maxLayoutWidth - leadSpacing - tailSpacing
        guard count > 1 else { return value }
        let spacing = (value - CGFloat(count) * fixedWidth) / CGFloat(count - 1)
        return floor(spacing)
    }
}


// MARK: - DWNMaxminValue

/// 最大最小值
public struct DWNMaxminValue {
    
    public var max: Double
    public var min: Double
}

public extension DWNMaxminValue {
    
    /// 获取的最大最小值为0
    static var zero: DWNMaxminValue {
        return DWNMaxminValue(max: .zero, min: .zero)
    }
    
    /// 判断最大最小值是否有效(不包含零值、不带无穷大的值、不带非法数字）
    var isValid: Bool {
        let isZero = max.isZero || min.isZero
        let isNaN = max.isNaN || min.isNaN
        let isInfinite = max.isInfinite || min.isInfinite
        return !isZero && !isNaN && !isInfinite
    }
    
    /// 获取最大最小值两点距离
    var distance: Double {
        return abs(max - min)
    }
    
    /// 获取最大最小值两点中间值
    var median: Double {
        return max - (max - min) * 0.5
    }
    
    /// 返回最大最小值均相同的最值
    static func same(_ value: Double) -> DWNMaxminValue {
        return DWNMaxminValue(max: value, min: value)
    }
    
    /// 判断两个最值是否相同
    func isEqual(to other: DWNMaxminValue) -> Bool {
        return max == other.max && min == other.min
    }
    
    /// 将某浮点数限制在最大最小值之间
    func limited(_ value: Double) -> Double {
        return Swift.min(max, Swift.max(min, value))
    }
    
    /// 判断最大最小值是否包含某个数值
    func isContains(_ value: Double) -> Bool {
        return !(value > max || value < min)
    }
}

public extension DWNMaxminValue {
    
    /// 将最大最小值转为绘图区横坐标线 (文案保留两位精度)
    func convertXaxis(_ n: Int) -> Array<Any> {
        return convertXaxis(n) { (_, value) -> String in String(format: "%.2f", value) }
    }
    
    /// 将最大最小值转为绘图区横坐标线 (自定义文案)
    func convertXaxis(_ n: Int, _ closure: (_ index: Int, _ value: Double) -> String) -> [String] {
        let numberOfSegments = Swift.max(2, n) - 1
        let equalValue = fabs(max - min) / Double(numberOfSegments)
        var axisValues = [String]()
        for index in 0...numberOfSegments {
            let value = max - equalValue * Double(index)
            axisValues.append(closure(index, value))
        }
        return axisValues
    }
}
