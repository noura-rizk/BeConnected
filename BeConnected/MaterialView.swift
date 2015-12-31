//
//  MaterialView.swift
//  BeConnected
//
//  Created by Noura Rizk on 12/28/15.
//  Copyright © 2015 Noura Rizk. All rights reserved.
//

import UIKit

class MaterialView: UIView {

    override func awakeFromNib() {
        layer.cornerRadius = 2.0;
        layer.shadowColor = UIColor(hue: SHADOW_COLOR, saturation: SHADOW_COLOR, brightness: SHADOW_COLOR, alpha: 0.5).CGColor;
        layer.shadowOpacity = 0.8;
        layer.shadowRadius = 5.0;
        layer.shadowOffset = CGSize(width: 0, height: 2.0);
    }

}
