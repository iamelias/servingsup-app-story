//
//  CustomNavController.swift
//  ServingsUp
//
//  Created by Elias Hall on 5/27/22.
//  Copyright © 2022 Elias Hall. All rights reserved.
//

import Foundation
import UIKit

class CustomNavController: UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
}
