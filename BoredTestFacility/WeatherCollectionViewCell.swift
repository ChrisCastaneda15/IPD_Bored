//
//  WeatherCollectionViewCell.swift
//  BoredTestFacility
//
//  Created by Chris Castaneda on 6/11/17.
//  Copyright © 2017 Chris Castaneda. All rights reserved.
//

import UIKit

class WeatherCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var popLabel: UILabel!
    @IBOutlet weak var iconLabel: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
