//
//  AddIngButton.swift
//  ServingsUp
//
//  Created by Elias Hall on 5/20/22.
//  Copyright © 2022 Elias Hall. All rights reserved.
//

import Foundation
import UIKit

final class AddIngButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override var isHighlighted: Bool {
        didSet {
            layer.opacity = isHighlighted ? 0.9 : 1.0
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        setUp()
        super.layoutSubviews()
    }
    
    func setUp() {
        self.clipsToBounds = true
        layer.cornerRadius = 8.0
        titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .heavy)
    }
}
