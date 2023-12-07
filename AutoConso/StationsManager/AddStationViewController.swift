//
//  AddStationViewController.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 23/03/2019.
//  Copyright © 2019 Edgar PETRUS. All rights reserved.
//

import Foundation
import Eureka
import CSV.Swift
import UIKit

class AddStationViewController: FormViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		form +++ Section("Informations Station")
			<<< TextRow(){ row in
				row.title = "Marque"
				row.placeholder = "Nom de la station"
			}
			<<< TextRow(){ row in
				row.title = "Adresse"
				row.placeholder = "Saisir"
			}
			<<< TextRow(){ row in
				row.title = "Code Postal"
				row.placeholder = "Saisir"
			}
			<<< TextRow(){ row in
				row.title = "Ville"
				row.placeholder = "Saisir"
			}
			+++ Section("Section2")
			<<< DateRow(){
				$0.title = "Date Row"
				$0.value = Date(timeIntervalSinceReferenceDate: 0)
		}
	}
}
