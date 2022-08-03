//
//  Array+ANExtensions.swift
//  AnswerExtensions
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z. All rights reserved.
//

import Foundation

public extension Array {
    
    /// 获取数组中一个随机下标
    var randomIndex: Int { Int.random(in: 0..<count) }
    
    /// 获取指定索引对应的元素，索引不存在则返回nil
    func element(safe index: Int) -> Element? {
        guard index >= 0, index < count else { return nil }
        return self[index]
    }
    
    /// 获取指定索引对应的元素，索引不存在则返回默认值
    func element(safe index: Int, default element: Element) -> Element {
        guard index >= 0, index < count else { return element }
        return self[index]
    }
    
    /// 检查数组内是否包含指定元素的类型
    func containsType<T>(of element: T) -> Bool {
        let elementType = type(of: element)
        return contains { type(of: $0) == elementType}
    }
    
    ///  获取数组中指定某范围内的元素 (返回某范围内元素的数组)
    func subarray(at range: NSRange) -> [Element] {
        var elements = [Element]()
        guard range.location >= 0, range.location < count else {
            return elements
        }
        guard range.length > 0, NSMaxRange(range) <= count else {
            return elements
        }
        for obj in self[range.location..<NSMaxRange(range)] {
            elements.append(obj)
        }
        return elements
    }
    
    /// 获取数组中前n个元素 (返回包含原数组内前n个元素的数组)
    func firstElements(of length: NSInteger) -> [Element] {
        var elements = [Element]()
        let end = Swift.max(0, Swift.min(self.count, length))
        for obj in self[0..<end] {
            elements.append(obj)
        }
        return elements
    }
    
    /// 获取数组中后n个元素 (返回包含原数组内后n个元素的数组)
    func lastElements(of length: NSInteger) -> [Element] {
        let begin = count - Swift.max(0, Swift.min(count, length))
        var elements = [Element]()
        for obj in self[begin..<count] {
            elements.append(obj)
        }
        return elements
    }
    
    /// 根据闭包返回的某个条件，查找数组内的最大最小值
    func maximin<T: Comparable>(_ block: (_ sender: Element) -> T) -> (max: T, min: T)? {
        guard !isEmpty else { return nil }
        var minValue = block(self[0]), maxValue = block(self[0])
        let lastIndex = count - 1
        for index in stride(from: 0, to: lastIndex, by: 2) {
            let one = block(self[index]), two = block(self[index + 1])
            let maxTemp = Swift.max(one, two)
            let minTemp = Swift.min(one, two)
            if maxTemp > maxValue { maxValue = maxTemp }
            if minTemp < minValue { minValue = minTemp }
        }
        let lastValue = block(self[lastIndex])
        if lastValue > maxValue { maxValue = lastValue }
        if lastValue < minValue { minValue = lastValue }
        return (maxValue, minValue)
    }
}

public extension Collection {
    
    /// 返回指定索引对应的元素，若索引越界则返回nil
    subscript (safe index: Index?) -> Iterator.Element? {
        guard let idx = index else { return nil }
        return indices.contains(idx) ? self[idx] : nil
    }
}
