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
    
    //@objc dynamic var ID = 0
    @objc dynamic var idCar = ""
    @objc dynamic var type = ""
    @objc dynamic var creadtedAt = NSDate()
    @objc dynamic var modifiedAt = NSDate()
    @objc dynamic var marque = ""
    @objc dynamic var modele = ""
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
    
    let consos = List<Conso>()
    
    //@objc dynamic var image = UIImage()
    
    /*override static func primaryKey() -> String? {
     return "ID"
    }*/
}
