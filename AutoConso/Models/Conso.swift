//
//  Conso.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 20/07/2018.
//  Copyright © 2018 Edgar PETRUS. All rights reserved.
//

import Foundation
import RealmSwift

final class Conso : Object {
    
    //@objc dynamic var id = 0
    @objc dynamic var idConso = ""
    @objc dynamic var dateConso = Date()
    @objc dynamic var createdAt = NSDate()
    @objc dynamic var carName = ""
    @objc dynamic var carKilometrage = 0
    @objc dynamic var carKmParcourus: Float = 0.00
	@objc dynamic var idStation = ""
    @objc dynamic var nomStation = ""
    @objc dynamic var adresseStation = ""
    @objc dynamic var CPStation = ""
    @objc dynamic var villeStation = ""
    @objc dynamic var typeCarburant = ""
    @objc dynamic var conso: Float = 0.00
    @objc dynamic var volConso: Float = 0.00
    @objc dynamic var prix: Float = 0.00
    @objc dynamic var coutLitre: Float = 0.00
    @objc dynamic var commentaire = ""
    @objc dynamic var data: NSData?
    @objc dynamic var idCar = ""
    @objc dynamic var car: Car?
    @objc dynamic var stationImage : NSData?
	@objc dynamic var statusPlein: Bool = true
	@objc dynamic var typeParcours = ""
	@objc dynamic var champOption1 = ""
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
	
	/* One-To-Many relationship pour Car et Station */
	let stations = LinkingObjects(fromType: Station.self, property: "consos")
	
	var station:Station? {
		return self.stations.first
	}
	
	override static func primaryKey() -> String? {
		return "idConso"
	}
}
