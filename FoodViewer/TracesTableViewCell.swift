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
    
    @IBOutlet weak var tracesTagListView: TagListView! {
        didSet {
            tracesTagListView.textFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            tracesTagListView.alignment = .Center
        }
    }
    
    var product: FoodProduct? = nil {
        didSet {
            if let traces = product?.traces {
                    tracesTagListView.removeAllTags()
                    for trace in traces {
                        tracesTagListView.addTag(trace)
                    }
            }
        }
    }

}
