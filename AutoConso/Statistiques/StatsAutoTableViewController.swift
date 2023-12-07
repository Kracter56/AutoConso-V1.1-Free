//
//  StatsAutoTableViewController.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 14/11/2018.
//  Copyright © 2018 Edgar PETRUS. All rights reserved.
//

import UIKit
import RealmSwift
//import Charts

class StatsAutoTableViewController: UITableViewController {

    var idCar:String?
    var carItem:[Car] = []
    var consoItem:[Conso] = []
	var consos:Results<Conso>?
    var realm:Realm?
    var distanceUnit = ""
    var currencyUnit = ""
    var volumeUnit = ""
    var carName:String?
	var objToDisplay:String?
    
    @IBOutlet weak var labelConsoMini: UILabel!
    @IBOutlet weak var labelDateRecordMini: UILabel!
    @IBOutlet weak var labelConsoMaxi: UILabel!
    @IBOutlet weak var labelDateConsoMaxi: UILabel!
    @IBOutlet weak var labelConsoMoyenne: UILabel!
    @IBOutlet weak var labelDistanceTotale: UILabel!
    @IBOutlet weak var labelFraisCarburantTotal: UILabel!
    @IBOutlet weak var labelAutonomieMaximale: UILabel!
    @IBOutlet weak var labelAutonomieMoyenne: UILabel!
    @IBOutlet weak var labelAutonomieMinimale: UILabel!
	@IBOutlet weak var labelCoutJournalier: UILabel!
	@IBOutlet weak var labelCoutAuKm: UILabel!
	
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("StatsAutoTableViewController:realmInit")
        let realm = try! Realm()
        let userSettings = UserDefaults.standard
        
        var distanceUnit = "km"
        var volumeUnit = "L"
        var currencyUnit = "€"
        
        if(settingsDataAlreadyExist(Key: "devise")){
            currencyUnit = userSettings.object(forKey: "devise") as! String
        }
        if(settingsDataAlreadyExist(Key: "distance")){
            distanceUnit = userSettings.object(forKey: "distance") as! String
        }
        if(settingsDataAlreadyExist(Key: "volume")){
            volumeUnit = userSettings.object(forKey: "volume") as! String
        }
        
        let carName = self.carName
        let carItem = realm.objects(Car.self).filter("idCar = %@",self.idCar).first
        let consoItem = realm.objects(Conso.self).filter("idCar = %@",self.idCar)
		let lastConso = consoItem.sorted(byKeyPath: "dateConso").last
        let initCarKM = carItem?.kilometrage
		
        if(consoItem.count > 0){
			
			let formatter = DateFormatter()
			formatter.dateFormat = "dd/MM/yyyy"
			
			// make sure the following are the same as that used in the API
			formatter.timeZone = TimeZone(secondsFromGMT: 0)
			formatter.locale = Locale.current
			
            let consoMoyenne:Float = consoItem.average(ofProperty: "conso")!
			
			/* Calcul de la conso mini */
            let consoMini:Float = consoItem.min(ofProperty: "conso")!
			let dateConsoMini:Date = (realm.objects(Conso.self).filter("conso = %@",consoMini).first?.dateConso)!
			
			/* date de la conso mini */
			let strDateConsoMini = formatter.string(from: dateConsoMini)
            let consoMaxi:Float = consoItem.max(ofProperty: "conso")!
			
			/* Calcul de la conso maxi */
			let dateConsoMaxi:Date = (realm.objects(Conso.self).filter("conso = %@",consoMaxi).first?.dateConso)!
			let strDateConsoMaxi = formatter.string(from: dateConsoMaxi)
			
			/* Calcul du dernier kilometrage */
            let lastkm:Int = consoItem.max(ofProperty: "carKilometrage")!
            let fraisCarburant:Double = consoItem.sum(ofProperty: "prix")
			
			/* Calcul des autonomies */
            let autonomieMin:Float = consoItem.min(ofProperty: "carKmParcourus")!
            let autonomieMoy:Float = consoItem.average(ofProperty: "carKmParcourus")!
            let autonomieMax:Float = consoItem.max(ofProperty: "carKmParcourus")!
			
			/* Arrondi des consos */
            let roundConsoMoyenne = (consoMoyenne * 1000).rounded() / 1000
            let roundFraisCarburant = (fraisCarburant * 1000).rounded() / 1000
            let roundConsoMini = (consoMini * 1000).rounded() / 1000
            let roundConsoMaxi = (consoMaxi * 1000).rounded() / 1000

			
			var coutKM = 0.00
			if(initCarKM! > 0){
				let KMparcourus = lastkm - initCarKM!
				coutKM = (roundFraisCarburant/Double(KMparcourus))
			}
			let roundCoutKM = (coutKM * 1000).rounded() / 1000
			let nbJours = getDaysSinceStart(startDate: (carItem?.dateAchat)!, endDate: (lastConso?.dateConso)!)
			
            self.labelConsoMoyenne?.text = roundConsoMoyenne.description + " " + volumeUnit + "/100 " + distanceUnit
            self.labelConsoMini?.text = roundConsoMini.description + " " + volumeUnit + "/100 " + distanceUnit
			self.labelDateRecordMini?.text = "Record atteint le " + strDateConsoMini
			self.labelDateConsoMaxi?.text = "Atteint le " + strDateConsoMaxi
            self.labelConsoMaxi?.text = roundConsoMaxi.description + " " + volumeUnit + "/100 " + distanceUnit
            
            self.labelAutonomieMaximale?.text = autonomieMax.description + " " + distanceUnit
            self.labelAutonomieMoyenne?.text = autonomieMoy.description + " " + distanceUnit
            self.labelAutonomieMinimale?.text = autonomieMin.description + " " + distanceUnit
            
            self.labelDistanceTotale?.text = lastkm.description + " " + distanceUnit
            self.labelFraisCarburantTotal?.text = roundFraisCarburant.description + " " + currencyUnit
            
            self.labelConsoMini?.text = roundConsoMini.description + " " + volumeUnit + "/100 " + distanceUnit
			
			self.labelCoutAuKm?.text = roundCoutKM.description + " " + currencyUnit + "/" + distanceUnit
			var coutJour:Float = ((Float(roundFraisCarburant) / Float(nbJours)) * 1000).rounded() / 1000
			self.labelCoutJournalier?.text = coutJour.description + " " + currencyUnit + "/jour"
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    func settingsDataAlreadyExist(Key: String) -> Bool {
        return UserDefaults.standard.object(forKey: Key) != nil
    }
	
	func getDaysSinceStart(startDate: Date, endDate: Date) -> Int{
		
		let differenceInDays = (endDate.timeIntervalSince(startDate)) / (60 * 60 * 24)
		print("getDaysSinceStart",differenceInDays)
		return Int(differenceInDays)
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let vc = storyboard.instantiateViewController(withIdentifier: "stationsSearchList") as! GraphesViewController
		
		switch indexPath.section {
		case 0:
			switch indexPath.row {
			case 0:
				// Kilometrage des enregistrements
				self.objToDisplay = "km"
				vc.idCar = self.idCar
				vc.objToDisplay = "km"
				break
			case 1:
				
				break
			default:
				break
			}
		case 1:
			switch indexPath.row {
			case 0:
				
				break
			case 1:
				
				
				break
			case 2:
				
				break
			case 3:
				
				break
			default:
				break
			}
		case 2:
			switch indexPath.row {
			case 0:
				
				break
			case 1:
				
				break
			case 2:
				
				break
			default:
				break
			}
		case 3:
			switch indexPath.row {
			case 0:
				
				break
			case 1:
				
				break
			default:
				break
			}
		case 4:
			switch indexPath.row{
			case 0:
				
				
				break
			default:
				break
			}
		default:
			break
		}
		navigationController?.pushViewController(vc, animated: true)
	}
	
	
    // MARK: - Table view data source

    /*override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }*/

    /*override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }*/

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
		
		// indexPath is set to the path that was tapped
		let indexPath = self.tableView.indexPathForSelectedRow
		//let section = self.tableView.ind
		// titleString is set to the title at the row in the objects array.
		//let carName = self.
		let vc = segue.destination as! GraphesViewController
		vc.idCar = self.idCar
		vc.consoItem = self.consoItem
		vc.objToDisplay = self.objToDisplay
		//vc.
		//self.tableView.deselectRow(at: indexPath!, animated: true)
		
    }
	

}
