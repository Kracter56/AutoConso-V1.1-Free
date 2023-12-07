//
//  Maintenance.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 02/07/2019.
//  Copyright © 2019 Edgar PETRUS. All rights reserved.
//

import Foundation
import RealmSwift
import MapKit

final class Facture : Object {
	
	@objc dynamic var idFacture = ""
	@objc dynamic var dateFacture = Date()
	@objc dynamic var NomFacture = ""
	@objc dynamic var refFacture = ""
	@objc dynamic var createdAt = NSDate()
	@objc dynamic var carName = ""
	@objc dynamic var carKilometrage = 0
	@objc dynamic var nomGarage = ""
	@objc dynamic var adresseGarage = ""
	@objc dynamic var CPGarage = ""
	@objc dynamic var villeGarage = ""
	@objc dynamic var prix: Float = 0.00
	@objc dynamic var details = ""
	@objc dynamic var commentaire = ""
	@objc dynamic var facture: NSData?	// Copie Facture
	@objc dynamic var idCar = ""
	@objc dynamic var car: Car?
	@objc dynamic var status:Bool = true
	@objc dynamic var GarageImage : NSData?	// Enseigne, Marque
	@objc dynamic var champOption1 = ""		// Nom de la facture
	@objc dynamic var champOption2 = ""
	@objc dynamic var champOption3 = ""
	@objc dynamic var champOption4: Float = 0.00
	@objc dynamic var champOption5: Float = 0.00
	@objc dynamic var champOption6: Float = 0.00
	@objc dynamic var champOption7 = 0
	@objc dynamic var champOption8 = 0
	@objc dynamic var champOption9 = 0
	@objc dynamic var champOption10:Bool = false
	@objc dynamic var champOption11:Bool = false
	@objc dynamic var champOption12:Bool = false
	
	let operations = List<operation>()
	
	//let operations = LinkingObjects(fromType: operation.self, property: "facture")
	
	/* One-To-Many relationship pour Car et Station */
	/*let garages = LinkingObjects(fromType: Garage.self, property: "facture")
	var garage:Garage? {
		return self.garages.first
	}*/
	
	override static func primaryKey() -> String? {
		return "idFacture"
	}
}
