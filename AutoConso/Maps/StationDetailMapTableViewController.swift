//
//  StationDetailMapTableViewController.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 25/11/2019.
//  Copyright © 2019 Edgar PETRUS. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class StationDetailMapTableViewController: UITableViewController {
	
	var myPosition:CLLocationCoordinate2D?
	@IBOutlet weak var imageStation: UIImageView!
	@IBOutlet weak var nomStation: UILabel!
	@IBOutlet weak var stationID: UILabel!
	@IBOutlet weak var adresseStation: UILabel!
	@IBOutlet weak var codepostal: UILabel!
	@IBOutlet weak var villeStation: UILabel!
	@IBAction func buttonNaviguer(_ sender: Any) {
		
		let coordinates = CLLocationCoordinate2DMake(self.station.latitude, self.station.longitude)
		let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
		let mapitem = MKMapItem(placemark: placemark)
		mapitem.name = self.stationObj?.nom
		let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
		mapitem.openInMaps(launchOptions: options)
		
	}
	@IBAction func buttonSaisirTicket(_ sender: UIButton){
		
		let VC = addConsoVC() //as UIViewController
		VC.station = self.station
		VC.source = "map"
		self.present(VC, animated: true, completion: nil)
		
	}
	
	var stationObj:stationObject?
	var station:Station = Station()
	var idStation:String?
	
	override func viewDidLoad() {
        super.viewDidLoad()

		let marque = self.stationObj?.marque
		
		let stationImage = UIImage(named: marque!.uppercased())
//		if(stationImage == nil){
//			let stationImage = UIImage(named: "icon_fuels")
//		}
		
		self.nomStation.text = self.stationObj?.marque
		self.stationID.text = self.stationObj?.idStation
		self.adresseStation.text = self.stationObj?.adresse
		self.codepostal.text = self.stationObj?.codePostal.description
		self.villeStation.text = self.stationObj?.ville
		self.imageStation.image = stationImage
		
		self.station = Utility.convStationObectToStation(stationObj: self.stationObj!)
			
		self.modalPresentationStyle = .overFullScreen
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 3
//    }
	
//	override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//		return 3.0
//	}

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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
