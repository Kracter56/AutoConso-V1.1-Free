//
//  operationsTableViewCell.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 25/07/2019.
//  Copyright © 2019 Edgar PETRUS. All rights reserved.
//

import UIKit

class operationsTableViewCell: UITableViewCell {

	@IBOutlet weak var imageTypeOperation: UIImageView!
	@IBOutlet weak var labelOperation: UILabel!
	@IBOutlet weak var labelCarKm: UILabel!
	@IBOutlet weak var labelNomGarage: UILabel!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
