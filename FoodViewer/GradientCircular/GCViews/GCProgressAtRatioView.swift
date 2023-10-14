//
//  ProgressAtRatioView.swift
//  GradientCircularProgress
//
//  Created by keygx on 2015/06/24.
//  Copyright (c) 2015年 keygx. All rights reserved.
//

import UIKit

class GCProgressAtRatioView: UIView {
    
    internal var arcView: GCArcView?
    internal var prop: GCProperty?
    internal var ratioLabel: UILabel?
    private var blurView: UIVisualEffectView?

    internal var ratio: CGFloat = 0.0 {
        didSet {
            ratioLabel?.text = String(format:"%.0f", ratio * 100) + "%"
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    public func setup(prop: GCProperty) {
        
        self.prop = prop
        layer.cornerRadius = self.frame.height/2
        layer.backgroundColor = UIColor.lightGray.cgColor
        ratioLabel = UILabel()
        if ratioLabel != nil {
            addSubview(ratioLabel!)
            ratioLabel!.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        }
        showRatio()
        backgroundColor = .clear
        layer.masksToBounds = true

        initialize(frame: frame)
        
        //getBlurView()
    }
    
    internal func initialize(frame: CGRect) {
        

        guard let prop = prop else {
            return
        }
        
        let rect: CGRect = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        
        // Base Circular
        if let baseLineWidth = prop.baseLineWidth, let baseArcColor = prop.baseArcColor {
            let circular: GCArcView = GCArcView(frame: rect, lineWidth: baseLineWidth)
            circular.prop = prop
            circular.ratio = 1.0
            circular.color = baseArcColor
            circular.lineWidth = baseLineWidth
            addSubview(circular)
        }
        
        // Gradient Circular
        if  GCColorUtil.toRGBA(color: prop.startArcColor).a < 1.0
            || GCColorUtil.toRGBA(color: prop.endArcColor).a < 1.0 {
            // Clear Color
            let gradient: UIView = GCGradientArcWithClearColorView().draw(rect: rect, prop: prop)
            addSubview(gradient)
            
            masking(rect: rect, prop: prop, gradient: gradient)
            
        } else {
            // Opaque Color
            let gradient: GCGradientArcView = GCGradientArcView(frame: rect)
            gradient.prop = prop
            addSubview(gradient)
            
            masking(rect: rect, prop: prop, gradient: gradient)
        }
    }
    
    private func masking(rect: CGRect, prop: GCProperty, gradient: UIView) {
        // Mask
        arcView = GCArcView(frame: rect, lineWidth: prop.arcLineWidth)
        
        guard let mask = arcView else {
            return
        }
        
        mask.prop = prop
        gradient.layer.mask = mask.layer
    }
    
    override func draw(_ rect: CGRect) {
        
        guard let mask = arcView else {
            return
        }
        
        if ratio > 1.0 {
            mask.ratio = 1.0
        } else {
            mask.ratio = ratio
        }
        mask.setNeedsDisplay()
    }
    
    public func showRatio() {
        
        guard let prop = prop else {
            return
        }
        // Progress Ratio
        ratioLabel?.font = prop.ratioLabelFont
        ratioLabel?.textAlignment = .center
        ratioLabel?.textColor = prop.ratioLabelFontColor
        //ratioLabel?.sizeToFit()
        //ratioLabel?.center = center
        //ratioLabel?.backgroundColor = .orange
    }
    
    private func getBlurView() {
        
        guard let prop = prop else {
            return
        }
        
        blurView = GCBackground().blurEffectView(fromBlurStyle: prop.backgroundStyle, frame: frame)
        
        guard let blurView = blurView else {
            return
        }
        
        backgroundColor = UIColor.clear
        addSubview(blurView)
    }

}
