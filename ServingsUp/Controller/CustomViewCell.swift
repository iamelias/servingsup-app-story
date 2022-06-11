//
//  CustomViewCell.swift
//  ServingsUp
//
//  Created by Elias Hall on 5/7/22.
//  Copyright © 2022 Elias Hall. All rights reserved.
//

import Foundation
import UIKit

class CustomViewCell: UITableViewCell {
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var cellLabel: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
