//
//  ContributorTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 17/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class ContributorTableViewCell: UITableViewCell {

    internal struct Notification {
        static let SearchContributorKey = "ContributorTableViewCell.Notification.SearchCOntributor.Key"
    }

    var contributor: FoodProduct.Contributor? = nil {
        didSet {
            if let existingContributor = contributor {
                nameLabel.text = existingContributor.name
                photographerLabel.isHidden = !existingContributor.role.isPhotographer
                correctorLabel.isHidden = !existingContributor.role.isCorrector
                editorLabel.isHidden = !existingContributor.role.isEditor
                informerLabel.isHidden = !existingContributor.role.isInformer
                creatorLabel.isHidden = !existingContributor.role.isCreator
            }
        }
    }

    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            // Long press allows to start a search
            let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ContributorTableViewCell.contributorLongPress))
            self.addGestureRecognizer(longPressGestureRecognizer)
        }
    }
    
    @IBOutlet weak var photographerLabel: UILabel! {
        didSet {
            photographerLabel.text = NSLocalizedString("📷", comment: "Image to indicate that the user took pictures of the product.")
        }
    }
    @IBOutlet weak var correctorLabel: UILabel! {
        didSet {
            correctorLabel.text = NSLocalizedString("🔦", comment: "Image to indicate that the user modified information of the product.")
        }
    }
    @IBOutlet weak var editorLabel: UILabel! {
        didSet {
            editorLabel.text = NSLocalizedString("📝", comment: "Image to indicate that the user who added or deleted information of the product.")
        }
    }
    @IBOutlet weak var informerLabel: UILabel! {
        didSet {
            informerLabel.text = NSLocalizedString("💭", comment: "Image to indicate that the user who added information to the product.")
        }
    }

    @IBOutlet weak var creatorLabel: UILabel! {
        didSet {
            creatorLabel.text = NSLocalizedString("❤️", comment: "Image to indicate that the user who created the product.")
        }
    }

    func contributorLongPress() {
        // I should encode the search component
        // And the search status
        guard contributor != nil else { return }
        let userInfo = [Notification.SearchContributorKey: contributor!.name]
        NotificationCenter.default.post(name: .LongPressInContributorCell, object: nil, userInfo: userInfo)
    }

}

// Definition:
extension Notification.Name {
    static let LongPressInContributorCell = Notification.Name("StateTableViewCell.Notification.LongPressInContributorCell")
}
