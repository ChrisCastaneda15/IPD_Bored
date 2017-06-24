//
//  FavoriteTableViewCell.swift
//  BoredTestFacility
//
//  Created by Chris Castaneda on 6/23/17.
//  Copyright © 2017 Chris Castaneda. All rights reserved.
//

import UIKit

class FavoriteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var placeDistLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected{
            placeNameLabel.textColor = UIColor.BoredColors.DeepBlue
            placeDistLabel.textColor = UIColor.BoredColors.DeepBlue
        }
        else {
            placeNameLabel.textColor = UIColor.BoredColors.OffWhite
            placeDistLabel.textColor = UIColor.BoredColors.OffWhite
        }

        // Configure the view for the selected state
    }
    
}
