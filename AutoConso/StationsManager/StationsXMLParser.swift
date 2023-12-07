//
//  StationsXMLParser.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 04/04/2019.
//  Copyright © 2019 Edgar PETRUS. All rights reserved.
//

import Foundation
import UIKit
import SWXMLHash

class StationItems {
	var idStation = "";
	var nom = "";
}

class Tag {
	var name = "";
	var count: Int?;
}


class StationsXMLParser: UITableViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		var xmlData:Data?
		
		guard let fileURL = Bundle.main.url(forResource: "PrixCarburants", withExtension: "xml")
			else { fatalError("cannot load file")}
		do {
			if let xmlData = try? Data(contentsOf: fileURL, options: []){
				let xml = SWXMLHash.parse(xmlData)
				for child in xml.children {
					var champ = child.element!.name
					
					switch(champ){
						case "adresse":
							let adresse = child.element!.children[0].description
							break
						case "ville":
							let ville = child.element!.children[0].description
							break
						
						default:
							print("break")
					}
				}
			}
		} catch {
			print(error)
		}
		
		
		
	}
	
	
}
