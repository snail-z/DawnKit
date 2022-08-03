//
//  UITableView+ANExtensions.swift
//  AnswerExtensions
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit

public extension UITableView {
    
    /// 返回tableView所有section的所有行数
    func numberOfRows() -> Int {
        var section = 0
        var rowCount = 0
        while section < numberOfSections {
            rowCount += numberOfRows(inSection: section)
            section += 1
        }
        return rowCount
    }
    
    /// 刷新数据完成处理回调
    func reloadData(_ completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0, animations: {
            self.reloadData()
        }, completion: { _ in
            completion()
        })
    }
    
    /// 删除TableHeaderView
    func removeTableHeaderView() {
        tableHeaderView = nil
    }
    
    /// 删除TableFooterView
    func removeTableFooterView() {
        tableFooterView = nil
    }
    
    /// 使用类名出列可重用的UITableViewCell
    func dequeueReusableCell<T: UITableViewCell>(withClass name: T.Type) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: String(describing: name)) as? T else {
            fatalError("Couldn't find UITableViewCell for \(String(describing: name)), make sure the cell is registered with table view")
        }
        return cell
    }

    /// 使用类名及indexPath出列可重用的UITableViewCell
    func dequeueReusableCell<T: UITableViewCell>(withClass name: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: String(describing: name), for: indexPath) as? T else {
            fatalError("Couldn't find UITableViewCell for \(String(describing: name)), make sure the cell is registered with table view")
        }
        return cell
    }

    /// 使用类名出列可重用的UITableViewHeaderFooterView
    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(withClass name: T.Type) -> T {
        guard let headerFooterView = dequeueReusableHeaderFooterView(withIdentifier: String(describing: name)) as? T else {
            fatalError("Couldn't find UITableViewHeaderFooterView for \(String(describing: name)), make sure the view is registered with table view")
        }
        return headerFooterView
    }
    
    /// 使用类名注册UITableViewHeaderFooterView
    func register<T: UITableViewHeaderFooterView>(headerFooterViewClassWith name: T.Type) {
        register(T.self, forHeaderFooterViewReuseIdentifier: String(describing: name))
    }

    /// 使用类名注册UITableViewCell
    func register<T: UITableViewCell>(cellWithClass name: T.Type) {
        register(T.self, forCellReuseIdentifier: String(describing: name))
    }

    /// 安全滚动到目标位置 (检查IndexPath在TableView中是否有效)
    func safeScrollToRow(at indexPath: IndexPath, at scrollPosition: UITableView.ScrollPosition, animated: Bool) {
        guard indexPath.section < numberOfSections else { return }
        guard indexPath.row < numberOfRows(inSection: indexPath.section) else { return }
        scrollToRow(at: indexPath, at: scrollPosition, animated: animated)
    }
}

public extension UITableViewCell {

    /// 返回UITableView可重用的UITableViewCell及子类实例
    static func cellForTableView(_ tableView: UITableView) -> Self {
        let identifier = String(describing: self)
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = Self.init(style: .default, reuseIdentifier: identifier)
        }
        return cell as! Self
    }
}

public extension UITableViewHeaderFooterView {

    /// 返回UITableView可重用的UITableViewHeaderFooterView及子类实例
    static func headerFooterViewForTableView(_ tableView: UITableView) -> Self {
        let identifier = String(describing: self)
        var reusableView = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier)
        if reusableView == nil {
            reusableView = Self.init(reuseIdentifier: identifier)
        }
        return reusableView as! Self
    }
}

#endif
