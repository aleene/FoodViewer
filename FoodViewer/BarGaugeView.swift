//
//  BarGaugeView.swift
//  BarGaugeViewDemo
//
//  Created by arnaud on 28/04/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

class BarGaugeView: UIView {

    private var _iOnIdx: Float = 0.0                // Point at which segments are on
    private var _iOffIdx: Float = 0.0               // Point at which segments are off
    private var _iPeakBarIdx: Int? = nil            // Index of peak value segment
    private var _iWarningBarIdx : Int? {            // Index of first warning segment
        return self.warnThreshold != nil && self.warnThreshold! > 0.0  ?
            Int((self.warnThreshold! - self.minLimit) / self.maxLimit * Float(self.numBars) ) : nil
    }
    private var _iDangerBarIdx : Int? {             // Index of first danger segment
        return self.dangerThreshold != nil && self.dangerThreshold! > 0.0 ?
            Int( (self.dangerThreshold! - self.minLimit) / self.maxLimit * Float(self.numBars) ) : nil
    }
    
    public var value: Float = 0.0 {
        didSet {
            var fRedraw = false

            // Point at which bars start lighting up
            let iOnIdx = self.value >= self.minLimit ?  0.0 : Float(self.numBars)
            if( iOnIdx != _iOnIdx ) {
                // Changed - save it
                _iOnIdx = iOnIdx;
                fRedraw = true;
            }
            
            // Point at which bars are no longer lit
            let iOffIdx = ((self.value - self.minLimit) / (self.maxLimit - self.minLimit)) * Float(self.numBars)
            if( iOffIdx != _iOffIdx ) {
                // Changed - save it
                _iOffIdx = iOffIdx;
                fRedraw = true;
            }
            
            // Are we doing peak?
            if self.holdPeak {
                if let existingPeakValue = self.peakValue {
                    if self.value > existingPeakValue {
                        self.peakValue = self.value
                        _iPeakBarIdx = min(Int(_iOffIdx), self.numBars - 1)
                    }
                } else {
                    // Yes, save the peak bar index
                    self.peakValue = self.value;
                    _iPeakBarIdx = min(Int(_iOffIdx), self.numBars - 1)
                }
            }
            
            // Redraw the display?
            if( fRedraw ) {
                // Do it
                self.setNeedsDisplay()
            }
        }
        
    }
    

    public var warnThreshold: Float? = 0.60
    public var dangerThreshold: Float? = 0.80
    public var maxLimit: Float = 1.0
    public var minLimit: Float = 0.0
    public var numBars: Int = 10 {
        didSet {
            self.peakValue = nil
        }
    }
    public var peakValue: Float? = nil
    public var holdPeak  = false
    public var litEffect = true
    public var reverse = false
    public var outerBorderColor: UIColor = .gray
    public var innerBorderColor: UIColor = .black
    public var innerBorderLineWidth: Float = 1.0
    public var outerBorderLineWidth: Float = 2.0
    public var outerBorderInsetWidth: Float = 1.0
    public var myBackgroundColor: UIColor = .black
    public var normalBarColor: UIColor = .systemGreen
    public var warningBarColor: UIColor = .systemYellow
    public var dangerBarColor: UIColor = .systemRed
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setDefaults()
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setDefaults()
    }
    
    func resetPeak()
    {
        self.peakValue = nil
        _iPeakBarIdx = nil
        self.setNeedsDisplay()
    }
    
    private func setDefaults()
    {
        if #available(iOS 13.0, *) {
            self.backgroundColor = .systemBackground
        } else {
            self.backgroundColor = .white
        }
        // Misc.
        self.clearsContextBeforeDrawing = false
        self.isOpaque = false
    }
    
    
    //-----------------------------------------------------------------------
    //    Draw the gauge
    //
    override func draw(_ rect: CGRect)
    {
        var rectBounds = CGRect.init()
        var rectBar = CGRect.init()
        var iBarSize = 0
        
        // How is the bar oriented?
        rectBounds = self.bounds;
        let fIsVertical = (rectBounds.size.height >= rectBounds.size.width)
        if(fIsVertical) {
            // Adjust height to be an exact multiple of bar
            iBarSize = Int(rectBounds.size.height) / self.numBars
            rectBounds.size.height  = CGFloat(iBarSize * self.numBars)
        }
        else {
            // Adjust width to be an exact multiple
            iBarSize = Int(rectBounds.size.width) / self.numBars
            rectBounds.size.width = CGFloat(iBarSize * self.numBars)
        }
        
        // Compute size of bar
        rectBar.size.width  = fIsVertical ? rectBounds.size.width - CGFloat(self.innerBorderLineWidth * 2) : CGFloat(iBarSize)
        rectBar.size.height = (fIsVertical) ? CGFloat(iBarSize) : rectBounds.size.height - CGFloat(self.innerBorderLineWidth * 2);
        
        // Get stuff needed for drawing
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.clear(self.bounds)
        
        // Fill background
        ctx?.setFillColor(self.myBackgroundColor.cgColor)
        ctx?.fill(rectBounds)
        
        // Draw LED bars
        ctx?.setFillColor(self.innerBorderColor.cgColor)
        ctx?.setLineWidth(CGFloat(self.innerBorderLineWidth))
        for iX in 0..<self.numBars {
            // Determine position for this bar
            if self.reverse {
                // if(_reverse) {
                // Top-to-bottom or right-to-left
                rectBar.origin.x = (fIsVertical) ? rectBounds.origin.x + 1.0 : (rectBounds.maxX - (CGFloat(iX) + 1.0) * CGFloat(iBarSize))
                rectBar.origin.y = (fIsVertical) ? (rectBounds.minY + CGFloat(iX * iBarSize)) : rectBounds.origin.y + CGFloat(self.innerBorderLineWidth)
            }
            else {
                // Bottom-to-top or right-to-left
                rectBar.origin.x = (fIsVertical) ? rectBounds.origin.x + 1.0 : (rectBounds.minX + CGFloat(iX * iBarSize))
                rectBar.origin.y = (fIsVertical) ? (rectBounds.maxY - (CGFloat(iX) + CGFloat(self.innerBorderLineWidth)) * CGFloat(iBarSize)) : rectBounds.origin.y + CGFloat(self.innerBorderLineWidth)
            }
            
            // Draw top and bottom borders for bar
            ctx?.addRect(rectBar)
            ctx?.strokePath()
            
            // Determine color of bar
            var clrFill = self.normalBarColor
            if _iDangerBarIdx != nil && iX >= _iDangerBarIdx! {
                clrFill = self.dangerBarColor
            }
            else if _iWarningBarIdx != nil && iX >= _iWarningBarIdx! {
                clrFill = self.warningBarColor
            }
            
            // Determine if bar should be lit
            let fLit = (iX >= Int(_iOnIdx) && iX < Int(_iOffIdx)) || (_iPeakBarIdx != nil && iX == _iPeakBarIdx!)
            
            // Fill the interior of the bar
            ctx?.saveGState()
            let rectFill = rectBar.insetBy(dx: CGFloat(self.innerBorderLineWidth), dy: CGFloat(self.innerBorderLineWidth))
            let clipPath = CGPath.init(rect: rectFill, transform: .none)
            ctx?.addPath(clipPath)
            ctx?.clip()
            self.drawBar(ctx, with: rectFill, and: clrFill, isLit: fLit)
            ctx?.restoreGState()
        }
        
        // Draw border around the control
        ctx?.setStrokeColor(self.outerBorderColor.cgColor)
        ctx?.setLineWidth(CGFloat(outerBorderLineWidth))
        // if I add an inset there will be a black line around this outer border
        ctx?.addRect(rectBounds.insetBy(dx: CGFloat(self.outerBorderInsetWidth), dy: CGFloat(self.outerBorderInsetWidth)))
        ctx?.strokePath()
    }
    
    
    //    This method draws a bar
    //
    private func drawBar(_ a_ctx: CGContext?, with a_rect: CGRect, and a_color: UIColor, isLit lit: Bool) {
        // Is the bar lit?
        if lit {
            // Are we doing radial gradient fills?
            if litEffect {
                // Yes, set up to draw the bar as a radial gradient
                
                let nu_locations = 2
                let locations: [CGFloat] = [0.0, 0.5]
                var aComponents: [CGFloat] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                let clr = a_color.cgColor
                
                // Set up color components from passed UIColor object
                if clr.numberOfComponents == 4 {
                    // Extract the components
                    aComponents[0] = clr.components![0]
                    aComponents[1] = clr.components![1]
                    aComponents[2] = clr.components![2]
                    aComponents[3] = clr.components![3]
                    aComponents[4] = aComponents[0] - ((aComponents[0] > 0.3) ? 0.3 : 0.0);
                    aComponents[5] = aComponents[1] - ((aComponents[1] > 0.3) ? 0.3 : 0.0);
                    aComponents[6] = aComponents[2] - ((aComponents[2] > 0.3) ? 0.3 : 0.0);
                    aComponents[7] = aComponents[3];
                }
                
                let width = a_rect.width
                let height = a_rect.height
                let radius = sqrt( width * width + height * height )
                
                let myColorspace = CGColorSpaceCreateDeviceRGB()
                if let myGradient = CGGradient.init(colorSpace: myColorspace,
                                                    colorComponents: aComponents,
                                                    locations: locations,
                                                    count: nu_locations) {
                    let myStartPoint = CGPoint.init(x: a_rect.midX, y: a_rect.midY)
                    a_ctx?.drawRadialGradient(myGradient,
                                              startCenter: myStartPoint,
                                              startRadius: 0.0,
                                              endCenter: myStartPoint,
                                              endRadius: radius,
                                              options: CGGradientDrawingOptions(rawValue: 0))
                }
            }
            else {
                // No, solid fill
                a_ctx?.setFillColor(a_color.cgColor)
                a_ctx?.fill(a_rect)
            }
        }
        else {
            // No, draw the bar as background color overlayed with a mostly
            // ... transparent version of the passed color
            let fillClr = a_color.withAlphaComponent(0.2)
            a_ctx?.setFillColor(myBackgroundColor.cgColor)
            a_ctx?.fill(a_rect)
            a_ctx?.setFillColor(fillClr.cgColor)
            a_ctx?.fill(a_rect)
        }
    }
    
}
