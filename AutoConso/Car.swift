//
//  Car.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 19/07/2018.
//  Copyright © 2018 Edgar PETRUS. All rights reserved.
//

import Foundation
import RealmSwift

final class Car : Object {
    
    //@objc dynamic var id = 0
    @objc dynamic var idCar = ""
    @objc dynamic var type = ""
    @objc dynamic var creadtedAt = NSDate()
    @objc dynamic var modifiedAt = NSDate()
    @objc dynamic var marque = ""
    @objc dynamic var modele = ""
    @objc dynamic var energy = ""
    @objc dynamic var immatriculation = ""
    @objc dynamic var couleur = ""
    @objc dynamic var pseudo = ""
    @objc dynamic var kilometrage = 0
    @objc dynamic var commentaire = ""
    @objc dynamic var reservoir = 0
    @objc dynamic var dateImmat = Date()
    @objc dynamic var motorisation = ""
    @objc dynamic var dateAchat = Date()
    @objc dynamic var numeroSerie = ""
    @objc dynamic var pressionPneu = ""
    @objc dynamic var data: NSData?
    @objc dynamic var cartegrise : NSData?
	@objc dynamic var parkingAdresse = ""
	@objc dynamic var parkingCodePostal = ""
	@objc dynamic var parkingVille = ""
	@objc dynamic var parkingLatitude: Double = 0.00
	@objc dynamic var parkingLongitude: Double = 0.00
	@objc dynamic var dateLocalisation = NSDate()
	@objc dynamic var champOption1 = ""
	@objc dynamic var champOption2 = ""
	@objc dynamic var champOption3 = ""
	@objc dynamic var champOption4: Double = 0.00
	@objc dynamic var champOption5: Double = 0.00
	@objc dynamic var champOption6: Double = 0.00
	@objc dynamic var champOption7 = 0
	@objc dynamic var champOption8 = 0
	@objc dynamic var champOption9 = 0
	@objc dynamic var champOption10:Bool = false
	@objc dynamic var champOption11:Bool = false
	@objc dynamic var champOption12:Bool = false
	
    let consos = LinkingObjects(fromType: Conso.self, property: "car")

	override static func primaryKey() -> String? {
		return "idCar"
	}
}
