//
//  UIHelper.swift
//  FUREKA
//
//  Created by Sherry Chen on 5/26/18.
//  Copyright © 2018 Sherry Chen. All rights reserved.
//

import UIKit

func generateCornerProfileImage(sourceView: UIImageView) -> UIImageView{
    sourceView.layer.cornerRadius = sourceView.frame.size.width / 2
    sourceView.clipsToBounds = true
    sourceView.layer.borderWidth = 3.0
    sourceView.layer.borderColor = UIColor.white.cgColor
    return sourceView
}
