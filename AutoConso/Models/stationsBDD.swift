//
//  stationsBDD.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 24/08/2019.
//  Copyright © 2019 Edgar PETRUS. All rights reserved.
//

import Foundation
import RealmSwift

final class stationsBDD : Object {
	
	@objc dynamic var idStation = ""
	@objc dynamic var nomStation = ""
	@objc dynamic var marque = ""
	@objc dynamic var creadtedAt = NSDate()
	@objc dynamic var modifiedAt = NSDate()
	@objc dynamic var adresse = ""
	@objc dynamic var ville = ""
	@objc dynamic var codePostal = ""
	@objc dynamic var pays = ""
	@objc dynamic var commentaire = ""
	@objc dynamic var data: NSData?
	@objc dynamic var distance: Double = 0.00
	@objc dynamic var latitude: Double = 0.00
	@objc dynamic var longitude: Double = 0.00
	@objc dynamic var favori: Bool = false
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
	
	let services = List<String>()
	
	//let consos = LinkingObjects(fromType: Conso.self, property: "station")
	
	override static func primaryKey() -> String? {
		return "idStation"
	}
}
