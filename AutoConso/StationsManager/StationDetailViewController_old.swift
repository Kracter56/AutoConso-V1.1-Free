//
//  StationDetailViewController.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 27/05/2019.
//  Copyright © 2019 Edgar PETRUS. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import UIKit
import Contacts
import Firebase
import FirebaseDatabase
import LCUIComponents
import RealmSwift

class StationDetailViewController: UITableViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIPopoverPresentationControllerDelegate {
	
	var station:stationObject?
	var idStation:String?
	@IBOutlet weak var imageStation: UIImageView!
	@IBOutlet weak var labelStationID: UILabel!
	@IBOutlet weak var labelStationName: UILabel!
	@IBOutlet weak var labelStationMARQUE: UILabel!
	@IBOutlet weak var labelStationAddress: UILabel!
	@IBOutlet weak var labelStationCodePostal: UILabel!
	@IBOutlet weak var labelStationVille: UILabel!
	@IBOutlet weak var labelStationLatitude: UILabel!
	@IBOutlet weak var labelStationLongitude: UILabel!
	@IBOutlet weak var buttonGuiderVersStation: UIButton!
	@IBOutlet weak var MapView: MKMapView!
	@IBOutlet weak var labelPrixDiesel: UILabel!
	@IBOutlet weak var labelPrixDieselPlus: UILabel!
	@IBOutlet weak var labelPrixSP95: UILabel!
    @IBOutlet weak var labelPrixSP95E10: UILabel!
	@IBOutlet weak var labelPrixSP98: UILabel!
	@IBOutlet weak var labelPrixEssPlus: UILabel!
	@IBOutlet weak var labelPrixE85: UILabel!
	@IBOutlet weak var labelPrixGPL: UILabel!
    @IBOutlet weak var labelDistanceStation: UILabel!
    @IBOutlet weak var labelTempsEstime: UILabel!
    
	/* date de mise à jour */
	@IBOutlet weak var dureeMajDiesel: UILabel!
	@IBOutlet weak var dureeMajDieselPlus: UILabel!
	@IBOutlet weak var dureeMajSP95: UILabel!
	@IBOutlet weak var dureeMajSP95E10: UILabel!
	@IBOutlet weak var dureeMajSP98: UILabel!
	@IBOutlet weak var dureeMajEssPlus: UILabel!
	@IBOutlet weak var dureeMajEss: UILabel!
	@IBOutlet weak var dureeMajGPL: UILabel!
	
	/* pseudo de mise à jour */
	@IBOutlet weak var pseudoMajDiesel: UILabel!
	@IBOutlet weak var pseudoMajDieselPlus: UILabel!
	@IBOutlet weak var pseudoMajSP95: UILabel!
	@IBOutlet weak var pseudoMajSP95E10: UILabel!
	@IBOutlet weak var pseudoMajSP98: UILabel!
	@IBOutlet weak var pseudoMajEssPlus: UILabel!
	@IBOutlet weak var pseudoMajEss: UILabel!
	@IBOutlet weak var pseudoMajGPL: UILabel!
	@IBOutlet weak var contentViewPenurie: UIView!
	
	/* lignes des services */
	@IBOutlet weak var cellServicesNonRenseignes: UITableViewCell!
	@IBOutlet weak var cellAireCampingCars: UITableViewCell!
	@IBOutlet weak var cellRestauration: UITableViewCell!
	@IBOutlet weak var CellAutomate2424: UITableViewCell!
	@IBOutlet weak var cellBorneDeRecharge: UITableViewCell!
	@IBOutlet weak var cellBoutiqueAlimentaire: UITableViewCell!
	@IBOutlet weak var cellBoutiqueNonAlimentaire: UITableViewCell!
	@IBOutlet weak var cellDistributeurDeBillet: UITableViewCell!
	@IBOutlet weak var cellDouches: UITableViewCell!
	@IBOutlet weak var cellEspaceBébé: UITableViewCell!
	@IBOutlet weak var cellGNV: UITableViewCell!
	@IBOutlet weak var CellLavageAuto: UITableViewCell!
	@IBOutlet weak var cellLavageManuel: UITableViewCell!
	@IBOutlet weak var cellLaverie: UITableViewCell!
	@IBOutlet weak var cellRelaisColis: UITableViewCell!
	@IBOutlet weak var cellStationGonflage: UITableViewCell!
	@IBOutlet weak var cellReparationEntretien: UITableViewCell!
	@IBOutlet weak var cellToilettesPubliques: UITableViewCell!
	@IBOutlet weak var cellVenteAdditifsCarburants: UITableViewCell!
	@IBOutlet weak var cellVenteFioulDomestique: UITableViewCell!
	@IBOutlet weak var cellVenteGazDomestique: UITableViewCell!
	@IBOutlet weak var cellVentePetroleLampant: UITableViewCell!
	@IBOutlet weak var cellWifi: UITableViewCell!
	@IBOutlet weak var cellPistePoidsLourdes: UITableViewCell!
	@IBOutlet weak var cellLocationVehicules: UITableViewCell!
	
	@IBOutlet weak var buttonChangerStation: UIButton!
	@IBAction func buttonChangerStation(_ sender: UIButton) {
		
		showPopOverBox(view: sender)
		
		
	}
	
	let locationManager = CLLocationManager()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
//		let realm = try! Realm()
//		let station = realm.objects(Station.self).filter("idStation = %@",self.idStation)

		/* On start, hide all the fuel station services */
		self.cellServicesNonRenseignes.isHidden = true
		self.cellAireCampingCars.isHidden = true
		self.cellRestauration.isHidden = true
		self.CellAutomate2424.isHidden = true
		self.cellBorneDeRecharge.isHidden = true
		self.cellBoutiqueAlimentaire.isHidden = true
		self.cellBoutiqueNonAlimentaire.isHidden = true
		self.cellDistributeurDeBillet.isHidden = true
		self.cellDouches.isHidden = true
		self.cellEspaceBébé.isHidden = true
		self.cellGNV.isHidden = true
		self.CellLavageAuto.isHidden = true
		self.cellLavageManuel.isHidden = true
		self.cellLaverie.isHidden = true
		self.cellRelaisColis.isHidden = true
		self.cellStationGonflage.isHidden = true
		self.cellReparationEntretien.isHidden = true
		self.cellToilettesPubliques.isHidden = true
		self.cellVenteAdditifsCarburants.isHidden = true
		self.cellVenteFioulDomestique.isHidden = true
		self.cellVenteGazDomestique.isHidden = true
		self.cellVentePetroleLampant.isHidden = true
		self.cellWifi.isHidden = true
		self.cellPistePoidsLourdes.isHidden = true
		self.cellLocationVehicules.isHidden = true
		
		updateServicesDisplay()
		
		let marque = self.station?.marque
		
		let stationImage = UIImage(named: marque!.uppercased())
		
		self.imageStation.image = stationImage
		self.labelStationID.text = self.station?.idStation
		self.labelStationName.text = self.station?.nom
		self.labelStationMARQUE.text = self.station?.marque
		self.labelStationAddress.text = self.station?.adresse
		self.labelStationCodePostal.text = self.station?.codePostal
		self.labelStationVille.text = self.station?.ville
		self.labelStationLatitude.text = self.station?.latitude.description
		self.labelStationLongitude.text = self.station?.longitude.description
		
		self.labelPrixSP95.text = self.station!.prixSP95 + " €/L"
		self.labelPrixDiesel.text = self.station!.prixDiesel + " €/L"
		self.labelPrixDieselPlus.text = self.station!.prixDieselPlus + " €/L"
		self.labelPrixSP95E10.text = self.station!.prixSP95E10 + " €/L"
		self.labelPrixSP98.text = self.station!.prixSP98 + " €/L"
		self.labelPrixEssPlus.text = self.station!.prixEssPlus + " €/L"
		self.labelPrixGPL.text = self.station!.prixGPL + " €/L"
		self.labelPrixE85.text = self.station!.prixEthanol + " €/L"
		
		if let dureeDiesel = Int(self.station!.majDiesel){
			switch dureeDiesel{
			case 0:
				self.dureeMajDiesel.text = "Aujourd'hui"
			case 1:
				self.dureeMajDiesel.text = "Hier"
			case 2..<30:
				self.dureeMajDiesel.text = "Il y a " + String(dureeDiesel) + " jours"
			default:
				self.dureeMajDiesel.text = "Il y a plus d'un mois"
				break
			}
		}
		if let dureeSP98 = Int(self.station!.majSP98){
			switch dureeSP98{
			case 0:
				self.dureeMajSP98.text = "Aujourd'hui"
			case 1:
				self.dureeMajSP98.text = "Hier"
			case 2..<30:
				self.dureeMajSP98.text = "Il y a " + String(dureeSP98) + " jours"
			default:
				self.dureeMajSP98.text = "Il y a plus d'un mois"
				break
			}
		}
		if let dureeSP95 = Int(self.station!.majSP95){
			switch dureeSP95{
			case 0:
				self.dureeMajSP95.text = "Aujourd'hui"
			case 1:
				self.dureeMajSP95.text = "Hier"
			case 2..<30:
				self.dureeMajSP95.text = "Il y a " + String(dureeSP95) + " jours"
			default:
				self.dureeMajSP95.text = "Il y a plus d'un mois"
				break
			}
		}
		if let dureeDieselPlus = Int(self.station!.majDieselPlus){
			switch dureeDieselPlus{
			case 0:
				self.dureeMajDieselPlus.text = "Aujourd'hui"
			case 1:
				self.dureeMajDieselPlus.text = "Hier"
			case 2..<30:
				self.dureeMajDieselPlus.text = "Il y a " + String(dureeDieselPlus) + " jours"
			default:
				self.dureeMajDieselPlus.text = "Il y a plus d'un mois"
				break
			}
		}
		if let dureeSP95E10 = Int(self.station!.majSP95E10){
			switch dureeSP95E10{
			case 0:
				self.dureeMajSP95E10.text = "Aujourd'hui"
			case 1:
				self.dureeMajSP95E10.text = "Hier"
			case 2..<30:
				self.dureeMajSP95E10.text = "Il y a " + String(dureeSP95E10) + " jours"
			default:
				self.dureeMajSP95E10.text = "Il y a plus d'un mois"
				break
			}
		}
		if let dureeGPL = Int(self.station!.majGPL){
			switch dureeGPL{
			case 0:
				self.dureeMajGPL.text = "Aujourd'hui"
			case 1:
				self.dureeMajGPL.text = "Hier"
			case 2..<30:
				self.dureeMajGPL.text = "Il y a " + String(dureeGPL) + " jours"
			default:
				self.dureeMajGPL.text = "Il y a plus d'un mois"
				break
			}
		}
		if let dureeEssPlus = Int(self.station!.majEssPlus){
			switch dureeEssPlus{
			case 0:
				self.dureeMajEssPlus.text = "Aujourd'hui"
			case 1:
				self.dureeMajEssPlus.text = "Hier"
			case 2..<30:
				self.dureeMajEssPlus.text = "Il y a " + String(dureeEssPlus) + " jours"
			default:
				self.dureeMajEssPlus.text = "Il y a plus d'un mois"
				break
			}
		}
		if let dureeE85 = Int(self.station!.majEthanol){
			switch dureeE85{
			case 0:
				self.dureeMajEss.text = "Aujourd'hui"
			case 1:
				self.dureeMajEss.text = "Hier"
			case 2..<30:
				self.dureeMajEss.text = "Il y a " + String(dureeE85) + " jours"
			default:
				self.dureeMajEss.text = "Il y a plus d'un mois"
				break
			}
		}
		
		self.pseudoMajDiesel.text = ""
		self.pseudoMajDieselPlus.text = ""
		self.pseudoMajEss.text = ""
		self.pseudoMajGPL.text = ""
		self.pseudoMajSP95.text = ""
		self.pseudoMajSP98.text = ""
		self.pseudoMajEssPlus.text = ""
		self.pseudoMajSP95E10.text = ""
		self.pseudoMajGPL.text = ""
		
		/* Localisation sur la carte */
		let center = CLLocationCoordinate2D(latitude: self.station!.latitude, longitude: self.station!.longitude)
		let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
		
		MapView.delegate = self
		self.MapView.setRegion(region, animated: true)
		
		let annotation = MKPointAnnotation()
		annotation.coordinate = CLLocationCoordinate2D(latitude: self.station!.latitude, longitude: self.station!.longitude)
		annotation.title = self.station?.marque
		annotation.subtitle = self.station?.ville
		self.MapView.addAnnotation(annotation)
		
		checkUsersLocationServicesAuthorization()
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
		locationManager.startUpdatingLocation()
	}
	@IBAction func buttonGuiderVersStation(_ sender: UIButton) {
		let coordinates = CLLocationCoordinate2DMake(self.station!.latitude, self.station!.longitude)
		let addressDict = [CNPostalAddressStreetKey: self.station?.nom, CNPostalAddressCityKey: self.station?.ville, CNPostalAddressStateKey: "France", CNPostalAddressPostalCodeKey: self.station?.codePostal]
		let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: addressDict)
		
		
		let mapitem = MKMapItem(placemark: placemark)
		let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
		mapitem.openInMaps(launchOptions: options)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let cell = super.tableView(tableView, cellForRowAt: indexPath)
		guard !cell.isHidden else {
			return 0
		}
		return super.tableView(tableView, heightForRowAt: indexPath)
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.section {
		case 3:
			switch indexPath.row {
			case 0:
				
				/* Display an actionsheet to propose price update or penurie of the selected carburant */
				let optionMenu = UIAlertController(title: nil, message: textStrings.strSignalementStationActionSheetTitle, preferredStyle: .actionSheet)
				let penurieAction = UIAlertAction(title: textStrings.strSignalementStationActionSheetChoice1, style: .default, handler:{
					(alert: UIAlertAction!) -> Void in
					
					let prixDiesel = self.labelPrixDiesel.text!
					
					let alert = UIAlertController(title: self.station?.nom, message: "Mise à jour du carburant Diesel", preferredStyle: .alert)
					alert.addTextField { (textField) in
						textField.keyboardType = .decimalPad
						textField.placeholder = prixDiesel
					}
					alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
						let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
						self.labelPrixDiesel.text = textField.text! + " €/L"
						self.dureeMajDiesel.text = "Aujourd'hui"
						/* Mise à jour de la donnée dans Firebase */
						let ref = Database.database().reference().child("Stations").child("Fr").child((self.station?.codePostal)!.description).child(self.station!.idStation)
						ref.updateChildValues(["Gazole_rupture": "oui"])
						ref.updateChildValues(["Gazole_user": UserDefaults.standard.string(forKey: "usrPseudo")])
						ref.updateChildValues(["Gazole_maj" : self.getUTCTimestamp()])
					}))
					alert.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: { [weak alert] (_) in
					}))
					self.present(alert, animated: true, completion: nil)
					
					print("Saved")
				})
				let updatePricesAction = UIAlertAction(title: textStrings.strSignalementStationActionSheetChoice2, style: .default, handler:{
					(alert: UIAlertAction!) -> Void in
					
					/* Mise à jour de la donnée dans Firebase */
					let ref = Database.database().reference().child("Stations").child("Fr").child((self.station?.codePostal)!.description).child(self.station!.idStation)
					ref.updateChildValues(["Gazole_rupture": "Oui"])
					ref.updateChildValues(["Gazole_user": UserDefaults.standard.string(forKey: "usrPseudo")])
					ref.updateChildValues(["Gazole_maj" : self.getUTCTimestamp()])
					
					print("Deleted")
				})
				let cancelAction = UIAlertAction(title: textStrings.strAnnuler, style: .cancel, handler:{
					(alert: UIAlertAction!) -> Void in
					print("Cancelled")
				})
				optionMenu.addAction(penurieAction)
				optionMenu.addAction(updatePricesAction)
				optionMenu.addAction(cancelAction)
				self.present(optionMenu, animated: true, completion: nil)
				
				
			case 1:
				
				let optionMenu = UIAlertController(title: nil, message: textStrings.strSignalementStationActionSheetTitle, preferredStyle: .actionSheet)
				let penurieAction = UIAlertAction(title: textStrings.strSignalementStationActionSheetChoice1, style: .default, handler:{
					(alert: UIAlertAction!) -> Void in
					
					let prixDiesel = self.labelPrixDieselPlus.text!
					
					let alert = UIAlertController(title: self.station?.nom, message: "Saisissez le prix du carburant Diesel Plus", preferredStyle: .alert)
					alert.addTextField { (textField) in
						textField.keyboardType = .decimalPad
						textField.placeholder = prixDiesel
					}
					alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
						let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
						self.labelPrixDieselPlus.text = textField.text! + " €/L"
						self.dureeMajDieselPlus.text = "Aujourd'hui"
						/* Mise à jour de la donnée dans Firebase */
						let ref = Database.database().reference().child("Stations").child("Fr").child((self.station?.codePostal)!.description).child(self.station!.idStation)
						ref.updateChildValues(["DieselPlus_prix": textField.text])
						ref.updateChildValues(["DieselPlus_user": UserDefaults.standard.string(forKey: "usrPseudo")])
						ref.updateChildValues(["DieselPlus_maj" : self.getUTCTimestamp()])
					}))
					alert.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: { [weak alert] (_) in
					}))
					self.present(alert, animated: true, completion: nil)
					
					print("Saved")
				})
				let updatePricesAction = UIAlertAction(title: textStrings.strSignalementStationActionSheetChoice2, style: .default, handler:{
					(alert: UIAlertAction!) -> Void in
					
					/* Mise à jour de la donnée dans Firebase */
					let ref = Database.database().reference().child("Stations").child("Fr").child((self.station?.codePostal)!.description).child(self.station!.idStation)
					ref.updateChildValues(["DieselPlus_rupture": "Oui"])
					ref.updateChildValues(["DieselPlus_user": UserDefaults.standard.string(forKey: "usrPseudo")])
					ref.updateChildValues(["DieselPlus_maj" : self.getUTCTimestamp()])
					
					print("Deleted")
				})
				let cancelAction = UIAlertAction(title: textStrings.strAnnuler, style: .cancel, handler:{
					(alert: UIAlertAction!) -> Void in
					print("Cancelled")
				})
				optionMenu.addAction(penurieAction)
				optionMenu.addAction(updatePricesAction)
				optionMenu.addAction(cancelAction)
				self.present(optionMenu, animated: true, completion: nil)
				
				
			case 2:
				
				let optionMenu = UIAlertController(title: nil, message: textStrings.strSignalementStationActionSheetTitle, preferredStyle: .actionSheet)
				let penurieAction = UIAlertAction(title: textStrings.strSignalementStationActionSheetChoice1, style: .default, handler:{
					(alert: UIAlertAction!) -> Void in
					
					let prixSP95 = self.labelPrixSP95.text!
					
					let alert = UIAlertController(title: self.station?.nom, message: "Saisissez le prix du carburant SP95", preferredStyle: .alert)
					alert.addTextField { (textField) in
						textField.keyboardType = .decimalPad
						textField.placeholder = prixSP95
					}
					alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
						let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
						self.labelPrixSP95.text = textField.text! + " €/L"
						self.dureeMajSP95.text = "Aujourd'hui"
						/* Mise à jour de la donnée dans Firebase */
						let ref = Database.database().reference().child("Stations").child("Fr").child((self.station?.codePostal)!.description).child(self.station!.idStation)
						ref.updateChildValues(["SP95_prix": textField.text])
						ref.updateChildValues(["SP95_user": UserDefaults.standard.string(forKey: "usrPseudo")])
						ref.updateChildValues(["SP95_maj" : self.getUTCTimestamp()])
					}))
					alert.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: { [weak alert] (_) in
					}))
					self.present(alert, animated: true, completion: nil)
					
					print("Saved")
				})
				let updatePricesAction = UIAlertAction(title: textStrings.strSignalementStationActionSheetChoice2, style: .default, handler:{
					(alert: UIAlertAction!) -> Void in
					
					/* Mise à jour de la donnée dans Firebase */
					let ref = Database.database().reference().child("Stations").child("Fr").child((self.station?.codePostal)!.description).child(self.station!.idStation)
					ref.updateChildValues(["SP95_rupture": "Oui"])
					ref.updateChildValues(["SP95_user": UserDefaults.standard.string(forKey: "usrPseudo")])
					ref.updateChildValues(["SP95_maj" : self.getUTCTimestamp()])
					
					print("Deleted")
				})
				let cancelAction = UIAlertAction(title: textStrings.strAnnuler, style: .cancel, handler:{
					(alert: UIAlertAction!) -> Void in
					print("Cancelled")
				})
				optionMenu.addAction(penurieAction)
				optionMenu.addAction(updatePricesAction)
				optionMenu.addAction(cancelAction)
				self.present(optionMenu, animated: true, completion: nil)
				
				
			case 3:
				
				let optionMenu = UIAlertController(title: nil, message: textStrings.strSignalementStationActionSheetTitle, preferredStyle: .actionSheet)
				let penurieAction = UIAlertAction(title: textStrings.strSignalementStationActionSheetChoice1, style: .default, handler:{
					(alert: UIAlertAction!) -> Void in
					
					let prixSP95E10 = self.labelPrixSP95E10.text!
					
					let alert = UIAlertController(title: self.station?.nom, message: "Saisissez le prix du carburant Sans Plomb 95 E10", preferredStyle: .alert)
					alert.addTextField { (textField) in
						textField.keyboardType = .decimalPad
						textField.placeholder = prixSP95E10
					}
					alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
						let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
						self.labelPrixSP95E10.text = textField.text! + " €/L"
						self.dureeMajSP95E10.text = "Aujourd'hui"
						/* Mise à jour de la donnée dans Firebase */
						let ref = Database.database().reference().child("Stations").child("Fr").child((self.station?.codePostal)!.description).child(self.station!.idStation)
						ref.updateChildValues(["E10_prix": textField.text])
						ref.updateChildValues(["E10_user": UserDefaults.standard.string(forKey: "usrPseudo")])
						ref.updateChildValues(["E10_maj" : self.getUTCTimestamp()])
					}))
					alert.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: { [weak alert] (_) in
					}))
					self.present(alert, animated: true, completion: nil)
					
					print("Saved")
				})
				let updatePricesAction = UIAlertAction(title: textStrings.strSignalementStationActionSheetChoice2, style: .default, handler:{
					(alert: UIAlertAction!) -> Void in
					
					/* Mise à jour de la donnée dans Firebase */
					let ref = Database.database().reference().child("Stations").child("Fr").child((self.station?.codePostal)!.description).child(self.station!.idStation)
					ref.updateChildValues(["E10_rupture": "Oui"])
					ref.updateChildValues(["E10_user": UserDefaults.standard.string(forKey: "usrPseudo")])
					ref.updateChildValues(["E10_maj" : self.getUTCTimestamp()])
					
					print("Deleted")
				})
				let cancelAction = UIAlertAction(title: textStrings.strAnnuler, style: .cancel, handler:{
					(alert: UIAlertAction!) -> Void in
					print("Cancelled")
				})
				optionMenu.addAction(penurieAction)
				optionMenu.addAction(updatePricesAction)
				optionMenu.addAction(cancelAction)
				self.present(optionMenu, animated: true, completion: nil)
				
				
				
			case 4:
				
				let optionMenu = UIAlertController(title: nil, message: textStrings.strSignalementStationActionSheetTitle, preferredStyle: .actionSheet)
				let penurieAction = UIAlertAction(title: textStrings.strSignalementStationActionSheetChoice1, style: .default, handler:{
					(alert: UIAlertAction!) -> Void in
					
					let prixSP98 = self.labelPrixSP98.text!
					
					let alert = UIAlertController(title: self.station?.nom, message: "Saisissez le prix du carburant Sans Plomb 98", preferredStyle: .alert)
					alert.addTextField { (textField) in
						textField.keyboardType = .decimalPad
						textField.placeholder = prixSP98
					}
					alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
						let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
						self.labelPrixSP98.text = textField.text! + " €/L"
						self.dureeMajSP98.text = "Aujourd'hui"
						/* Mise à jour de la donnée dans Firebase */
						let ref = Database.database().reference().child("Stations").child("Fr").child((self.station?.codePostal)!.description).child(self.station!.idStation)
						ref.updateChildValues(["SP98_prix": textField.text])
						ref.updateChildValues(["SP98_user": UserDefaults.standard.string(forKey: "usrPseudo")])
						ref.updateChildValues(["SP98_maj" : self.getUTCTimestamp()])
					}))
					alert.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: { [weak alert] (_) in
					}))
					self.present(alert, animated: true, completion: nil)
					
					print("Saved")
				})
				let updatePricesAction = UIAlertAction(title: textStrings.strSignalementStationActionSheetChoice2, style: .default, handler:{
					(alert: UIAlertAction!) -> Void in
					
					/* Mise à jour de la donnée dans Firebase */
					let ref = Database.database().reference().child("Stations").child("Fr").child((self.station?.codePostal)!.description).child(self.station!.idStation)
					ref.updateChildValues(["SP98_rupture": "Oui"])
					ref.updateChildValues(["SP98_user": UserDefaults.standard.string(forKey: "usrPseudo")])
					ref.updateChildValues(["SP98_maj" : self.getUTCTimestamp()])
					
					print("Deleted")
				})
				let cancelAction = UIAlertAction(title: textStrings.strAnnuler, style: .cancel, handler:{
					(alert: UIAlertAction!) -> Void in
					print("Cancelled")
				})
				optionMenu.addAction(penurieAction)
				optionMenu.addAction(updatePricesAction)
				optionMenu.addAction(cancelAction)
				self.present(optionMenu, animated: true, completion: nil)
				
				
				
				
				
			case 5:
				
				let optionMenu = UIAlertController(title: nil, message: textStrings.strSignalementStationActionSheetTitle, preferredStyle: .actionSheet)
				let penurieAction = UIAlertAction(title: textStrings.strSignalementStationActionSheetChoice1, style: .default, handler:{
					(alert: UIAlertAction!) -> Void in
					
					let prixEssPlus = self.labelPrixEssPlus.text!
					
					let alert = UIAlertController(title: self.station?.nom, message: "Saisissez le prix du carburant Essence Plus", preferredStyle: .alert)
					alert.addTextField { (textField) in
						textField.keyboardType = .decimalPad
						textField.placeholder = prixEssPlus
					}
					alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
						let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
						self.labelPrixEssPlus.text = textField.text! + " €/L"
						self.dureeMajEssPlus.text = "Aujourd'hui"
						/* Mise à jour de la donnée dans Firebase */
						let ref = Database.database().reference().child("Stations").child("Fr").child((self.station?.codePostal)!.description).child(self.station!.idStation)
						ref.updateChildValues(["EssencePlus_prix": textField.text])
						ref.updateChildValues(["EssencePlus_user": UserDefaults.standard.string(forKey: "usrPseudo")])
						ref.updateChildValues(["EssencePlus_maj" : self.getUTCTimestamp()])
					}))
					alert.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: { [weak alert] (_) in
					}))
					self.present(alert, animated: true, completion: nil)
					
					print("Saved")
				})
				let updatePricesAction = UIAlertAction(title: textStrings.strSignalementStationActionSheetChoice2, style: .default, handler:{
					(alert: UIAlertAction!) -> Void in
					
					/* Mise à jour de la donnée dans Firebase */
					let ref = Database.database().reference().child("Stations").child("Fr").child((self.station?.codePostal)!.description).child(self.station!.idStation)
					ref.updateChildValues(["EssencePlus_rupture": "Oui"])
					ref.updateChildValues(["EssencePlus_user": UserDefaults.standard.string(forKey: "usrPseudo")])
					ref.updateChildValues(["EssencePlus_maj" : self.getUTCTimestamp()])
					
					print("Deleted")
				})
				let cancelAction = UIAlertAction(title: textStrings.strAnnuler, style: .cancel, handler:{
					(alert: UIAlertAction!) -> Void in
					print("Cancelled")
				})
				optionMenu.addAction(penurieAction)
				optionMenu.addAction(updatePricesAction)
				optionMenu.addAction(cancelAction)
				self.present(optionMenu, animated: true, completion: nil)
				
				
			case 6:
				
				let optionMenu = UIAlertController(title: nil, message: textStrings.strSignalementStationActionSheetTitle, preferredStyle: .actionSheet)
				let penurieAction = UIAlertAction(title: textStrings.strSignalementStationActionSheetChoice1, style: .default, handler:{
					(alert: UIAlertAction!) -> Void in
					
					self.toastMessage(self.labelPrixE85.text!)
					let prixE85 = self.labelPrixE85.text!
					
					let alert = UIAlertController(title: self.station?.nom, message: "Saisissez le prix du carburant SuperEthanol E85", preferredStyle: .alert)
					alert.addTextField { (textField) in
						textField.keyboardType = .decimalPad
						textField.placeholder = prixE85
					}
					alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
						let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
						self.labelPrixE85.text = textField.text! + " €/L"
						self.dureeMajEss.text = "Aujourd'hui"
						/* Mise à jour de la donnée dans Firebase */
						let ref = Database.database().reference().child("Stations").child("Fr").child((self.station?.codePostal)!.description).child(self.station!.idStation)
						ref.updateChildValues(["E85_prix": textField.text])
						ref.updateChildValues(["E85_user": UserDefaults.standard.string(forKey: "usrPseudo")])
						ref.updateChildValues(["E85_maj" : self.getUTCTimestamp()])
					}))
					alert.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: { [weak alert] (_) in
					}))
					self.present(alert, animated: true, completion: nil)
					
					print("Saved")
				})
				let updatePricesAction = UIAlertAction(title: textStrings.strSignalementStationActionSheetChoice2, style: .default, handler:{
					(alert: UIAlertAction!) -> Void in
					
					/* Mise à jour de la donnée dans Firebase */
					let ref = Database.database().reference().child("Stations").child("Fr").child((self.station?.codePostal)!.description).child(self.station!.idStation)
					ref.updateChildValues(["E85_rupture": "Oui"])
					ref.updateChildValues(["E85_user": UserDefaults.standard.string(forKey: "usrPseudo")])
					ref.updateChildValues(["E85_maj" : self.getUTCTimestamp()])
					
					print("Deleted")
				})
				let cancelAction = UIAlertAction(title: textStrings.strAnnuler, style: .cancel, handler:{
					(alert: UIAlertAction!) -> Void in
					print("Cancelled")
				})
				optionMenu.addAction(penurieAction)
				optionMenu.addAction(updatePricesAction)
				optionMenu.addAction(cancelAction)
				self.present(optionMenu, animated: true, completion: nil)
				
				
				
				
				
			case 7:
				
				let optionMenu = UIAlertController(title: nil, message: textStrings.strSignalementStationActionSheetTitle, preferredStyle: .actionSheet)
				let penurieAction = UIAlertAction(title: textStrings.strSignalementStationActionSheetChoice1, style: .default, handler:{
					(alert: UIAlertAction!) -> Void in
					
					self.toastMessage(self.labelPrixGPL.text!)
					let prixGPL = self.labelPrixGPL.text!
					
					let alert = UIAlertController(title: self.station?.nom, message: "Saisissez le prix du carburant GPL", preferredStyle: .alert)
					alert.addTextField { (textField) in
						textField.keyboardType = .decimalPad
						textField.placeholder = prixGPL
					}
					alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
						let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
						self.labelPrixGPL.text = textField.text! + " €/L"
						self.dureeMajGPL.text = "Aujourd'hui"
						/* Mise à jour de la donnée dans Firebase */
						let ref = Database.database().reference().child("Stations").child("Fr").child((self.station?.codePostal)!.description).child(self.station!.idStation)
						ref.updateChildValues(["GPL_prix": textField.text])
						ref.updateChildValues(["GPL_user": UserDefaults.standard.string(forKey: "usrPseudo")])
						ref.updateChildValues(["GPL_maj" : self.getUTCTimestamp()])
					}))
					alert.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: { [weak alert] (_) in
					}))
					self.present(alert, animated: true, completion: nil)
					
					print("Saved")
				})
				let updatePricesAction = UIAlertAction(title: textStrings.strSignalementStationActionSheetChoice2, style: .default, handler:{
					(alert: UIAlertAction!) -> Void in
					
					/* Mise à jour de la donnée dans Firebase */
					let ref = Database.database().reference().child("Stations").child("Fr").child((self.station?.codePostal)!.description).child(self.station!.idStation)
					ref.updateChildValues(["GPL_rupture": "Oui"])
					ref.updateChildValues(["GPL_user": UserDefaults.standard.string(forKey: "usrPseudo")])
					ref.updateChildValues(["GPL_maj" : self.getUTCTimestamp()])
					
					print("Deleted")
				})
				let cancelAction = UIAlertAction(title: textStrings.strAnnuler, style: .cancel, handler:{
					(alert: UIAlertAction!) -> Void in
					print("Cancelled")
				})
				optionMenu.addAction(penurieAction)
				optionMenu.addAction(updatePricesAction)
				optionMenu.addAction(cancelAction)
				self.present(optionMenu, animated: true, completion: nil)
				
				
			default:
				break
			}
		case 4:
			switch indexPath.row{
			case 0:
				//showPopOverBox(view: self.tableView.cellForRow(at: indexPath)!)
				/*let items = ["SP95", "SP95E10", "SP98", "Gazole", "Diesel Plus", "GPLc", "E85"]
				let controller = ArrayChoiceTableViewController(items) { (name) in
					print("\(name) selected")
				}
				controller.preferredContentSize = CGSize(width: 300, height: 200)
				//showPopup(controller, sourceView: self.contentViewPenurie)
				
				let items = [URL(string: "http://www.example.com")!, URL(string: "http://www.test.com")!]
				let controller = ArrayChoiceTableViewController(items, labels: { $0.host ?? "-" }) { (url) in
				print("\(url) selected")
				}
				*/
				
				break
				
			default:
				break
			}
		default:
			break
		}
	}
	
	func signalerCarburant(carburant:String){
		
		
		
	}
	
	func showPopOverBox(view:UIView)
	{
        let popoverViewController = self.storyboard?.instantiateViewController(withIdentifier: "popoverVC") as! popOverViewController
        popoverViewController.modalPresentationStyle = .popover
        popoverViewController.preferredContentSize = CGSize.init(width: 50, height: 20)
		
        let popoverPresentationViewController = popoverViewController.popoverPresentationController
		
		popoverPresentationViewController?.permittedArrowDirections = UIPopoverArrowDirection.down
		popoverPresentationViewController?.sourceView = view
		popoverPresentationViewController?.sourceRect = view.bounds
		
        present(popoverViewController, animated: true, completion: nil)
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let location = locations.last
		
		let centerOnCurrentLocation = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
		let region = MKCoordinateRegion(center: centerOnCurrentLocation, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
		
		let stationCoordinates = CLLocationCoordinate2DMake(Double(self.station!.latitude), Double(self.station!.longitude))
		let addressDictStation = [CNPostalAddressStreetKey: self.station?.nom, CNPostalAddressCityKey: self.station?.ville, CNPostalAddressStateKey: "France", CNPostalAddressPostalCodeKey: self.station?.codePostal]
		let placemarkStation = MKPlacemark(coordinate: stationCoordinates, addressDictionary: addressDictStation)
		
		let myCoordinates = CLLocationCoordinate2DMake(location!.coordinate.latitude, location!.coordinate.longitude)
		let myAddressDict = [CNPostalAddressStreetKey: "Vous etes ici"]
		let myPlacemark = MKPlacemark(coordinate: myCoordinates, addressDictionary: myAddressDict)
		
		
		//bigMap.setRegion(region, animated: true)
		self.locationManager.stopUpdatingLocation()
		
		let myPIN = MKPointAnnotation()
		myPIN.coordinate = location!.coordinate
		myPIN.title = "Vous etes ici"
		
		let stationPIN = MKPointAnnotation()
		stationPIN.coordinate = stationCoordinates
		stationPIN.title = self.station?.nom
		let centerregion = MKCoordinateRegion(center: stationCoordinates, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
		
		self.MapView.addAnnotation(myPIN)
		self.MapView.addAnnotation(stationPIN)
		self.MapView.setRegion(centerregion, animated: true)
		showRouteOnMap(pickupCoordinate: myPIN.coordinate, destinationCoordinate: stationPIN.coordinate)
		//self.MapView.fitAllMarkers(shouldIncludeCurrentLocation: true)
		//self.MapView.showAnnotations(self.MapView.annotations, animated: true)
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Errors " + error.localizedDescription)
	}
	
	/*func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?
	{
		if !(annotation is MKPointAnnotation) {
			return nil
		}
		
		let annotationIdentifier = "AnnotationIdentifier"
		var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
		
		if annotationView == nil {
			annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
			annotationView!.canShowCallout = true
		}
		else {
			annotationView!.annotation = annotation
		}
		
		let pinImage = UIImage(named: "customPinImage")
		annotationView!.image = pinImage
		return annotationView
	}*/
	
	/*func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		let renderer = MKPolylineRenderer(overlay: overlay)
		renderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)
		renderer.lineWidth = 5.0
		return renderer
	}*/
	
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		let renderer = MKPolylineRenderer(overlay: overlay)
		renderer.strokeColor = UIColor(red: 255.0/255.0, green: 47.0/255.0, blue: 17.0/255.0, alpha: 1)
		renderer.lineWidth = 2.0
		return renderer
	}
	
	
	/* Cette fonction vérifie les autorisations pour le GPS, si tout est OK, lance une recherche des stations */
	func checkUsersLocationServicesAuthorization(){
		
		let titleEnableGPS = NSLocalizedString("Autorisation GPS", comment: "titleEnableGPS")
		let messageEnableGPS = NSLocalizedString("L'app AutoConso a besoin d'accéder à votre localisation. Activer les permissions de localisation dans le menu Réglages de votre iPhone", comment: "messageEnableGPS")
		let settingsButton = NSLocalizedString("Réglages", comment: "settingsButton")
		
		switch CLLocationManager.authorizationStatus() {
			
		case .notDetermined:
			// Request when-in-use authorization initially
			// This is the first and the ONLY time you will be able to ask the user for permission
			self.locationManager.delegate = self
			locationManager.requestWhenInUseAuthorization()
			//self.localisationOK = false
			break
			
		case .restricted, .denied:
			// Disable location features
			
			/*SweetAlert().showAlert(titleEnableGPS, subTitle: messageEnableGPS, style: AlertStyle.customImage(imageFile: "icon_location"), buttonTitle:settingsButton, buttonColor:self.UIColorFromRGB(rgbValue: 0xD0D0D0))
			{ action in
				guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
					return
				}
				if UIApplication.shared.canOpenURL(settingsUrl) {
					UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
						print("Settings opened: \(success)")
					})
				}
				
			}*/
			
			break
			
		case .authorizedWhenInUse, .authorizedAlways:
			// Enable features that require aaaation services here.
			print("Full Access")
			//self.localisationOK = true
			print("authorizedWhenInUse-out")
			break
		}
	}
	
	func getTimestamp() -> String {
		let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
		return timestamp
	}
	
	func getUTCTimestamp() -> String {
		//let timestamp = Date.init(timeIntervalSince1970: 1/1000).description
		let date = Date()
		// "Nov 2, 2016, 4:48 AM" <-- local time
		
		var formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
		let defaultTimeZoneStr = formatter.string(from: date)
		// "2016-11-02 04:48:53 +0800" <-- same date, local with seconds and time zone
		formatter.timeZone = TimeZone(abbreviation: "UTC")
		let utcTimeZoneStr = formatter.string(from: date)
		// "2016-11-01 20:48:53 +0000" <-- same date, now in UTC
		return utcTimeZoneStr
	}
	
	func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
		
		let sourcePlacemark = MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil)
		let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)
		
		let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
		let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
		
		let sourceAnnotation = MKPointAnnotation()
		
		if let location = sourcePlacemark.location {
			sourceAnnotation.coordinate = location.coordinate
		}
		
		let destinationAnnotation = MKPointAnnotation()
		
		if let location = destinationPlacemark.location {
			destinationAnnotation.coordinate = location.coordinate
		}
		
		self.MapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
		
		let directionRequest = MKDirections.Request()
		directionRequest.source = sourceMapItem
		directionRequest.destination = destinationMapItem
		directionRequest.transportType = .automobile
		
		// Calculate the direction
		let directions = MKDirections(request: directionRequest)
		
		directions.calculate {
			(response, error) -> Void in
			
			guard let response = response else {
				if let error = error {
					print("Error: \(error)")
				}
				
				return
			}
			
			let route = response.routes[0]
			let eta = route.expectedTravelTime
			let distance = Double(round(route.distance)/1000)
			
			let temps = self.secondsToHoursMinutesSeconds(seconds: Int(eta))
			
            self.labelDistanceStation.text = distance.description + " km"
            self.labelTempsEstime.text = temps
            
			self.MapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
			
			let rect = route.polyline.boundingMapRect
			self.MapView.setRegion(MKCoordinateRegion(rect), animated: true)
		}
	}
	
	func secondsToHoursMinutesSeconds (seconds : Int) -> (String) {
		var tps:String = "Calcul..."
		if(seconds>3600){
			let h = seconds/3600
			let m = (seconds % 3600)/60
			let s = (seconds % 3600) % 60
			return h.description + "h " + m.description + " min."
		}
		if(seconds<3600){
			let m = (seconds % 3600)/60
			let s = (seconds % 3600) % 60
			return m.description + " min."
		}
		return tps
	}
	
	func updateServicesDisplay(){
		var servicesString = self.station?.services
		let servicesArray = servicesString?.split(separator: ";")
		
		if(servicesArray?.count == 0){
			self.cellServicesNonRenseignes.isHidden = false
			
			if((servicesString == "-")||(servicesString == "")){
				self.cellServicesNonRenseignes.isHidden = false
			}else{
				self.cellServicesNonRenseignes.isHidden = true
			}
			
		}else{
			self.cellServicesNonRenseignes.isHidden = true
			
			for services in servicesArray!{
				switch services{
					
				case "Carburant additive":
					self.cellVenteAdditifsCarburants.isHidden = false
					break
					
				case "Station de gonflage":
					self.cellStationGonflage.isHidden = false
					break
					
				case "Vente de gaz domestique (Butane, Propane)":
					self.cellVenteGazDomestique.isHidden = false
					break
					
				case "DAB (Distributeur automatique de billets)":
					self.cellDistributeurDeBillet.isHidden = false
					break
					
				case "Automate CB 24/24":
					self.CellAutomate2424.isHidden = false
					break
					
				case "Boutique alimentaire":
					self.cellBoutiqueAlimentaire.isHidden = false
					break
					
				case "Boutique non alimentaire":
					self.cellBoutiqueNonAlimentaire.isHidden = false
					break
					
				case "Services reparation / entretien":
					self.cellReparationEntretien.isHidden = false
					break
					
				case "Location de vehicule":
					self.cellLocationVehicules.isHidden = false
					break
					
				case "Piste poids lourds":
					self.cellPistePoidsLourdes.isHidden = false
					break
					
				case "Lavage automatique":
					self.CellLavageAuto.isHidden = false
					break
					
				case "Lavage manuel":
					self.cellLavageManuel.isHidden = false
					break
					
				case "Toilettes publiques":
					self.cellToilettesPubliques.isHidden = false
					break
					
				case "Relais colis":
					self.cellRelaisColis.isHidden = false
					break
					
				case "Vente de fioul domestique":
					self.cellVenteFioulDomestique.isHidden = false
					break
					
				case "Restauration à emporter":
					self.cellRestauration.isHidden = false
					break
					
				case "Restauration":
					self.cellRestauration.isHidden = false
					break
					
				case "à emporter":
					self.cellRestauration.isHidden = false
					break
					
				case "Wifi":
					self.cellWifi.isHidden = false
					break
					
				case "Bar":
					self.cellRestauration.isHidden = false	//Add bar on the list
					break
					
				case "Espace bebe":
					self.cellEspaceBébé.isHidden = false
					break
					
				case "Laverie":
					self.cellLaverie.isHidden = false
					break
					
				case "Aire de camping-cars":
					self.cellAireCampingCars.isHidden = false
					break
					
				case "Bornes electriques":
					self.cellBorneDeRecharge.isHidden = false //Add Bornes electriques on the list
					break
					
				case "Vente de petrole lampant":
					self.cellVentePetroleLampant.isHidden = false
					break
					
				case "Douches":
					self.cellDouches.isHidden = false
					break
					
				case "GNV":
					self.cellGNV.isHidden = false
					break
					
				case "-":
					self.cellServicesNonRenseignes.isHidden = false
					break
					
				default:
					self.cellServicesNonRenseignes.isHidden = false
					break
				}
		}
		
		
		
		
		
		}
	}
	
	// MARK: - MKMapViewDelegate
	/*func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		let renderer = MKPolylineRenderer(overlay: overlay)
		renderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)
		renderer.lineWidth = 5.0
		return renderer
	}*/
	
}

/*extension UIViewController: MKMapViewDelegate {
	
	func MapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
		// once annotationView is added to the map, get the last one added unless it is the user's location:
		if let annotationView = views.last {
			// show callout programmatically:
			mapView.selectAnnotation(annotationView.annotation!, animated: false)
			// zoom to all annotations on the map:
			mapView.showAnnotations(mapView.annotations, animated: true)
		}
	}
}*/

/*class myCustomAnnotationView : MKAnnotationView {
	
	override var annotation: MKAnnotation? {
		willSet {
			guard let annotation = newValue else {return}
			switch annotation {
			case is myCustomMKAnnotation:
				self.canShowCallout = true
				self.image = #yourimage
				self.centerOffset = CGPoint(x: 0, y: -self.image!.size.height / 2)
				break
			default:
				return
			}
			self.setAnimationLayer()
		}
}*/

/*extension MKMapView
{
	func fitAllMarkers(shouldIncludeCurrentLocation: Bool) {
		
		if !shouldIncludeCurrentLocation
		{
			showAnnotations(annotations, animated: true)
		}
		else
		{
			var zoomRect = MKMapRect.null
			
			let point = MKMapPoint(userLocation.coordinate)
			let pointRect = MKMapRect(x: point.x, y: point.y, width: 0, height: 0)
			zoomRect = zoomRect.union(pointRect)
			
			for annotation in annotations {
				
				let annotationPoint = MKMapPoint(annotation.coordinate)
				let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0, height: 0)
				
				if (zoomRect.isNull){
					zoomRect = pointRect
				} else {
					zoomRect = zoomRect.union(pointRect)
				}
			}
			
			setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8), animated: true)
		}
	}
	
	
}*/
