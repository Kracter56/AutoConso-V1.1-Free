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
	@IBOutlet weak var stationId: UILabel!
	@IBOutlet weak var prixEssPlus: UILabel!
	@IBOutlet weak var prixDieselPlus: UILabel!
	@IBOutlet weak var prixGazole: UILabel!
	@IBOutlet weak var prixSP95E10: UILabel!
	@IBOutlet weak var prixSP95: UILabel!
	@IBOutlet weak var prixSP98: UILabel!
	@IBOutlet weak var prixSUP: UILabel!
	@IBOutlet weak var prixEthanol: UILabel!
	
	@IBOutlet weak var dureeE85: UILabel!
	@IBOutlet weak var dureeEssPlus: UILabel!
	@IBOutlet weak var dureeSP98: UILabel!
	@IBOutlet weak var dureeSP95: UILabel!
	@IBOutlet weak var dureeE10: UILabel!
	@IBOutlet weak var dureeDieselPlus: UILabel!
	@IBOutlet weak var dureeGazole: UILabel!
	@IBOutlet weak var carburantsStackView: UIStackView!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
	func configureLocationCell(locationId: String, locationName: String, marque: String, location: String, codePostal: String, ville: String, distance: String, prixEssPlus: String, majEssPlus: String, prixDieselPlus: String, majDieselPlus: String, prixGazole: String, majGazole: String, prixSP95E10: String, majSP95E10: String, prixSP95: String, majSP95: String, prixSP98: String, majSP98: String, prixSUP: String, majSUP: String, prixEthanol: String, majEthanol: String, prixGPL: String, majGPL: String) {
        self.stationName.text = locationName
        self.stationAdresse.text = location
        let nomImage = marque.uppercased()
        
        if let myImage = UIImage(named: nomImage) {
            self.iconStation.image = UIImage(named: nomImage)
        }
        else {
            self.iconStation.image = UIImage(named: "icon_fuel")
        }
        self.stationCodePostal.text = codePostal
        self.stationCPVille.text = ville
        self.stationDistance.text = distance
		self.stationId.text = locationId
		self.prixEssPlus.text = prixEssPlus
		self.prixDieselPlus.text = prixDieselPlus
		self.prixGazole.text = prixGazole
		self.prixSP95E10.text = prixSP95E10
		self.prixSP95.text = prixSP95
		self.prixSP98.text = prixSP98
		self.prixEthanol.text = prixEthanol
		
		if let dureeEssPlus = Int(majEssPlus){
			switch dureeEssPlus {
				case 0:
					self.dureeEssPlus.text = "Auj"
				case 1..<7:
					self.dureeEssPlus.text = majEssPlus + "J"
				default:
					self.dureeEssPlus.text = "> 1sem."
			}
		}
		if let dureeDieselPlus = Int(majDieselPlus){
			switch dureeDieselPlus {
				case 0:
					self.dureeDieselPlus.text = "Auj"
				case 1..<7:
					self.dureeDieselPlus.text = majDieselPlus + "J"
				default:
					self.dureeDieselPlus.text = "> 1sem."
			}
		}
		if let dureeGazole = Int(majGazole){
			switch dureeGazole {
				case 0:
					self.dureeGazole.text = "Auj"
				case 1..<7:
					self.dureeGazole.text = majGazole + "J"
				default:
					self.dureeGazole.text = "> 1sem."
			}
		}
		if let dureeE10 = Int(majSP95E10){
			switch dureeE10 {
				case 0:
					self.dureeE10.text = "Auj"
				case 1..<7:
					self.dureeE10.text = majSP95E10 + "J"
				default:
					self.dureeE10.text = "> 1sem."
			}
		}
		if let dureeSP95 = Int(majSP95){
			switch dureeSP95 {
				case 0:
					self.dureeSP95.text = "Auj"
				case 1..<7:
					self.dureeSP95.text = majSP95 + "J"
				default:
					self.dureeSP95.text = "> 1sem."
			}
		}
		if let dureeSP98 = Int(self.dureeSP98.text!){
			switch dureeSP98 {
			case 0:
				self.dureeSP98.text = "Auj"
			case 1..<7:
				self.dureeSP98.text = majSP98 + "J"
			default:
				self.dureeSP98.text = "> 1sem."
			}
		}
		
		if let dureeE85 = Int(self.dureeE85.text!){
			switch dureeE85 {
			case 0:
				self.dureeE85.text = "Auj"
			case 1..<7:
				self.dureeE85.text = majSP98 + "J"
			default:
				self.dureeE85.text = "> 1sem."
			}
		}
    }
}
