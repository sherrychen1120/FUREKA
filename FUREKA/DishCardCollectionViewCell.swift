//
//  DishCardCollectionViewCell.swift
//  FUREKA
//
//  Created by Sherry Chen on 5/29/18.
//  Copyright © 2018 Sherry Chen. All rights reserved.
//

import UIKit

class DishCardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var DishCardContent: UIView!
    
    private var dish = ""
    
    func configure(dish: String) {
        self.dish = dish
    }
    
}
