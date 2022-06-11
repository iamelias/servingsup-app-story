//
//  UIImageExt.swift
//  ServingsUp
//
//  Created by Elias Hall on 5/23/22.
//  Copyright © 2022 Elias Hall. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func fixImageOrientation() -> UIImage? { //vertical/normal orientation
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()
        guard let context = context else {
            return nil
        }
        context.translateBy(x: self.size.width/2, y: self.size.height/2)
        context.scaleBy(x: 1.0, y: 1.0)
        context.translateBy(x: -self.size.width/2, y: -self.size.height/2)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    func resizeImage() -> UIImage? {
        let oldWidth = self.size.width
        let scaleFactor = 90.0/oldWidth
        let newHeight = self.size.height * scaleFactor
        let newSize = CGSize(width: 90.0, height: newHeight)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image{(context) in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

extension UITableView {
    func deselectCellRow(animated: Bool)
    {
        if let indexPath = self.indexPathForSelectedRow {
            self.deselectRow(at: indexPath, animated: animated)
        }
    }
}

extension UIImageView {
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}
