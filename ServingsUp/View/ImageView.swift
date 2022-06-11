//
//  ImageView.swift
//  ServingsUp
//
//  Created by Elias Hall on 4/19/22.
//  Copyright © 2022 Elias Hall. All rights reserved.
//

import Foundation
import UIKit

final class ImageView: UIImageView {
    
    override var image: UIImage? {
        didSet { //if image is present border will be present
            if image != nil {
                layer.borderWidth = 0.5
            } else if image == nil {
                layer.borderWidth = 0.0
            }
        }
    }
    
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
        layer.cornerRadius = 15
    }
}

