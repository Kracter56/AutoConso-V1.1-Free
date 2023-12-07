//
//  Location.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 19/11/2018.
//  Copyright © 2018 Edgar PETRUS. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class StationObject: NSObject {
    var locationName: String!
    var location: String!
    var image: UIImageView!
    var distance: String!
    var codePostal: String!
    var ville: String!
    var coordGPS: String!
    
	init(locationName: String, locationMarque: String, adresse: String, codePostal: String, ville: String, Distance: String, coordGPS: String) {
        self.locationName = locationName
        self.location = location
        self.codePostal = codePostal
        self.ville = ville
        self.distance = Distance
        self.coordGPS = coordGPS
    }
}

