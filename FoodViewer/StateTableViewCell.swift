//
//  StateTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 12/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class StateTableViewCell: UITableViewCell {

    internal struct Notification {
        static let SearchStatusKey = "StateTableViewCell.Notification.SearchStatus.Key"
    }

    var state: Bool = false {
        didSet {
            setImage()
        }
    }
    
    var searchString: String? = nil
    
    var stateTitle: String? = nil {
        didSet {
            var stateLabelText = stateTitle != nil ? stateTitle! : NSLocalizedString("none", comment: "Text for a cell, when no status title has been provided, such as 'completed', etc.")
            // add a question mark
            stateLabelText += "?"
            stateLabel.text = stateLabelText
        }
    }
    
    @IBOutlet weak var stateLabel: UILabel! {
        didSet {
            // Long press allows to start a search
            let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(StateTableViewCell.stateLongPress))
                self.addGestureRecognizer(longPressGestureRecognizer)

        }
    }
    
    @IBOutlet weak var stateImage: UIImageView! {
        didSet {
            setImage()
        }
    }
    
    private func setImage() {
        stateImage?.image = state ? UIImage.init(named: "OK") : UIImage.init(named: "NotOK")
    }
    
    func stateLongPress() {
        // I should encode the search component
        // And the search status
        guard searchString != nil else { return }
        let userInfo = [Notification.SearchStatusKey: searchString!]
        NotificationCenter.default.post(name: .LongPressInStateCell, object: nil, userInfo: userInfo)
    }

}

// Definition:
extension Notification.Name {
    static let LongPressInStateCell = Notification.Name("StateTableViewCell.Notification.LongPressInStateCell")
}

