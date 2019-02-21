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
    
    //var id: Int
    @objc dynamic var idConso = ""
    @objc dynamic var dateConso = Date()
    @objc dynamic var createdAt = NSDate()
    @objc dynamic var carName = ""
    @objc dynamic var carKilometrage = 0
    @objc dynamic var carKmParcourus: Float = 0.00
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
    @objc dynamic var station: Station?
    @objc dynamic var car: Car?
    
    /* One-To-Many relationship pour Car et Station */
    let stations = LinkingObjects(fromType: Station.self, property: "consos")
    let cars = LinkingObjects(fromType: Car.self, property: "consos")
    
    /*init(carName: String?, carKilometrage: String?, carKmParcourus: String?, dateConso: String?, station: String?, conso: String?, volConso: String?, prix: String?, coutLitre: String?) {
        self.carName = carName
        self.carKilometrage = carKilometrage
        self.carKmParcourus = carKmParcourus
        self.dateConso = dateConso
        self.station = station
        self.conso = conso
        self.volConso = volConso
        self.prix = prix
        self.coutLitre = coutLitre
    }*/
}
