//
//  ImageUtils.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 8/7/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func convertJpegToData() -> Data {
        return UIImageJPEGRepresentation(self, 1)!
    }
    
    func convertPNGToData() -> Data {
        return UIImagePNGRepresentation(self)!
    }
    
    // Compress an image to reduce file size in order to save data
    func compressImage() -> UIImage {
        let actualHeight:CGFloat = self.size.height
        let actualWidth:CGFloat = self.size.width
        let imgRatio:CGFloat = actualWidth/actualHeight // This should (almost) always be 1:1
        let maxWidth:CGFloat = 1024.0
        let resizedHeight:CGFloat = maxWidth/imgRatio
        let compressionQuality:CGFloat = 0.5
        
        let rect:CGRect = CGRect(x: 0, y: 0, width: maxWidth, height: resizedHeight)
        UIGraphicsBeginImageContext(rect.size)
        self.draw(in: rect)
        let img: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        let imageData:Data = UIImageJPEGRepresentation(img, compressionQuality)!
        UIGraphicsEndImageContext()
        
        return UIImage(data: imageData)!
    }
    
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    static func generateProfilePhotoWithText(text: String) -> UIImage {
        let image = UIImage(named: "Grey Empty Profile Picture")!
        
        // Create the imageview
        let imageView = UIImageView(image: image)
        imageView.backgroundColor = UIColor.clear
        imageView.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        
        // Create the label
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        label.backgroundColor = UIColor.clear
        label.textAlignment = .center
        label.textColor = UIColor.black
        label.text = text
        label.font = UIFont(name: "Josefin Sans", size: 50)
        
        // Center the label in the view
        label.center = imageView.center
        
        
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0);
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        let imageWithText = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        return imageWithText!
    }
}
