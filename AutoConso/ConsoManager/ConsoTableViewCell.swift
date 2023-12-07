//
//  ConsoCell.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 21/07/2018.
//  Copyright © 2018 Edgar PETRUS. All rights reserved.
//

import UIKit

class ConsoTableViewCell: UITableViewCell {

    @IBOutlet weak var textFieldDateRavitaillement: UILabel!
    @IBOutlet weak var textFieldStationService: UILabel!
    @IBOutlet weak var textFieldPrixTotalRavitaillement: UILabel!
    @IBOutlet weak var textFieldNbLitres: UILabel!
    @IBOutlet weak var textFieldL100: UILabel!
    @IBOutlet weak var ImageViewConso: UIImageView!
    @IBOutlet weak var textFieldPseudo: UILabel!
	@IBOutlet weak var trajetUrbain: UILabel!
	@IBOutlet weak var trajetMixte: UILabel!
	@IBOutlet weak var trajetRoutier: UILabel!
	
    
    
    /*var conso: Conso? {
        didSet {
            
            print("ConsoCell")
            
            guard let conso = conso else { return }
            
            textFieldStationService.text = conso.nomStation
            textFieldDateRavitaillement.text = conso.
            textFieldNbLitres.text = conso.volConso
            textFieldPrixTotalRavitaillement.text = conso.prix
        }
    }*/
    
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
