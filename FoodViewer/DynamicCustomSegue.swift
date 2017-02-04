//
//  DynamicCustomSegue.swift
//  FoodViewer
//
//  Created by arnaud on 03/02/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

class DynamicCustomSegue: UIStoryboardSegue {
    
    override func perform() {
        if let svc = self.source as? IdentificationTableViewController,
            let pvc = self.destination as? MainLanguageViewController {
            // Present the view controller using the popover style
            pvc.modalPresentationStyle = UIModalPresentationStyle.popover
            svc.present(pvc, animated: true, completion: nil)
            if let selectedIndexPath = svc.tableView.indexPathForSelectedRow {
                // Get the popover presentation controller and configure it
                if let cell = svc.tableView.cellForRow(at: selectedIndexPath) as? BarcodeTableViewCell {
                    if let presentationController = pvc.popoverPresentationController {
                        presentationController.permittedArrowDirections = .any
                        presentationController.sourceView = svc.tableView
                        presentationController.sourceRect = cell.frame
                    }
                }
            }
        }
    }
}
