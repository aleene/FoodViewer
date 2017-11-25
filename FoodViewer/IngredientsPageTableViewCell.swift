//
//  IngredientsPageTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 20/08/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

class IngredientsPageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ingredientsLabel: UILabel!
    
    @IBOutlet weak var allergensLabel: UILabel!

    @IBOutlet weak var tracesLabel: UILabel!
    
    /// Badge value
    public var ingredientsBadgeString : String = "" {
        didSet {
            if ingredientsBadgeString.isEmpty {
                ingredientsBadgeView.removeFromSuperview()
                layoutSubviews()
            } else {
                let accessoryOffset: CGFloat = accessoryView != nil ? 13 : 3
                contentView.addSubview(ingredientsBadgeView)
                ingredientsBadgeView.image = draw(with: ingredientsBadgeString)
                ingredientsBadgeView.frame = CGRect(
                    x:ingredientsLabel.frame.width + ingredientsLabel.frame.origin.x + badgeOffset.x - accessoryOffset - ingredientsBadgeView.image!.size.width,
                    y:ingredientsLabel.frame.origin.y + (ingredientsLabel.frame.height - ingredientsBadgeView.frame.height ) / 2,
                    width:ingredientsBadgeView.image!.size.width,
                    height:ingredientsBadgeView.image!.size.height )
                // Now lets update the width of the cells text labels to take the badge into account
                ingredientsLabel.frame.size.width -= ingredientsBadgeView.frame.width + badgeOffset.x * 2
                layoutSubviews()
            }
        }
    }
    
    /// Badge value
    public var allergensBadgeString : String = "" {
        didSet {
            if(allergensBadgeString == "") {
                allergensBadgeView.removeFromSuperview()
                layoutSubviews()
            } else {
                let accessoryOffset: CGFloat = accessoryView != nil ? 13 : 3
                contentView.addSubview(allergensBadgeView)
                allergensBadgeView.image = draw(with: allergensBadgeString)
                allergensBadgeView.frame = CGRect(
                    x:allergensLabel.frame.width + allergensLabel.frame.origin.x + badgeOffset.x - accessoryOffset - allergensBadgeView.image!.size.width,
                    y:allergensLabel.frame.origin.y + (allergensLabel.frame.height - allergensBadgeView.frame.height ) / 2,
                    width:allergensBadgeView.image!.size.width,
                    height:allergensBadgeView.image!.size.height )
                // Now lets update the width of the cells text labels to take the badge into account
                allergensLabel.frame.size.width -= allergensBadgeView.frame.width + badgeOffset.x * 2
                layoutSubviews()
            }
        }
    }
    /// Badge value
    public var tracesBadgeString : String = "" {
        didSet {
            if(tracesBadgeString == "") {
                tracesBadgeView.removeFromSuperview()
                layoutSubviews()
            } else {
                let accessoryOffset: CGFloat = accessoryView != nil ? 13 : 3
                contentView.addSubview(tracesBadgeView)
                tracesBadgeView.image = draw(with: tracesBadgeString)
                tracesBadgeView.frame = CGRect(
                    x:tracesLabel.frame.width + tracesLabel.frame.origin.x + badgeOffset.x - accessoryOffset - tracesBadgeView.image!.size.width,
                    y:tracesLabel.frame.origin.y + (tracesLabel.frame.height - tracesBadgeView.frame.height ) / 2,
                    width:tracesBadgeView.image!.size.width,
                    height:tracesBadgeView.image!.size.height )
                // Now lets update the width of the cells text labels to take the badge into account
                tracesLabel.frame.size.width -= tracesBadgeView.frame.width + badgeOffset.x * 2
                layoutSubviews()
            }
        }
    }

    
    /// Badge background color for normal states
    public var badgeColor : UIColor = UIColor(red: 0, green: 0.478, blue: 1, alpha: 1.0) // 007AFF
    /// Badge background color for highlighted states
    public var badgeColorHighlighted : UIColor = .darkGray
    
    /// Badge font size
    public var badgeFontSize : Float = 11.0
    /// Badge text color
    public var badgeTextColor: UIColor?
    /// Corner radius of the badge. Set to 0 for square corners.
    public var badgeRadius : Float = 20
    /// The Badges offset from the right hand side of the Table View Cell
    public var badgeOffset = CGPoint(x:10, y:0)
    
    /// The imageViews that the badges will be rendered into
    internal var ingredientsBadgeView = UIImageView()
    internal var allergensBadgeView = UIImageView()
    internal var tracesBadgeView = UIImageView()
    
    // When the badge
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        // drawBadge()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // drawBadge()
    }
    
    
    /// Generate the badge image
    internal func draw(with text: String) -> UIImage {
        // Calculate the size of our string
        let textSize : CGSize = NSString(string: text).size(withAttributes:[NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize:CGFloat(badgeFontSize))])
        
        // Create a frame with padding for our badge
        let height = textSize.height + 10
        var width = textSize.width + 16
        if width < height  {
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
        
        badge.cornerRadius = (CGFloat(badgeRadius) < (badge.frame.size.height / 2)) ? CGFloat(badgeRadius) : CGFloat(badge.frame.size.height / 2)
        
        // Draw badge into graphics context
        UIGraphicsBeginImageContextWithOptions(badge.frame.size, false, UIScreen.main.scale)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.saveGState()
        badge.render(in:ctx)
        ctx.saveGState()
        
        // Draw string into graphics context
        if badgeTextColor == nil  {
            ctx.setBlendMode(CGBlendMode.clear)
        }
        
        NSString(string: text).draw(in:CGRect(x:8, y:5, width:textSize.width, height:textSize.height), withAttributes: [
            NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize:CGFloat(badgeFontSize)),
            NSAttributedStringKey.foregroundColor: badgeTextColor ?? UIColor.clear
            ])
        
        let badgeImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return badgeImage
    }

}
