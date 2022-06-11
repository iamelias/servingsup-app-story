//
//  RoundButton.swift
//  ServingsUp
//
//  Created by Elias Hall on 4/19/22.
//  Copyright © 2022 Elias Hall. All rights reserved.
//

import Foundation
import UIKit

final class RoundButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override var isHighlighted: Bool {
        didSet {
            layer.opacity = isHighlighted ? 0.9 : 1.0
        }
    }
    
    override var titleLabel: UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .heavy)
        return label
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
        layer.borderColor = UIColor.black.cgColor
        layer.shadowRadius = 2.0
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        layer.shadowOpacity = 0.5
        layer.masksToBounds = false
    }
}
