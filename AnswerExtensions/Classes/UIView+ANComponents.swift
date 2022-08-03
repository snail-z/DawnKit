//
//  UIView+ANComponents.swift
//  AnswerExtensions
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z. All rights reserved.
//

import UIKit

// - MARK: ANImageLabel -

@objc open class ANImageLabel: UIView {
    
    /// 图片与文字布局位置
    @objc public enum ImagePlacement: Int {
        /// 图片在上，文字在下
        case top
        /// 图片在左，文字在右
        case left
        /// 图片在下，文字在上
        case bottom
        /// 图片在右，文字在左
        case right
    }
    
    /// 设置按图标和文字的相对位置，默认为ImagePlacement.left
    @objc public var imagePlacement: ImagePlacement = .left {
        didSet {
            guard imagePlacement != oldValue else { return }
            imagePlacementUpdates()
        }
    }
    
    /// 设置图标和文字之间的间隔，默认为10 (与对齐到两端样式冲突时优先布局.spaceBetween样式)
    @objc public var imageAndTitleSpacing: CGFloat = 10 {
        didSet {
            stackView.spacing = imageAndTitleSpacing
        }
    }
    
    /// 设置图标固定尺寸，默认为zero图标尺寸自适应
    @objc public var imageFixedSize: CGSize = .zero {
        didSet {
            guard !imageFixedSize.equalTo(oldValue) else { return }
            imageFixedSizeUpdates()
        }
    }
    
    /// 设置四周内边距，默认.zero
    @objc public var contentEdgeInsets: UIEdgeInsets = .zero {
        didSet {
            guard contentEdgeInsets != oldValue else { return }
            layoutUpdates()
        }
    }
    
    /// 竖直方向对齐样式
    @objc public enum ContentVerticalAlignment: Int {
        /// nature常用于视图自适应内容大小时 // center, left, right, spaceBetween常用于高度已被约束时
        case nature, center, top, bottom, spaceBetween
    }
    
    /// 水平方向对齐样式
    @objc public enum ContentHorizontalAlignment: Int {
        /// nature常用于视图自适应内容大小时 // center, left, right, spaceBetween常用于宽度已被约束时
        case nature, center, left, right, spaceBetween
    }
        
    /// 竖直方向对齐样式，默认顶部对齐
    @objc public var contentVerticalAlignment: ContentVerticalAlignment = .nature {
        didSet {
            guard contentVerticalAlignment != oldValue else { return }
            layoutUpdates()
        }
    }
    
    /// 水平方向对齐样式，默认居左对齐
    @objc public var contentHorizontalAlignment: ContentHorizontalAlignment = .nature {
        didSet {
            guard contentHorizontalAlignment != oldValue else { return }
            layoutUpdates()
        }
    }
    
    /// 子视图排列对齐样式
    public var arrangedAlignment: UIStackView.Alignment = .center {
        didSet {
            stackView.alignment = arrangedAlignment
        }
    }
    
    /// 是否自动调整 `cornerRadius` 使其始终保持为高度的 1/2
    @objc public var adjustsRoundedCornersAutomatically: Bool = false {
        didSet {
            guard adjustsRoundedCornersAutomatically else { return }
            layer.masksToBounds = true
            setNeedsLayout()
        }
    }
    
    /// 设置扩增手势事件的响应区域，默认UIEdgeInsetsZero
    @objc public var touchResponseInsets:UIEdgeInsets = .zero
    
    @objc public private(set) var imageView: UIImageView!
    @objc public private(set) var titleLabel: UILabel!
    private var stackView: UIStackView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        privateInitialization()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        privateInitialization()
    }
    
    private func privateInitialization() {
        stackView = UIStackView()
        stackView.alignment = arrangedAlignment
        stackView.spacing = imageAndTitleSpacing
        addSubview(stackView)
        
        imageView = UIImageView()
        stackView.addArrangedSubview(imageView)
        
        titleLabel = UILabel()
        stackView.addArrangedSubview(titleLabel)
        
        layoutUpdates()
    }

    private func imagePlacementUpdates() {
        imageView.removeFromSuperview()
        switch imagePlacement {
        case .left, .top:
            stackView.insertArrangedSubview(imageView, at: 0)
        case .right, .bottom:
            stackView.addArrangedSubview(imageView)
        }
        
        layoutUpdates()
    }
    
    private func layoutUpdates() {
        switch imagePlacement {
        case .top, .bottom:
            stackView.axis = .vertical
            stackView.distribution = contentVerticalAlignment == .spaceBetween ? .equalCentering : .fill
            imageView.setContentHuggingPriority(.required, for: .vertical)
            imageView.setContentCompressionResistancePriority(.required, for: .vertical)
            contentVerticalLayoutUpdates()
        case .left, .right:
            stackView.axis = .horizontal
            stackView.distribution = contentHorizontalAlignment == .spaceBetween ? .equalCentering : .fill
            imageView.setContentHuggingPriority(.required, for: .horizontal)
            imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
            contentHorizontalLayoutUpdates()
        }
    }
    
    private func contentHorizontalLayoutUpdates() {
        let inset = contentEdgeInsets
        switch contentHorizontalAlignment {
        case .nature, .spaceBetween:
            stackView.pk.remakeConstraints { make in
                make.top.equalTo(inset.top)
                make.bottom.equalToSuperview().inset(inset.bottom)
                make.left.equalTo(inset.left)
                make.right.equalToSuperview().inset(inset.right)
            }
        case .center:
            stackView.pk.remakeConstraints { make in
                make.top.equalTo(inset.top)
                make.bottom.equalToSuperview().inset(inset.bottom)
                make.centerX.equalToSuperview()
                make.left.greaterThanOrEqualToSuperview().offset(inset.left)
                make.right.lessThanOrEqualToSuperview().inset(inset.right)
            }
        case .left:
            stackView.pk.remakeConstraints { make in
                make.top.equalTo(inset.top)
                make.bottom.equalToSuperview().inset(inset.bottom)
                make.left.equalTo(inset.left)
                make.right.lessThanOrEqualToSuperview().inset(inset.right)
            }
        case .right:
            stackView.pk.remakeConstraints { make in
                make.top.equalTo(inset.top)
                make.bottom.equalToSuperview().inset(inset.bottom)
                make.left.greaterThanOrEqualToSuperview().offset(inset.left)
                make.right.equalToSuperview().inset(inset.right)
            }
        }
    }
    
    private func contentVerticalLayoutUpdates() {
        let inset = contentEdgeInsets
        switch contentVerticalAlignment {
        case .nature, .spaceBetween:
            stackView.pk.remakeConstraints { make in
                make.left.equalTo(inset.left)
                make.right.equalToSuperview().inset(inset.right)
                make.top.equalTo(inset.top)
                make.bottom.equalToSuperview().inset(inset.bottom)
            }
        case .center:
            stackView.pk.remakeConstraints { make in
                make.left.equalTo(inset.left)
                make.right.equalToSuperview().inset(inset.right)
                make.centerY.equalToSuperview()
                make.top.greaterThanOrEqualToSuperview().offset(inset.top)
                make.bottom.lessThanOrEqualToSuperview().inset(inset.bottom)
            }
        case .top:
            stackView.pk.remakeConstraints { make in
                make.left.equalTo(inset.left)
                make.right.equalToSuperview().inset(inset.right)
                make.top.equalTo(inset.top)
                make.bottom.lessThanOrEqualToSuperview().inset(inset.bottom)
            }
        case .bottom:
            stackView.pk.remakeConstraints { make in
                make.left.equalTo(inset.left)
                make.right.equalToSuperview().inset(inset.right)
                make.top.greaterThanOrEqualToSuperview().offset(inset.top)
                make.bottom.equalToSuperview().inset(inset.bottom)
            }
        }
    }
    
    private func imageFixedSizeUpdates() {
        imageView.pk.updateConstraints { make in
            make.size.equalTo(imageFixedSize)
        }
    }
    
    open override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        guard adjustsRoundedCornersAutomatically else { return }
        layer.cornerRadius = bounds.height / 2
    }
    
    private func getResponseRect() -> CGRect {
        guard touchResponseInsets != UIEdgeInsets.zero else {
            return bounds
        }
        return CGRect(x: bounds.minX - touchResponseInsets.left,
                      y: bounds.minY - touchResponseInsets.top,
                      width: bounds.width + touchResponseInsets.left + touchResponseInsets.right,
                      height: bounds.height + touchResponseInsets.top + touchResponseInsets.bottom)
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let rect = getResponseRect()
        guard rect.equalTo(bounds) else {
            return rect.contains(point)
        }
        return super.point(inside: point, with: event)
    }
}

// - MARK: ANGradientView -

@objc open class ANGradientView: UIView {
    
    /// 线性渐变方向
    public enum GradientDirection {
        /// 从左到右渐变
        case leftToRight
        /// 从右到左渐变
        case rightToLeft
        /// 从上到下渐变
        case topToBottom
        /// 从下到上渐变
        case bottomToTop
        /// 从左上到右下渐变
        case leftTopToRightBottom
        /// 从左下到右上渐变
        case leftBottomToRightTop
        /// 从右上到左下渐变
        case rightTopToLeftBottom
        /// 从右下到左上渐变
        case rightBottomToLeftTop
    }
    
    /// 线性渐变方向
    public var gradientDirection: GradientDirection = .leftToRight {
        didSet {
            setLinear(gradientDirection)
        }
    }
    
    /// 渐变色数组
    public var gradientClolors: [NSUIColor?]? {
        didSet {
            setColors(gradientClolors)
        }
    }
    
    /// 渐变路径
    public var gradientPath: CGPath? {
        didSet {
            setPath(gradientPath)
        }
    }
    
    open class override var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    private var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    private func setLinear(_ direction: GradientDirection) {
        switch direction {
        case .leftToRight:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        case .rightToLeft:
            gradientLayer.startPoint = CGPoint(x: 1, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0, y: 0)
        case .topToBottom:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        case .bottomToTop:
            gradientLayer.startPoint = CGPoint(x: 0, y: 1)
            gradientLayer.endPoint = CGPoint(x: 0, y: 0)
        case .leftTopToRightBottom:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        case .leftBottomToRightTop:
            gradientLayer.startPoint = CGPoint(x: 0, y: 1)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        case .rightTopToLeftBottom:
            gradientLayer.startPoint = CGPoint(x: 1, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        case .rightBottomToLeftTop:
            gradientLayer.startPoint = CGPoint(x: 1, y: 1)
            gradientLayer.endPoint = CGPoint(x: 0, y: 0)
        }
    }
    
    private func setColors(_ colors: [NSUIColor?]?) {
        gradientLayer.colors = colors?.map { $0?.cgColor ?? NSUIColor.black.cgColor }
    }
    
    private lazy var maskLayer: ANShapeLayer = {
        let maskLayer = ANShapeLayer()
        maskLayer.fillColor = NSUIColor.white.cgColor
        maskLayer.strokeColor = NSUIColor.clear.cgColor
        maskLayer.lineJoin  = .bevel
        maskLayer.lineCap = .square
        maskLayer.lineWidth = 0
        return maskLayer
    }()
    
    private func setPath(_ path: CGPath?) {
        guard
            let cgPath = gradientPath,
            let colors = gradientClolors, !colors.isEmpty else {
            clear()
            return
        }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.mask = maskLayer
        maskLayer.path = cgPath
        CATransaction.commit()
    }
    
    private func clear() {
        maskLayer.path = nil
        gradientLayer.mask = nil
        gradientLayer.colors = nil
        gradientLayer.backgroundColor = nil
    }
}
