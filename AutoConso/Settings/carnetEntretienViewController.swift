//
//  carnetEntretienViewController.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 28/07/2019.
//  Copyright © 2019 Edgar PETRUS. All rights reserved.
//

import Foundation
import RealmSwift
import Eureka

class carnetEntretienViewController: FormViewController {
	
	var operationsTypeList:[typeOperation] = []
	
	
	let types = ["Entretien", "Réparation", "Lavage"]
	
	let categories = [["Huiles et liquides", "Filtres", "Batterie", "Système de Freinage", "Pneus"], ["Réparation"], ["Lavage"]]
	
	let operations = [["Vidange huile moteur", "Vidange boite de vitesse manuelle", "Vidange boite de vitesse automatique", "Mise à niveau liquide lave glace", "Mise à niveau liquide de refroidissement", "Vidange liquide de frein"], ["Remplacement filtre à huile", "Remplacement filtre à air", "Remplacement filtre à carburant", "Remplacement filtre habitacle"], ["Diagnostic Batterie", "Remplacement de batterie"], ["Remplacement plaquettes de frein AV", "Remplacement plaquettes de frein AR", "Remplacement disques de frein AV", "Remplacement disques de frein AR"],["Remplacement pneus AV", "Remplacement pneus AR", "Parallélisme AV", "Parallélisme AR", "Contrôle de géométrie"]]
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
	
	
	form
		+++ Section()
		<<< PushRow<String>() {
			$0.title = "Type d'intervention"
			$0.selectorTitle = "type"
			$0.options = self.types
			$0.value = "Entretien"    // initially selected
			$0.tag = "typeIntervention"
		}
	
	}
}
