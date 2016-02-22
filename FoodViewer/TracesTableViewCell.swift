//
//  TracesTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 05/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit
import TagListView

class TracesTableViewCell: UITableViewCell {
    
    private struct Constants {
        static let NoInformation = "No Traces specified"
    }
    
    @IBOutlet weak var tracesTagListView: TagListView! {
        didSet {
            tracesTagListView.textFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            tracesTagListView.alignment = .Center
            tracesTagListView.cornerRadius = 10
        }
    }
    
    var product: FoodProduct? = nil {
        didSet {
            tracesTagListView.removeAllTags()
            if let traces = product?.traces {
                tracesTagListView.tagBackgroundColor = UIColor.greenColor()
                for trace in traces {
                    tracesTagListView.addTag(trace)
                }
            } else {
                tracesTagListView.tagBackgroundColor = UIColor.orangeColor()
                tracesTagListView.addTag(Constants.NoInformation)
            }
        }
    }

}
