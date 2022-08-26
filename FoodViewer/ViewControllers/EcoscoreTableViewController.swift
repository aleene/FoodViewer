//
//  EcoscoreTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 09/12/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

protocol EcoscoreCoordinatorProtocol {
    /**
    Inform the protocol delegate that the done button has been tapped.
    - Parameters:
         - sender : the `EcoscoreTableViewController` that called the function.
    */
    func ecoscoreViewControllerDidTapDone(_ sender: EcoscoreTableViewController)
}

class EcoscoreTableViewController: UITableViewController {

// MARK: - constants
    
    private let AgribalyseBaseUrl = "https://www.agribalyse.fr/app/aliments/"

// MARK: - storyboard
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var navBarTitle: UINavigationItem!
    
    @IBAction func doneBarButtonItemTapped(_ sender: UIBarButtonItem) {
        protocolCoordinator?.ecoscoreViewControllerDidTapDone(self)
    }
    
// MARK: - External properties

    var protocolCoordinator: EcoscoreCoordinatorProtocol? = nil
            
    /// The manager of this viewController and its protocol delegate
    weak var coordinator: Coordinator? = nil

// MARK: - External functions

/**
Configures the viewController with the ecoscore detail calculation data.
- parameters:
     -  ecoscoreData: the ecoscore detail calculation data;
*/
    public func configure(ecoscoreData: OFFProductEcoscoreData) {
        self.ecoscoreData = ecoscoreData
    }
        
// MARK: - private variables
    
    // The sections used in the tableView
    enum SectionType {
        case grade
        case agribalyse
        case species
        case packaging
        case productionSystem
        case transport
        
        static var sections: [SectionType] {
            return [.grade,
                    .agribalyse,
                    .productionSystem,
                    .species,
                    .transport,
                    .packaging]
        }
    }
    
    private var ecoscoreData: OFFProductEcoscoreData? = nil
              
    @objc func openAgribalyseCategory() {
        guard let ciqual = ecoscoreData?.agribalyse?.agribalyse_food_code else { return }
        guard let url = URL(string: AgribalyseBaseUrl + ciqual) else { return }
        
        if UIApplication.shared.canOpenURL(url){
            UIApplication.shared.open(url)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navBarTitle?.title = TranslatableStrings.EcoscoreDetailsTitle
        tableView?.dataSource = self
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
        
    override func viewDidDisappear(_ animated: Bool) {
        coordinator?.viewControllerDidDisappear(self)
        super.viewDidDisappear(animated)
    }
}

extension EcoscoreTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch SectionType.sections[section] {
        case .grade:
            return 1
        case .agribalyse:
            return 2
        case .species:
            return 1
        case .transport:
            var aantalCountries = 0
            if let countries = ecoscoreData?.adjustments?.origins_of_ingredients?.origins_from_origins_field {
                aantalCountries = countries.count
            }
            return aantalCountries + 2
        case .productionSystem:
            return 1
        case .packaging:
            var numberOfPackagingComponents = 0
            if let packagings = ecoscoreData?.adjustments?.packaging?.packagings {
                numberOfPackagingComponents = packagings.count
            }
            return numberOfPackagingComponents + 1
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return SectionType.sections.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 1
        numberFormatter.maximumFractionDigits = 1
        
        switch SectionType.sections[indexPath.section] {
        case .agribalyse:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetailTableViewCell.EcoscoreTableViewController", for: indexPath)
            switch indexPath.row {
            case 0:
                //cell.textLabel?.text = "Catégorie Agribalyse"
                if let ciqual = ecoscoreData?.agribalyse?.agribalyse_food_code {
                    let urlString = AgribalyseBaseUrl + ciqual
                    let tapGesture = UITapGestureRecognizer()
                    tapGesture.numberOfTouchesRequired = 1
                    tapGesture.addTarget(self, action: #selector(openAgribalyseCategory))
                    cell.detailTextLabel?.attributedText = NSAttributedString(string: ciqual, attributes: [NSAttributedString.Key.link: URL(string: urlString)!])
                    cell.detailTextLabel?.addGestureRecognizer(tapGesture)
                } else {
                    cell.detailTextLabel?.attributedText = NSAttributedString(string: "")
                }
                cell.textLabel?.text = ecoscoreData?.agribalyse?.agribalyse_food_name_en
            default:
                cell.textLabel?.text = TranslatableStrings.EcoscoreDetailsScoreACV
                if let validScore = ecoscoreData?.agribalyse?.score {
                    cell.detailTextLabel?.text = numberFormatter.string(from: NSNumber(value: validScore))
                } else {
                    cell.detailTextLabel?.text = TranslatableStrings.None
                }
            }
            return cell
        case .productionSystem:
            if let validLabel = ecoscoreData?.adjustments?.production_system?.label {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetailTableViewCell.EcoscoreTableViewController", for: indexPath)
                cell.textLabel?.text = validLabel
                if let validScore = ecoscoreData?.adjustments?.production_system?.value {
                    cell.detailTextLabel?.text = numberFormatter.string(from: NSNumber(value: validScore))
                } else {
                    cell.detailTextLabel?.text = ""
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCaptionTableViewCell.EcoscoreTableViewController", for: indexPath)
                cell.textLabel?.text = TranslatableStrings.EcoscoreNoLablesTakenIntoAccount
                return cell
            }
            
        case .transport:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetailTableViewCell.EcoscoreTableViewController", for: indexPath)
            let aantalRows = tableView.numberOfRows(inSection: indexPath.section)
            switch indexPath.row {
            case aantalRows - 1: // last row
                if let validScore = ecoscoreData?.adjustments?.origins_of_ingredients?.transportation_value {
                    cell.textLabel?.text = validScore < 0.0 ? TranslatableStrings.EcoscoreMalusTransport : TranslatableStrings.EcoscoreBonusTransport

                    cell.detailTextLabel?.text = numberFormatter.string(from: NSNumber(value: validScore))
                } else {
                    cell.textLabel?.text = TranslatableStrings.EcoscoreBonusMalusTransport
                    cell.detailTextLabel?.text = TranslatableStrings.Undefined
                }
            case aantalRows - 2:
                if let validScore = ecoscoreData?.adjustments?.origins_of_ingredients?.epi_value {
                    cell.textLabel?.text = validScore < 0.0
                        ? TranslatableStrings.EcoscoreMalusEnvironmentalPolitics
                        : TranslatableStrings.EcoscoreBonusEnvironmentalPolitics
                    cell.detailTextLabel?.text = numberFormatter.string(from: NSNumber(value: validScore))
                } else {
                    cell.textLabel?.text = TranslatableStrings.EcoscoreBonusMalusEnvironmentalPolitics
                    cell.detailTextLabel?.text = TranslatableStrings.Undefined
                }
            default:
                if let validScore = ecoscoreData?.adjustments?.origins_of_ingredients?.origins_from_origins_field {
                    cell.textLabel?.text = validScore[indexPath.row]
                    cell.detailTextLabel?.text = ""
                } else {
                    cell.textLabel?.text = TranslatableStrings.EcoscoreNoOriginsSpecified
                }
            }
            return cell
            
        case .species:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCaptionTableViewCell.EcoscoreTableViewController", for: indexPath)
            cell.textLabel?.text = TranslatableStrings.EcoscoreNoMenacedSpecies
            return cell
            
        case .packaging:
            let aantalRows = tableView.numberOfRows(inSection: indexPath.section)
            switch indexPath.row {
            case aantalRows - 1: // last row
                let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetailTableViewCell.EcoscoreTableViewController", for: indexPath)
                cell.textLabel?.text = TranslatableStrings.EcoscoreTotalOfAllPackagingParts
                if let validScore = ecoscoreData?.adjustments?.packaging?.value {
                    cell.detailTextLabel?.text = numberFormatter.string(from: NSNumber(value: validScore))
                } else {
                    cell.detailTextLabel?.text = TranslatableStrings.NoPackaging
                }
                return cell
            default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetailFootnoteTableViewCell.EcoscoreTableViewController", for: indexPath)
            if let validScore = ecoscoreData?.adjustments?.packaging?.packagings {
                cell.textLabel?.text = ( validScore[indexPath.row].material ?? TranslatableStrings.EcoscorePackagingOfUnrecognizedMaterial)
                        + " / " +
                    ( validScore[indexPath.row].shape ?? TranslatableStrings.EcoscorePackagingOfUnrecognizedShape )
                    if let materialScore = validScore[indexPath.row].ecoscore_material_score,
                        let materialRatio = validScore[indexPath.row].ecoscore_shape_ratio {
                        let malus = (materialScore - 100.0) * Double(materialRatio) / 10.0
                        cell.detailTextLabel?.text = numberFormatter.string(from: NSNumber(value: malus))
                    } else {
                        cell.detailTextLabel?.text = TranslatableStrings.EcoscoreNoTotalScore
                    }
                } else {
                    cell.textLabel?.text = TranslatableStrings.NoPackaging
                }
                return cell
            }

        case .grade:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: EcoscoreTableViewCell.self), for: indexPath) as! EcoscoreTableViewCell
            cell.ecoscore = ecoscoreData?.score
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch SectionType.sections[section] {
        case .agribalyse:
            return TranslatableStrings.EcoscoreHeaderReferenceScore
        case .productionSystem:
            return TranslatableStrings.EcoscoreHeaderProductionSystemImpact
        case .transport:
            return TranslatableStrings.EcoscoreHeaderOriginImpact
        case .species:
            return TranslatableStrings.EcoscoreHeaderMenacedSpeciesImpact
        case .packaging:
            return TranslatableStrings.EcoscoreHeaderPackagingImpact
        case .grade:
            return TranslatableStrings.EcoscoreHeaderFinalScore
        }
    }
}
