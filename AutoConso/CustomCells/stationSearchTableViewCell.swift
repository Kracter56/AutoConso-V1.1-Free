//
//  stationSearchTableViewCell.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 18/11/2018.
//  Copyright © 2018 Edgar PETRUS. All rights reserved.
//

import UIKit

class stationSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var labelObjectName: UILabel!
    @IBOutlet weak var labelObjectAddress: UILabel!
    @IBOutlet weak var labelObjectDistance: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
