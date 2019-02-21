//
//  MarquesTableViewCell.swift
//  AutoConso-v0
//
//  Created by Edgar PETRUS on 15/10/2018.
//  Copyright © 2018 Edgar PETRUS. All rights reserved.
//

import UIKit

class MarquesTableViewCell: UITableViewCell {

    @IBOutlet weak var carMarque: UILabel!
    @IBOutlet weak var carMarqueImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
