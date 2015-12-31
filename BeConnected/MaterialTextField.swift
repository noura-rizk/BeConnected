//
//  MaterialTextField.swift
//  BeConnected
//
//  Created by Noura Rizk on 12/28/15.
//  Copyright © 2015 Noura Rizk. All rights reserved.
//

import UIKit

class MaterialTextField: UITextField {
    
    override func awakeFromNib() {
        layer.cornerRadius = 2.0;
        layer.borderColor = UIColor(hue: SHADOW_COLOR, saturation: SHADOW_COLOR, brightness: SHADOW_COLOR, alpha: 0.1).CGColor;
        layer.borderWidth = 1.0;
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 10, 0)
    }
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 10, 0)
    }
}
