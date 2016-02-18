//
//  ContributorTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 17/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class ContributorTableViewCell: UITableViewCell {

    var contributor: FoodProduct.Contributor? = nil {
        didSet {
            if let existingContributor = contributor {
                nameLabel.text = existingContributor.name
                photographerLabel.hidden = !existingContributor.role.isPhotographer
                correctorLabel.hidden = !existingContributor.role.isCorrector
                checkerLabel.hidden = !existingContributor.role.isChecker
                editorLabel.hidden = !existingContributor.role.isEditor
                informerLabel.hidden = !existingContributor.role.isInformer
                creatorLabel.hidden = !existingContributor.role.isCreator
            }
        }
    }

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var photographerLabel: UILabel! {
        didSet {
            photographerLabel.text = "📷"
        }
    }
    @IBOutlet weak var correctorLabel: UILabel! {
        didSet {
            correctorLabel.text = "🔦"
        }
    }
    @IBOutlet weak var checkerLabel: UILabel! {
        didSet {
            checkerLabel.text = "🔍"
        }
    }
    @IBOutlet weak var editorLabel: UILabel! {
        didSet {
            editorLabel.text = "📝"
        }
    }
    @IBOutlet weak var informerLabel: UILabel! {
        didSet {
            informerLabel.text = "💭"
        }
    }

    @IBOutlet weak var creatorLabel: UILabel! {
        didSet {
            creatorLabel.text = "❤️"
        }
    }

}
