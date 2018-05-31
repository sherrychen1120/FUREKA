//
//  ButtonsTableViewCell.swift
//  FUREKA
//
//  Created by Sherry Chen on 5/26/18.
//  Copyright © 2018 Sherry Chen. All rights reserved.
//

import UIKit

protocol ButtonsTableViewCellDelegate {
    func ARMenuPressed()
    func SharePhotoPressed()
}

class ButtonsTableViewCell: UITableViewCell {
    
    var delegate: ButtonsTableViewCellDelegate?
    
    @IBOutlet weak var ARMenuButton: UIButton!
    @IBAction func ARMenuButtonPressed(_ sender: Any) {
        if (self.delegate != nil) {
            print("ARMenu Button Pressed")
            self.delegate?.ARMenuPressed()
        }
    }
    
    @IBAction func SharePhotoButtonPressed(_ sender: Any) {
        if (self.delegate != nil) {
            print("Share Photo Button Pressed")
            self.delegate?.SharePhotoPressed()
        }
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
