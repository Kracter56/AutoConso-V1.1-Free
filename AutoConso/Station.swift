//
//  Station.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 13/11/2018.
//  Copyright © 2018 Edgar PETRUS. All rights reserved.
//

import Foundation
import RealmSwift
import MapKit

final class Station : Object {
    
    //@objc dynamic var ID = 0
    @objc dynamic var idStation = ""
    @objc dynamic var nomStation = ""
    @objc dynamic var coordGPS = ""
    @objc dynamic var creadtedAt = NSDate()
    @objc dynamic var modifiedAt = NSDate()
    @objc dynamic var typeRoute = ""
    @objc dynamic var adresse = ""
    @objc dynamic var ville = ""
    @objc dynamic var codePostal = ""
    @objc dynamic var heureDebut = ""
    @objc dynamic var heureFin = ""
    @objc dynamic var commentaire = ""
    @objc dynamic var saufJour = ""
    @objc dynamic var prixCarburant: Float = 0.00
    @objc dynamic var services = ""
    @objc dynamic var carburant = ""
    @objc dynamic var compteur = 0
    @objc dynamic var data: NSData?
    
    let consos = List<Conso>()
    
    //@objc dynamic var image = UIImage()
    
    /*override static func primaryKey() -> String? {
     return "ID"
     }*/
}
