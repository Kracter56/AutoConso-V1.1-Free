//
//  FraisTableViewCell.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 19/07/2019.
//  Copyright © 2019 Edgar PETRUS. All rights reserved.
//

import UIKit
import FoldingCell


class FraisTableViewCell: UITableViewCell {

	@IBOutlet weak var imageViewType: UIImageView!
	@IBOutlet weak var labelDateFacture: UILabel!
	@IBOutlet weak var labelKMVehicule: UILabel!
	@IBOutlet weak var labelNomFacture: UILabel!
	@IBOutlet weak var labelPrixFacture: UILabel!
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
