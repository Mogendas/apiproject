//
//  StationTableViewCell.swift
//  apiproject
//
//  Created by Johan Wejdenstolpe on 2017-05-07.
//  Copyright © 2017 Johan Wejdenstolpe. All rights reserved.
//

import UIKit

class StationTableViewCell: UITableViewCell {

    @IBOutlet weak var stationName: UILabel!
    @IBOutlet weak var stationDistance: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
