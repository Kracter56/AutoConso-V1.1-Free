//
//  Location.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 19/11/2018.
//  Copyright © 2018 Edgar PETRUS. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import Firebase

class stationObject: NSObject {
	var idStation: String!
    var nom: String!
	var marque: String!
    var adresse: String!
	var codePostal: String!
	var ville: String!
    var image: UIImageView!
    var distance: String!
    var latitude: Double!
	var longitude: Double!
	var services: String!
	
	var prixEssPlus: String!
	var prixSP95E10: String!
	var prixSP95: String!
	var prixSP98: String!
	var prixSUPER: String!
	var prixDieselPlus: String!
	var prixDiesel: String!
	var prixGPL: String!
	var prixEthanol: String!
	
	var majEssPlus: String!
	var majSP95E10: String!
	var majSP95: String!
	var majSP98: String!
	var majSUPER: String!
	var majDieselPlus: String!
	var majDiesel: String!
	var majGPL: String!
	var majEthanol: String!
	
	var ruptureEssPlus: String!
	var ruptureSP95E10: String!
	var ruptureSP95: String!
	var ruptureSP98: String!
	var ruptureSUPER: String!
	var ruptureDieselPlus: String!
	var ruptureDiesel: String!
	var ruptureGPL: String!
	var ruptureEthanol: String!
	
	init(idStation:String, nom: String, marque: String, adresse: String, codePostal: String, ville: String, distance: String, latitude: Double, longitude: Double, services: String, prixEssPlus: String, majEssPlus: String, ruptureEssPlus: String!, prixSP95E10: String!, majSP95E10: String, ruptureSP95E10: String!, prixSP95: String!, majSP95: String, ruptureSP95: String!, prixSP98: String!, majSP98: String, ruptureSP98: String!, prixSUPER: String!, majSUPER: String, ruptureSUPER: String!, prixDieselPlus: String!, majDieselPlus: String, ruptureDieselPlus: String!, prixDiesel: String!, majDiesel: String, ruptureDiesel: String!, prixGPL: String!, majGPL: String, ruptureGPL: String!, prixEthanol: String!, majEthanol: String, ruptureEthanol: String!) {
		
		self.idStation = idStation
        self.nom = nom
        self.marque = marque
		self.adresse = adresse
        self.codePostal = codePostal
        self.ville = ville
        self.distance = distance
        self.latitude = latitude
		self.longitude = longitude
		self.services = services
		
		self.prixEssPlus = prixEssPlus
		self.prixSP95E10 = prixSP95E10
		self.prixSP95 = prixSP95
		self.prixSP98 = prixSP98
		self.prixSUPER = prixSUPER
		self.prixDieselPlus = prixDieselPlus
		self.prixDiesel = prixDiesel
		self.prixGPL = prixGPL
		self.prixEthanol = prixEthanol
		
		self.majEssPlus = majEssPlus
		self.majSP95E10 = majSP95E10
		self.majSP95 = majSP95
		self.majSP98 = majSP98
		self.majSUPER = majSUPER
		self.majDieselPlus = majDieselPlus
		self.majDiesel = majDiesel
		self.majGPL = majGPL
		self.majEthanol = majEthanol
		
		self.ruptureGPL = ruptureGPL
		self.ruptureSP95 = ruptureSP95
		self.ruptureSP98 = ruptureSP98
		self.ruptureSUPER = ruptureSUPER
		self.ruptureDiesel = ruptureDiesel
		self.ruptureEthanol = ruptureEthanol
		self.ruptureEssPlus = ruptureEssPlus
		self.ruptureSP95E10 = ruptureSP95E10
		self.ruptureDieselPlus = ruptureDieselPlus
    }
}

