//
//  tdbCarsTableViewCell.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 24/10/2018.
//  Copyright © 2018 Edgar PETRUS. All rights reserved.
//

import UIKit

class tdbCarsTableViewCell: UITableViewCell {

    @IBOutlet weak var labelCarPseudo: UILabel!
    @IBOutlet weak var labelCarModele: UILabel!
    @IBOutlet weak var labelkmParcourusDepuisAchat: UILabel!
    @IBOutlet weak var labelFraisCarburantDepuisAchat: UILabel!
    @IBOutlet weak var labelNbJoursDepuisAchat: UILabel!
    @IBOutlet weak var labelConsoMoyenne: UILabel!
    @IBOutlet weak var labelCoutAuKm: UILabel!
    @IBOutlet weak var labelCoutJournalier: UILabel!
    @IBOutlet weak var cellContentView: UIView!
    @IBOutlet weak var imageCar: UIImageView!
	@IBOutlet weak var controlsView: UIView!/*{
		didSet {
			controlsView.isHidden = true
		}
	}*/
	
    /* Boutons Menu Vehicule */
    @IBOutlet weak var BtnStats: UIButton!
    @IBOutlet weak var BtnFuel: UIButton!
    @IBOutlet weak var BtnParking: UIButton!
    @IBOutlet weak var BtnEntretien: UIButton!
    
    /* Tags Energie */
    @IBOutlet weak var tagInconnu: UILabel!
    @IBOutlet weak var TagEssence: UILabel!
    @IBOutlet weak var TagDiesel: UILabel!
    @IBOutlet weak var TagElectrique: UILabel!
    @IBOutlet weak var TagHybride: UILabel!
    
    
    weak var delegate: HomeTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    /*override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }*/
    @IBAction func BtnStats(_ sender: UIButton) {
        delegate?.HomeTableViewCellDidTapStats(self)
    }
    @IBAction func BtnFuel(_ sender: UIButton) {
        delegate?.HomeTableViewCellDidTapFuel(self)
    }
    @IBAction func BtnParking(_ sender: UIButton) {
        delegate?.HomeTableViewCellDidTapParking(self)
    }
    @IBAction func BtnEntretien(_ sender: UIButton) {
        delegate?.HomeTableViewCellDidTapEntretien(self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        if selected {
            super.setSelected(selected, animated: animated)
            /*let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotationAnimation.fromValue = 0.0
            
            //Put the angle in a constant so we can use to create a transform
            let angle = (180.0 * CGFloat(M_PI)) / 180.0
            rotationAnimation.toValue =
                rotationAnimation.duration = 0.45*/
            
            /*let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotateAnimation.fromValue = 0.0
            rotateAnimation.toValue = CGFloat(.pi * 2.0)
            rotateAnimation.duration = Operation
            rotateAnimation.repeatCount = Float.greatestFiniteMagnitude;
 
            self.cellContentView.layer.add(rotationAnimation, forKey: nil)
            
            //Create a transform for our rotation
            let transform = CATransform3DMakeRotation(angle, 0, 0, 1)
            
            //install the transform on the layer so the change is active after
            //the animation completes
            layer.transform = transform*/
        }
    }

}
