//
//  UIKit+Ext.swift
//  WeatherApp
//
//  Created by Ichsan Indra Wahyudi on 03/09/24.
//

import UIKit

extension UIImage {
    func resized() -> UIImage? {
        /// `300` is tolerant size for set the image in widget
        ///
        let targetSize = CGSize.square(size: 300)
        let size = self.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        let newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }

        let rect = CGRect(origin: .zero, size: newSize)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
