//
//  GKCropBorderView.swift
//  GKImagePickerSwift
//
//
//  Created by Georg Kitz on 6/1/12.
//  Copyright (c) 2012 Aurora Apps. All rights reserved.
//
//  Translated in Swift 3.0 by arnaud on 12/02/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation
import UIKit

class GKCropBorderView: UIView {
    
// This class draws the resizable border with its handles
    
    private struct Constant {
        static let kNumberOfBorderHandles = 8
        static let kHandleDiameter = 24
    }
    
    private var _calculateAllNeededHandleRects: [Any] = []

    // MARK: - inits
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - drawing

    override func draw(_ rect: CGRect) {
        // Drawing code
        if let ctx = UIGraphicsGetCurrentContext() {
            ctx.setStrokeColor(UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5).cgColor)
            ctx.setLineWidth(1.5)
            ctx.addRect(CGRect.init(x: CGFloat(Constant.kHandleDiameter / 2),
                                    y: CGFloat(Constant.kHandleDiameter / 2),
                                    width: rect.size.width - CGFloat(Constant.kHandleDiameter),
                                    height: rect.size.height - CGFloat(Constant.kHandleDiameter)
                )
            )
            ctx.strokePath()
    
            let handleRectArray = calculateAllNeededHandleRects()
            for handleRect in handleRectArray {
                ctx.setFillColor(UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.95).cgColor)
                ctx.fillEllipse(in: handleRect)
            }
        }
    }
    
    // MARK: - private
    
    private func calculateAllNeededHandleRects() -> [CGRect] {
    
        var a: [CGRect] = []

        // upper row
        a.append(CGRect.init(x: 0,
                             y: 0,
                             width: Constant.kHandleDiameter,
                             height: Constant.kHandleDiameter) )
        a.append(CGRect.init(x: Int(self.frame.size.width / 2) - Constant.kHandleDiameter / 2,
                             y: 0,
                             width: Constant.kHandleDiameter,
                             height: Constant.kHandleDiameter))
        a.append(CGRect.init(x: Int(self.frame.size.width) - Constant.kHandleDiameter,
                             y: 0,
                             width: Constant.kHandleDiameter,
                             height: Constant.kHandleDiameter) )
    
        a.append(CGRect.init(x: Int(self.frame.size.width) - Constant.kHandleDiameter,
                             y: Int(self.frame.size.height / 2) - Constant.kHandleDiameter / 2,
                             width: Constant.kHandleDiameter,
                             height: Constant.kHandleDiameter))
        a.append(CGRect.init(x: Int(self.frame.size.width) - Constant.kHandleDiameter,
                             y: Int(self.frame.size.height) - Constant.kHandleDiameter,
                             width: Constant.kHandleDiameter,
                             height: Constant.kHandleDiameter) )
        a.append(CGRect.init(x: Int(self.frame.size.width / 2) - Constant.kHandleDiameter / 2,
                             y: Int(self.frame.size.height) - Constant.kHandleDiameter,
                             width: Constant.kHandleDiameter,
                             height: Constant.kHandleDiameter) )
        a.append(CGRect.init(x: 0,
                             y: Int(self.frame.size.height) - Constant.kHandleDiameter,
                             width: Constant.kHandleDiameter,
                             height: Constant.kHandleDiameter) )
        //now back up again
        a.append(CGRect.init(x: 0,
                             y: Int(self.frame.size.height / 2) - Constant.kHandleDiameter / 2,
                             width: Constant.kHandleDiameter,
                             height: Constant.kHandleDiameter) )
    
        return a;
    }
    
}
