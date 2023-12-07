//
//  typeCarburant.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 09/08/2019.
//  Copyright © 2019 Edgar PETRUS. All rights reserved.
//

import Foundation
import RealmSwift

final class typeCarburant : Object {
	
	@objc dynamic var idTypeCarburant = ""
	@objc dynamic var Energie = ""
	@objc dynamic var NomCarburant = ""
	@objc dynamic var commentaire = ""
	@objc dynamic var imageOperation : NSData?
	
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
	
	override static func primaryKey() -> String? {
		return "idTypeCarburant"
	}
}
