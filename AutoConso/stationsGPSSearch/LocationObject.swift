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

class LocationObject: NSObject {
    var locationName: String!
    var location: String!
    var image: UIImageView!
    var distance: String!
    var codePostal: String!
    var ville: String!
    
    init(locationName: String, location: String, codePostal: String, ville: String, Distance: String) {
        self.locationName = locationName
        self.location = location
        self.codePostal = codePostal
        self.ville = ville
        self.distance = Distance
    }
}

