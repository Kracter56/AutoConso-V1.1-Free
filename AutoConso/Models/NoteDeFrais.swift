//
//  NoteDeFrais.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 16/08/2019.
//  Copyright © 2019 Edgar PETRUS. All rights reserved.
//

import Foundation
import RealmSwift

final class NoteDeFrais : Object {

	@objc dynamic var idNdF = ""
	@objc dynamic var ref = ""
	@objc dynamic var date = Date()
	@objc dynamic var Nom = ""
	@objc dynamic var Service = ""
	@objc dynamic var typeRemboursement = ""
	@objc dynamic var Objet = ""
	@objc dynamic var typeFrais = ""
	@objc dynamic var Lieu = ""
	@objc dynamic var Montant:Float = 0.00
	@objc dynamic var etat = ""
	@objc dynamic var status:Bool = false
	@objc dynamic var commentaire = ""
	@objc dynamic var justificatif:Data?
	@objc dynamic var imageType:Data?
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
	
	override static func primaryKey() -> String? {
		return "idNdF"
	}
}
