//
//  ContributorTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 17/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class ContributorTableViewCell: UITableViewCell {

    var contributor: Contributor? = nil {
        didSet {
            if let existingContributor = contributor {
                nameLabel.text = existingContributor.name
                photographerLabel.isHidden = !existingContributor.isPhotographer
                correctorLabel.isHidden = !existingContributor.isCorrector
                editorLabel.isHidden = !existingContributor.isEditor
                informerLabel.isHidden = !existingContributor.isInformer
                creatorLabel.isHidden = !existingContributor.isCreator
                
                if !nameLabel.isHidden {
                    // Long press allows to start a search
                    let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ContributorTableViewCell.contributorLongPress))
                    nameLabel.addGestureRecognizer(longPressGestureRecognizer)
                }
                nameLabel.isUserInteractionEnabled = !nameLabel.isHidden
                
                /* not yet available by OFF
                if !creatorLabel.isHidden {
                    let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ContributorTableViewCell.creatorLongPress))
                    creatorLabel.addGestureRecognizer(longPressGestureRecognizer)
                }
                creatorLabel.isUserInteractionEnabled = !creatorLabel.isHidden
                */
                
                if !informerLabel.isHidden {
                    let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ContributorTableViewCell.informerLongPress))
                    informerLabel.addGestureRecognizer(longPressGestureRecognizer)
                }
                informerLabel.isUserInteractionEnabled = !informerLabel.isHidden
                
                if !editorLabel.isHidden {
                    let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ContributorTableViewCell.editorLongPress))
                    editorLabel.addGestureRecognizer(longPressGestureRecognizer)
                }
                editorLabel.isUserInteractionEnabled = !editorLabel.isHidden
                
                if !photographerLabel.isHidden {
                    let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ContributorTableViewCell.photographerLongPress))
                    photographerLabel.addGestureRecognizer(longPressGestureRecognizer)
                }
                photographerLabel.isUserInteractionEnabled = !photographerLabel.isHidden
                
                if !correctorLabel.isHidden {
                    let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ContributorTableViewCell.correctorLongPress))
                    correctorLabel.addGestureRecognizer(longPressGestureRecognizer)
                }
                correctorLabel.isUserInteractionEnabled = !correctorLabel.isHidden

            }
        }
    }

    var delegate: ProductPageViewController? = nil

    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
        }
    }
    
    @IBOutlet weak var photographerLabel: UILabel! {
        didSet {
            photographerLabel.text = TranslatableStrings.PhotographerUnicode
        }
    }
    @IBOutlet weak var correctorLabel: UILabel! {
        didSet {
            correctorLabel.text = TranslatableStrings.CorrectorUnicode
        }
    }
    @IBOutlet weak var editorLabel: UILabel! {
        didSet {
            editorLabel.text = TranslatableStrings.EditorUnicode
        }
    }
    @IBOutlet weak var informerLabel: UILabel! {
        didSet {
            informerLabel.text = TranslatableStrings.InformerUnicode
        }
    }

    @IBOutlet weak var creatorLabel: UILabel! {
        didSet {
            creatorLabel.text = TranslatableStrings.CreatorUnicode
        }
    }

    func contributorLongPress() {
        // I should encode the search component
        // And the search status
        guard contributor != nil else { return }
        delegate?.search(for: contributor!.name, in: .contributor)
    }

    func creatorLongPress() {
        // I should encode the search component
        // And the search status
        guard contributor != nil else { return }
        delegate?.search(for: contributor!.name, in: .creator)
    }
    
    func photographerLongPress() {
        // I should encode the search component
        // And the search status
        guard contributor != nil else { return }
        delegate?.search(for: contributor!.name, in: .photographer)
    }

    func informerLongPress() {
        // I should encode the search component
        // And the search status
        guard contributor != nil else { return }
        delegate?.search(for: contributor!.name, in: .informer)
    }

    func editorLongPress() {
        // I should encode the search component
        // And the search status
        guard contributor != nil else { return }
        delegate?.search(for: contributor!.name, in: .editor)
    }

    func correctorLongPress() {
        // I should encode the search component
        // And the search status
        guard contributor != nil else { return }
        delegate?.search(for: contributor!.name, in: .corrector)
    }

}

