//
//  StationsSearchTableViewCell.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 19/11/2018.
//  Copyright © 2018 Edgar PETRUS. All rights reserved.
//

import UIKit

class stationsSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var iconStation: UIImageView!
    @IBOutlet weak var stationName: UILabel!
    @IBOutlet weak var stationAdresse: UILabel!
    @IBOutlet weak var stationCodePostal: UILabel!
    @IBOutlet weak var stationCPVille: UILabel!
    @IBOutlet weak var stationDistance: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureLocationCell(locationName: String, location: String, codePostal: String, ville: String, distance: String) {
        self.stationName.text = locationName
        self.stationAdresse.text = location
        let nomImage = locationName.uppercased()
        
        if let myImage = UIImage(named: nomImage) {
            self.iconStation.image = UIImage(named: nomImage)
        }
        else {
            self.iconStation.image = UIImage(named: "icon_fuel")
        }
        self.stationCodePostal.text = codePostal
        self.stationCPVille.text = ville
        self.stationDistance.text = distance
    }
}
