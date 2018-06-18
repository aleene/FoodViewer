//
//  TDBadgedCell.swift
//  TDBadgedCell
//
//  Created by Tim Davies on 07/09/2016.
//  https://github.com/tmdvs/TDBadgedCell
//  Copyright © 2016 Tim Davies. All rights reserved.
//

import UIKit

/// TDBadgedCell is a table view cell class that adds a badge, similar to the badges in Apple's own apps
/// The badge is generated as image data and drawn as a sub view to the table view cell. This is hopefully
/// most resource effective that a manual draw(rect:) call would be

class TDBadgedCell: UITableViewCell {
    
    /// Badge value
    public var badgeString : String = "" {
        didSet {
            if badgeString.isEmpty {
                badgeView.removeFromSuperview()
                layoutSubviews()
            } else {
                contentView.addSubview(badgeView)
                drawBadge()
            }
        }
    }
    
    private struct Constant {
        static let BadgeRadius = 20
        struct Margin {
            struct Text {
                static let Height: CGFloat = 5.0
                static let Width: CGFloat = 8.0
            }
            static let Horizontal: CGFloat = 8.0
        }
    }
    /// Badge background color for normal states
    public var badgeColor : UIColor = UIColor(red: 0, green: 0.478, blue: 1, alpha: 1.0) // 007AFF
    /// Badge background color for highlighted states
    public var badgeColorHighlighted : UIColor = .darkGray
    
    /// Badge font size
    //public var badgeFontSize : Float = 11.0
    /// Badge text color
    public var badgeTextColor: UIColor?
    /// Corner radius of the badge. Set to 0 for square corners.
    //public var badgeRadius : Float = 20
    /// The Badges offset from the right hand side of the Table View Cell
    //public var badgeOffset = CGPoint(x:10, y:0)
    
    /// The Image view that the badge will be rendered into
    internal let badgeView = UIImageView()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Layout our badge's position
        var offsetX = Constant.Margin.Horizontal //badgeOffset.x
        if isEditing == false && accessoryType != .none || accessoryView != nil {
            offsetX = 0 // Accessory types are a pain to get sizing for?
        }
        
        badgeView.frame.origin.x = floor(contentView.frame.width - badgeView.frame.width - offsetX)
        badgeView.frame.origin.y = floor((frame.height / 2) - (badgeView.frame.height / 2))
//print(contentView.frame, badgeView.frame)
        // Now lets update the width of the cells text labels to take the badge into account
        textLabel?.frame.size.width -= badgeView.frame.width + (offsetX * 2)
        if detailTextLabel != nil {
            detailTextLabel?.frame.size.width -= badgeView.frame.width + (offsetX * 2)
        }
    }
    
    // When the badge
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        drawBadge()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        drawBadge()
    }
    
    /// Generate the badge image
    internal func drawBadge() {
        // Calculate the size of our string
        let textSize : CGSize = NSString(string: badgeString).size(withAttributes:[NSAttributedStringKey.font:UIFont.preferredFont(forTextStyle: .caption1)])
        textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        // Create a frame with padding for our badge
        let height = textSize.height + Constant.Margin.Text.Height * 2
        var width = textSize.width + Constant.Margin.Text.Width * 2
        if width < height {
            width = height
        }
        let badgeFrame : CGRect = CGRect(x:0, y:0, width:width, height:height)
        
        let badge = CALayer()
        badge.frame = badgeFrame
        
        if isHighlighted || isSelected {
            badge.backgroundColor = badgeColorHighlighted.cgColor
        } else {
            badge.backgroundColor = badgeColor.cgColor
        }
        
        badge.cornerRadius = CGFloat(Constant.BadgeRadius) < (badge.frame.size.height / 2) ? CGFloat(Constant.BadgeRadius) : CGFloat(badge.frame.size.height / 2)
        
        // Draw badge into graphics context
        UIGraphicsBeginImageContextWithOptions(badge.frame.size, false, UIScreen.main.scale)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.saveGState()
        badge.render(in:ctx)
        ctx.saveGState()
        
        // Draw string into graphics context
        if badgeTextColor == nil { ctx.setBlendMode(CGBlendMode.clear) }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        NSString(string: badgeString).draw(in:CGRect(x: Constant.Margin.Text.Width, y: Constant.Margin.Text.Height, width: textSize.width, height: textSize.height), withAttributes: [
            NSAttributedStringKey.font:UIFont.preferredFont(forTextStyle: .caption1),
            NSAttributedStringKey.foregroundColor: badgeTextColor ?? UIColor.clear,
            NSAttributedStringKey.paragraphStyle: paragraphStyle
            ])

        let badgeImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
//print(badgeString, badgeImage.size, self.textLabel?.frame)
        badgeView.frame = CGRect(x:0, y:0, width:badgeImage.size.width, height:badgeImage.size.height)
        //let oldFrame = textLabel?.frame ?? CGRect(x: 0, y: 0, width: 1, height: 1)
        
        //let newWidth = textLabel != nil ? textLabel!.frame.width - badgeImage.size.width : 0
        //let newFrame = CGRect(x:oldFrame.origin.x, y:oldFrame.origin.y, width:newWidth, height:oldFrame.height)
        //textLabel?.frame = newFrame
//print(badgeString, badgeImage.size, self.textLabel?.frame)
        badgeView.image = badgeImage
        
        layoutSubviews()
    }
}
