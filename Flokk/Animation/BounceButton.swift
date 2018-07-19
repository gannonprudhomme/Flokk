//
//  BounceButton.swift
//  Flokk
//
//  Created by Jared Heyen on 3/21/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
//

import UIKit

class BounceButton: UIButton {
 
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 6, options: .allowUserInteraction, animations: {
        
        self.transform = CGAffineTransform.identity
        }, completion: nil)
        
        super.touchesBegan(touches, with: event)
        
        
    }

}
