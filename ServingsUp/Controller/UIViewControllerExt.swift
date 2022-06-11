//
//  UIViewControllerExt.swift
//  ServingsUp
//
//  Created by Elias Hall on 5/8/22.
//  Copyright © 2022 Elias Hall. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    public func actionSheetiPadUpdate(actionSheet: UIAlertController) { //to prevent crash when using alert on iPad
        if let popoverPresentationController = actionSheet.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverPresentationController.permittedArrowDirections = []
        }
    }
}

