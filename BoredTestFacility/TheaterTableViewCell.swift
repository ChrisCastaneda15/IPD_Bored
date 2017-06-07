//
//  TheaterTableViewCell.swift
//  BoredTestFacility
//
//  Created by Chris Castaneda on 6/6/17.
//  Copyright © 2017 Chris Castaneda. All rights reserved.
//

import UIKit

class TheaterTableViewCell: UITableViewCell {
    
    @IBOutlet weak var moviePosterImageView: UIImageView!
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var movieRatingImageView: UIImageView!
    @IBOutlet weak var movieRuntimeLabel: UILabel!
    @IBOutlet weak var movieShowtimesTextView: UITextView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
