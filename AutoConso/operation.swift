//
//  operation.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 16/07/2019.
//  Copyright © 2019 Edgar PETRUS. All rights reserved.
//

import Foundation
import RealmSwift

final class operation : Object {
	
	@objc dynamic var idOperation = ""
	@objc dynamic var type = ""		// Entretien ou Réparation ou Lavage
	@objc dynamic var dateOperation = Date()
	@objc dynamic var NomOperation = ""
	@objc dynamic var idFacture = ""
	@objc dynamic var refFacture = ""
	@objc dynamic var prochaineEcheanceKM = 0
	@objc dynamic var intervalle = 0
	@objc dynamic var prochaineEcheanceDate = Date()
	@objc dynamic var createdAt = NSDate()
	@objc dynamic var carName = ""
	@objc dynamic var carKilometrage = 0
	@objc dynamic var nomGarage = ""
	@objc dynamic var adresseGarage = ""
	@objc dynamic var CPGarage = ""
	@objc dynamic var villeGarage = ""
	@objc dynamic var commentaire = ""
	@objc dynamic var idCar = ""
	@objc dynamic var car: Car?
	@objc dynamic var rappelEcheance:Bool = true
	@objc dynamic var champOption1 = ""		// Nom de la facture
	@objc dynamic var champOption2 = ""
	@objc dynamic var champOption3 = ""
	@objc dynamic var champOption4: Float = 0.00
	@objc dynamic var champOption5: Float = 0.00
	@objc dynamic var champOption6: Float = 0.00
	@objc dynamic var champOption7 = 0
	@objc dynamic var champOption8 = 0
	@objc dynamic var champOption9 = 0
	@objc dynamic var imageOperation : NSData?
	@objc dynamic var champOption10:Bool = false
	@objc dynamic var champOption11:Bool = false
	@objc dynamic var champOption12:Bool = false
	
	/* One-To-Many relationship pour Car et Station */
	let factures = LinkingObjects(fromType: Facture.self, property: "operations")
	
	/*var facture:Facture? {
		return self.facture.first
	}	*/
	override static func primaryKey() -> String? {
		return "idOperation"
	}
}
