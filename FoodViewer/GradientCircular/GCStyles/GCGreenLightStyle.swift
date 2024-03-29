//
//  GreenLightStyle.swift
//  GradientCircularProgress
//
//  Created by keygx on 2015/11/24.
//  Copyright (c) 2015年 keygx. All rights reserved.
//
import UIKit

public struct GCGreenLightStyle: GCStyleProperty {
    // Progress Size
    public var progressSize: CGFloat = 80.0
    
    // Gradient Circular
    public var arcLineWidth: CGFloat = 14.0
    public var startArcColor: UIColor = GCColorUtil.toUIColor(r: 40.0, g: 110.0, b: 60.0, a: 1.0)
    public var endArcColor: UIColor = .green
    
    // Base Circular
    public var baseLineWidth: CGFloat? = 1.0
    public var baseArcColor: UIColor? = UIColor(red:0.0, green: 0.0, blue: 0.0, alpha: 0.1)
    
    // Ratio
    public var ratioLabelFont: UIFont? = UIFont(name: "Verdana-Bold", size: 14.0)
    public var ratioLabelFontColor: UIColor? = .darkGray
    
    // Message
    public var messageLabelFont: UIFont? = UIFont(name: "Verdana", size: 18.0)
    public var messageLabelFontColor: UIColor? = .darkGray
    
    // Background
    public var backgroundStyle: GCBackgroundStyles = .light
    
    // Dismiss
    public var dismissTimeInterval: Double? = nil // 'nil' for default setting.
    
    public init() {}
}
