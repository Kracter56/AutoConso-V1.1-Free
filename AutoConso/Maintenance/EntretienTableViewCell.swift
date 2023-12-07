//
//  EntretienTableViewCell.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 12/07/2019.
//  Copyright © 2019 Edgar PETRUS. All rights reserved.
//

import UIKit

class EntretienTableViewCell: UITableViewCell {

	@IBOutlet weak var imageEntretienItem: UIImageView!
	@IBOutlet weak var labelEntretien: UILabel!
	@IBOutlet weak var labelKM: UILabel!
	@IBOutlet weak var labelNomGarage: UILabel!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
		self.accessoryType = selected ? .checkmark : .none
        // Configure the view for the selected state
    }

	/* Enable multiple selection with tick mark */
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.selectionStyle = .none
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
}
