//
//  TblImageView.swift
//  ServingsUp
//
//  Created by Elias Hall on 5/7/22.
//  Copyright © 2022 Elias Hall. All rights reserved.
//

import Foundation
import UIKit

final class TblImageView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setUp()
    }
    
    func setUp() {
        self.clipsToBounds = true
        layer.cornerRadius = 15.0
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 0.5
    }
    
    func removeBorder() {
        layer.borderWidth = 0.0
    }
}
