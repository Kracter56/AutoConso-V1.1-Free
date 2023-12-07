//
//  CarTableViewCell.swift
//  AutoConso-v0
//
//  Created by Edgar PETRUS on 13/10/2018.
//  Copyright © 2018 Edgar PETRUS. All rights reserved.
//

import UIKit

class CarTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var CarMarque: UILabel!
    @IBOutlet weak var CarPseudo: UILabel!
    @IBOutlet weak var CarImmatriculation: UILabel!
    @IBOutlet weak var CarImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
